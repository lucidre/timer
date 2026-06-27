import 'dart:io';
import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';

// ─────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────
const int _kPort = 41234; // pick any unused UDP port, same on all devices
const String _kBroadcastAddr = '255.255.255.255';
const String _kAppMagic =
    'TIMER_SYNC_V1'; // prevents collisions with other apps

// ─────────────────────────────────────────────────────────────
// SYNC EVENT TYPES
// ─────────────────────────────────────────────────────────────
enum SyncEventType {
  scheduleInserted,
  scheduleModified,
  scheduleDeleted,
  fullSync, // sender broadcasts their entire list (e.g. on app start)
  ping, // discovery / presence heartbeat
  pong, // reply to ping — triggers full sync response
}

// ─────────────────────────────────────────────────────────────
// SYNC PACKET  — what travels over the wire (JSON)
// ─────────────────────────────────────────────────────────────
class SyncPacket {
  final String magic;
  final String senderId; // unique per device instance
  final SyncEventType type;
  final List<Schedule>? schedules; // full list for fullSync
  final Schedule? schedule; // single item for insert/modify/delete
  final int? scheduleId; // id only for delete
  final DateTime sentAt;

  SyncPacket({
    required this.senderId,
    required this.type,
    this.schedules,
    this.schedule,
    this.scheduleId,
  }) : magic = _kAppMagic,
       sentAt = DateTime.now();

  // ── Serialisation ──────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'magic': magic,
    'senderId': senderId,
    'type': type.name,
    'schedules': schedules?.map((s) => s.toJson()).toList(),
    'schedule': schedule?.toJson(),
    'scheduleId': scheduleId,
    'sentAt': sentAt.toIso8601String(),
  };

  factory SyncPacket.fromJson(Map<String, dynamic> json) {
    return SyncPacket(
      senderId: json['senderId'] as String,
      type: SyncEventType.values.byName(json['type'] as String),
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((e) => Schedule.fromMap(e as Map<String, dynamic>))
          .toList(),
      schedule: json['schedule'] != null
          ? Schedule.fromMap(json['schedule'] as Map<String, dynamic>)
          : null,
      scheduleId: json['scheduleId'] as int?,
    );
  }

  List<int> encode() => utf8.encode(jsonEncode(toJson()));

  static SyncPacket? tryDecode(List<int> bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      // Drop packets from other apps on the same port
      if (json['magic'] != _kAppMagic) return null;
      return SyncPacket.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// SCHEDULE SYNC SERVICE
//
// Drop this into GetX as a singleton:
//   Get.put(ScheduleSyncService());
//
// Then in DashboardController:
//   final _sync = Get.find<ScheduleSyncService>();
// ─────────────────────────────────────────────────────────────
class ScheduleSyncService extends GetxService {
  // ── Public stream — controller observes this ───────────────
  final _eventController = StreamController<SyncPacket>.broadcast();
  Stream<SyncPacket> get events => _eventController.stream;

  // ── Internal state ─────────────────────────────────────────
  late final String _senderId;
  RawDatagramSocket? _socket;
  bool _isRunning = false;

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Unique ID per device session (stable within one app launch)
    _senderId = DateTime.now().microsecondsSinceEpoch.toString();
    _start();
  }

  @override
  void onClose() {
    _stop();
    _eventController.close();
    super.onClose();
  }

  // ── Socket setup ───────────────────────────────────────────
  Future<void> _start() async {
    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _kPort,
        reuseAddress:
            true, // lets multiple apps bind the same port on one device (dev)
        reusePort: false,
      );

      _socket!.broadcastEnabled = true;
      _isRunning = true;

      AppLogger.log(
        'sync',
        'UDP socket bound on port $_kPort [id: $_senderId]',
      );

      _socket!.listen(
        _onSocketEvent,
        onError: (e) => AppLogger.error('sync', 'Socket error: $e'),
        onDone: () {
          _isRunning = false;
          AppLogger.log('sync', 'Socket closed');
        },
      );

      // Let peers know we just joined — they'll reply with fullSync
      await _sendPing();
    } catch (e) {
      AppLogger.error('sync', 'Failed to bind UDP socket: $e');
    }
  }

  void _stop() {
    _isRunning = false;
    _socket?.close();
    _socket = null;
  }

  // ── Receive ────────────────────────────────────────────────
  void _onSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    final datagram = _socket?.receive();
    if (datagram == null) return;

    final packet = SyncPacket.tryDecode(datagram.data);
    if (packet == null) return;

    // Ignore our own broadcasts
    if (packet.senderId == _senderId) return;

    AppLogger.log(
      'sync',
      'Received ${packet.type.name} from ${packet.senderId}',
    );

    // If a new peer pings us, they want our full list — handled in controller
    _eventController.add(packet);
  }

  // ── Send helpers ───────────────────────────────────────────
  Future<void> _broadcast(SyncPacket packet) async {
    if (!_isRunning || _socket == null) return;
    try {
      final bytes = packet.encode();
      _socket!.send(bytes, InternetAddress(_kBroadcastAddr), _kPort);
      AppLogger.log('sync', 'Broadcast ${packet.type.name} (${bytes.length}b)');
    } catch (e) {
      AppLogger.error('sync', 'Broadcast failed: $e');
    }
  }

  // ── Public API — called from DashboardController ───────────

  /// Someone joined the network — announce our presence
  Future<void> _sendPing() =>
      _broadcast(SyncPacket(senderId: _senderId, type: SyncEventType.ping));

  /// Reply to a ping with our full schedule list
  Future<void> broadcastFullSync(List<Schedule> schedules) => _broadcast(
    SyncPacket(
      senderId: _senderId,
      type: SyncEventType.fullSync,
      schedules: schedules,
    ),
  );

  /// A new schedule was added
  Future<void> broadcastInsert(Schedule schedule) => _broadcast(
    SyncPacket(
      senderId: _senderId,
      type: SyncEventType.scheduleInserted,
      schedule: schedule,
    ),
  );

  /// An existing schedule was modified
  Future<void> broadcastModify(Schedule schedule) => _broadcast(
    SyncPacket(
      senderId: _senderId,
      type: SyncEventType.scheduleModified,
      schedule: schedule,
    ),
  );

  /// A schedule was deleted
  Future<void> broadcastDelete(int scheduleId) => _broadcast(
    SyncPacket(
      senderId: _senderId,
      type: SyncEventType.scheduleDeleted,
      scheduleId: scheduleId,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// DASHBOARD CONTROLLER MIXIN
//
// Add `with ScheduleSyncMixin` to your DashboardController and
// call initSync() from onInit() and disposeSync() from onClose().
//
// The mixin wires the stream → your existing schedules list.
// ─────────────────────────────────────────────────────────────
mixin ScheduleSyncMixin on GetxController {
  // Must be implemented by the controller
  RxList<Schedule> get schedules;
  Future<void> getData();

  late final ScheduleSyncService _syncService;
  StreamSubscription<SyncPacket>? _syncSub;

  void initSync() {
    _syncService = Get.find<ScheduleSyncService>();
    _syncSub = _syncService.events.listen(_handleIncoming);
  }

  void disposeSync() {
    _syncSub?.cancel();
  }

  // ── Incoming packet router ──────────────────────────────────
  void _handleIncoming(SyncPacket packet) {
    debugPrint('Handling: $packet');
    switch (packet.type) {
      // A new peer just joined — send them our full list
      case .ping:
        _syncService.broadcastFullSync(schedules.toList());
        break;

      // A peer replied to our ping — merge their list
      case .fullSync:
      case .pong:
        if (packet.schedules != null) _mergeFullList(packet.schedules!);
        break;

      // Single-item mutations
      case .scheduleInserted:
        if (packet.schedule != null) _applyInsert(packet.schedule!);
        break;

      case .scheduleModified:
        if (packet.schedule != null) _applyModify(packet.schedule!);
        break;

      case .scheduleDeleted:
        //TODO: if (packet.scheduleId != null) _applyDelete(packet.scheduleId!);
        break;
    }
  }

  // ── Merge strategies ───────────────────────────────────────

  /// Full sync: keep items from remote that don't exist locally,
  /// update items that exist on both sides (remote wins — last-write).
  void _mergeFullList(List<Schedule> remote) {
    debugPrint('Merge Full List: $remote');
    for (final remoteItem in remote) {
      final idx = schedules.indexWhere((s) => s.id == remoteItem.id);
      if (idx == -1) {
        schedules.add(remoteItem);
      } else {
        // Last-write wins: keep whichever was updated most recently
        final local = schedules[idx];
        if (_isNewer(remoteItem, local)) {
          schedules[idx] = remoteItem;
        }
      }
    }
    _sortSchedules();
  }

  void _applyInsert(Schedule schedule) {
    final exists = schedules.any((s) => s.id == schedule.id);
    if (!exists) {
      schedules.add(schedule);
      _sortSchedules();
    }
  }

  void _applyModify(Schedule schedule) {
    final idx = schedules.indexWhere((s) => s.id == schedule.id);
    if (idx != -1) {
      final local = schedules[idx];
      if (_isNewer(schedule, local)) {
        schedules[idx] = schedule;
        _sortSchedules();
      }
    } else {
      // We don't have this item — treat as insert
      _applyInsert(schedule);
    }
  }

  void _applyDelete(int scheduleId) {
    schedules.removeWhere((s) => s.id == scheduleId);
  }

  /// Sort by start time so the list stays ordered after remote inserts
  void _sortSchedules() {
    schedules.sort((a, b) {
      final aStart = a.start;
      final bStart = b.start;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return aStart.compareTo(bStart);
    });
  }

  /// Compares updatedAt timestamps — assumes Schedule has an `updatedAt` field.
  /// Falls back to true (remote wins) if timestamps unavailable.
  bool _isNewer(Schedule remote, Schedule local) {
    final r = remote.updatedAt;
    final l = local.updatedAt;
    if (r == null || l == null) return true;
    return r.isAfter(l);
  }

  // ── Outgoing broadcast helpers ──────────────────────────────
  // Call these AFTER your local persistence succeeds.

  void syncInsert(Schedule schedule) => _syncService.broadcastInsert(schedule);

  void syncModify(Schedule schedule) => _syncService.broadcastModify(schedule);

  void syncDelete(int scheduleId) => _syncService.broadcastDelete(scheduleId);

  void syncFullList() => _syncService.broadcastFullSync(schedules.toList());
}
