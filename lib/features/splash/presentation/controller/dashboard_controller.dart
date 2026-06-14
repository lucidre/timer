import 'package:timer/common_libs.dart';
import 'package:timer/features/splash/data/data_sources/schedule_sync.dart';
import 'package:timer/features/splash/data/repositorites/splash_repository_impl.dart';
import 'package:timer/features/splash/domain/usecases/splash_service.dart';
import 'package:timer/features/splash/models/schedule/schedule.dart';

//TODO: EDITR ITEM WITHOUT IT BEING CURRENT.
// ADD BUTTONS
// DRAG AND REORDER.
final _normalSpectrum = [
  primaryColor,
  secondaryColor,
  tertiaryColor,
  const Color(0xFF4F46E5),
];

final _warningSpectrum = [warning400, warning500, warning600, warning700];

final _overtimeSpectrum = [
  destructive500,
  destructive600,
  destructive700,
  accentCrimson,
];

class DashboardController extends GetxController with ScheduleSyncMixin {
  final SplashService service;

  DashboardController() : service = .new(SplashRepositoryImpl(.new()));

  @override
  final schedules = <Schedule>[].obs;
  final _gradients = <Color>[].obs;
  final _current = Rxn<Schedule>();
  final _state = TimerState.good.obs;
  final _remaining = Duration.zero.obs;
  final _warningRange = 0.0.obs;
  final _isLoading = true.obs;
  final _isRefreshing = false.obs;
  final _errorOccurred = false.obs;
  final _isScrolling = false.obs;

  Timer? _ticker;
  Timer? _scrollTimer;
  late final RefreshController refreshController;
  late final ScrollController scrollController;

  // Getters

  List<Color> get gradients => _gradients;
  bool get isLoading => _isLoading.value;
  bool get errorOccurred => _errorOccurred.value;
  bool get isRefreshing => _isRefreshing.value;
  Schedule? get current => _current.value;
  Duration get remaining => _remaining.value;
  bool get isOvertime => _remaining.value.isNegative;
  TimerState get state => _state.value;
  double get warningRange => _warningRange.value;
  String get timeSign => isOvertime ? '-' : '';
  bool get isScrolling => _isScrolling.value;

  bool get isWarning {
    if (current == null || isOvertime) return false;
    return remaining.inSeconds <= warningRange;
  }

  String get formattedHours {
    final int hours = remaining.abs().inHours;
    if (hours == 0) return '';
    return '${hours.toString().padLeft(2, '0')}H';
  }

  String get formattedMinutes {
    final int minutes = remaining.abs().inMinutes % 60;
    if (minutes == 0) return '';
    return '${minutes.toString().padLeft(2, '0')}M';
  }

  String get formattedSeconds {
    final int seconds = remaining.abs().inSeconds % 60;
    return '${seconds.toString().padLeft(2, '0')}S';
  }

  // Setters
  set schedules(List<Schedule> value) => schedules.value = value;
  set isLoading(bool value) => _isLoading.value = value;
  set errorOccurred(bool value) => _errorOccurred.value = value;
  set isRefreshing(bool value) => _isRefreshing.value = value;
  set gradients(List<Color> value) => _gradients.value = value;
  set state(TimerState value) => _state.value = value;
  set warningRange(double value) => _warningRange.value = value;
  set remaining(Duration value) => _remaining.value = value;
  set isScrolling(bool value) => _isScrolling.value = value;

  Future<void> setCurrent(Schedule schedule) async {
    _current.value = schedule;

    startCountdown();
    await pushToTimer();
  }

  Future<void> onNext() async {
    if (current == null) return;
    final indexOf = schedules.indexOf(current!);
    if (indexOf != -1 && indexOf != schedules.length - 1) {
      await setCurrent(schedules[indexOf + 1]);
    }
  }

  Future<void> applyTime({
    required bool isAddition,
    required Duration duration,
    required bool isShifting,
  }) async {
    //TODO: APPLU PLUS ON A TIME THAT IS ALREADY 5 SECONDS IS NOT WORKING. SO REMOVE LIKE AN HOUR AND ADD AND IT WOUDL NOT WORK.

    if (current == null) return;

    final fromIndex = schedules.indexOf(current!);
    if (fromIndex == -1) return;

    final blockStart = current!.start;
    final blockEnd = current!.end;
    if (blockStart == null || blockEnd == null) return;

    final Duration resolved;

    if (isAddition) {
      resolved = duration;
    } else {
      const minGap = Duration(seconds: 5);
      final earliest = blockStart.add(minGap);
      final reduced = blockEnd.subtract(duration);

      resolved = reduced.isBefore(earliest)
          ? blockEnd.difference(earliest)
          : duration;
    }

    final updatedEnd = isAddition
        ? blockEnd.add(resolved)
        : blockEnd.subtract(resolved);

    schedules[fromIndex] = current!.copyWith(end: updatedEnd);
    _current.value = schedules[fromIndex];

    if (!isShifting || resolved == .zero) {
      await setCurrent(schedules[fromIndex]);
      return;
    }

    for (int i = fromIndex + 1; i < schedules.length; i++) {
      final block = schedules[i];
      if (block.start == null || block.end == null) continue;

      schedules[i] = block.copyWith(
        start: isAddition
            ? block.start!.add(resolved)
            : block.start!.subtract(resolved),
        end: isAddition
            ? block.end!.add(resolved)
            : block.end!.subtract(resolved),
      );
    }

    await setCurrent(schedules[fromIndex]);
  }

  Future<bool?> onPrevious() async {
    if (current == null) return null;

    final indexOf = schedules.indexOf(current!);
    if (indexOf != -1 && indexOf - 1 <= 0) {
      final item = schedules[indexOf - 1];
      if (isSchedulePast(item)) return true;
      setCurrent(item);
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    initSync();
    scrollController = ScrollController();
    refreshController = RefreshController(initialRefresh: false);
    refreshGradients(false, false);
    scrollController.addListener(onScroll);
  }

  @override
  void onClose() {
    disposeSync();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    refreshController.dispose();
    stopCountdown();
    super.onClose();
  }

  void onScroll() {
    isScrolling = true;
    _scrollTimer?.cancel();
    _scrollTimer = Timer(1.seconds, () => isScrolling = false);
  }

  Future<void> pushToTimer() async {
    final blockStart = current!.start;
    final blockEnd = current!.end;

    if (blockStart == null || blockEnd == null) {
      throw DashboardControllerErrors.nullTime;
    }

    await service.pushAndStart(
      host: 'http://${AppPreferences.deviceIp}',
      startDate: blockStart.isBefore(.now()) ? .now() : blockStart,
      endDate: blockEnd,
    );
  }

  void refreshGradients(bool isWarning, bool isOvertime) {
    List<Color> activeBucket;

    if (isOvertime) {
      activeBucket = .of(_overtimeSpectrum);
    } else if (isWarning) {
      activeBucket = .of(_warningSpectrum);
    } else {
      activeBucket = .of(_normalSpectrum);
    }

    activeBucket.shuffle();

    gradients = activeBucket.take(3).toList();
  }

  void stopCountdown() => _ticker?.cancel();

  void startCountdown() {
    _ticker?.cancel();
    _setWarningRange();
    _updateTimer();
    _ticker = .periodic(1.seconds, (_) => _updateTimer());
  }

  void _setWarningRange() {
    if (current == null || current!.end == null) return;

    final end = current!.end!;
    final buffer = current!.buffer ?? .zero;
    final bufferIncrease = current!.bufferIncrease ?? false;

    final finalDeadline = bufferIncrease
        ? end.add(buffer)
        : end.subtract(buffer);

    warningRange = (finalDeadline.difference(.now()).inSeconds) * 0.10;
  }

  void _updateTimer() {
    if (current == null || current!.end == null) return;

    final end = current!.end!;
    final buffer = current!.buffer ?? .zero;
    final bufferIncrease = current!.bufferIncrease ?? false;

    final DateTime finalDeadline = bufferIncrease
        ? end.add(buffer)
        : end.subtract(buffer);

    remaining = finalDeadline.difference(.now());

    checkTimerState();
  }

  void checkTimerState() {
    final TimerState targetState = isOvertime
        ? .overtime
        : isWarning
        ? .warning
        : .good;

    if (state != targetState) {
      state = targetState;
      refreshGradients(isWarning, isOvertime);
    }
  }

  DateTime? previousDate({int? index}) {
    if (index == null) return schedules.lastOrNull?.end;
    if (index == 0) return null;
    return schedules[index - 1].end;
  }

  Future<void> onRefresh() async {
    isRefreshing = true;
    await getData();
    isRefreshing = false;
  }

  Future<void> getData() async {
    isLoading = true;
    errorOccurred = false;
    schedules.clear();

    try {
      final model = await service.getSchedule();

      final data = model.data ?? [];
      schedules.addAll(data);
      if (isRefreshing) refreshController.refreshCompleted();
    } catch (e) {
      errorOccurred = true;
      if (isRefreshing) refreshController.refreshFailed();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  void insertSchedule(Schedule schedule) {
    schedules.add(schedule);
    schedules.sort((a, b) => (a.start ?? .now()).compareTo(b.start ?? .now()));
    syncInsert(schedule);
  }

  Future<void> modifySchedule(Schedule modified) async {
    final index = schedules.indexWhere((s) => s.id == modified.id);
    if (index == -1) return;

    schedules[index] = modified;

    schedules.sort((a, b) => (a.start ?? .now()).compareTo(b.start ?? .now()));

    if (modified.id == current?.id) {
      await setCurrent(modified);
      syncModify(modified);
    }
  }

  bool isSchedulePast(Schedule schedule) {
    if (schedule == current) return false;
    final now = DateTime.now();
    return schedule.end == null ||
        schedule.end!.millisecondsSinceEpoch < now.millisecondsSinceEpoch;
  }
}

enum TimerState { good, warning, overtime }

enum DashboardControllerErrors { nullTime }
