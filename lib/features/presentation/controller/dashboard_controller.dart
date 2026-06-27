import 'package:timer/common_libs.dart';
import 'package:timer/features/data/data_sources/schedule_sync.dart';
import 'package:timer/features/data/repositorites/splash_repository_impl.dart';
import 'package:timer/features/domain/usecases/splash_service.dart';
import 'package:timer/features/models/schedule/schedule.dart';

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
  final _shiftAll = true.obs;
  final _errorOccurred = false.obs;
  final _isScrolling = false.obs;

  Timer? _ticker;
  Timer? _scrollTimer;
  late final RefreshController refreshController;
  late final ScrollController scrollController;

  // Getters

  List<Color> get gradients => _gradients;
  bool get shiftAll => _shiftAll.value;
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
  set shiftAll(bool value) {
    _shiftAll.value = value;
    AppPreferences.setShiftAll(value);
  }

  set errorOccurred(bool value) => _errorOccurred.value = value;
  set isRefreshing(bool value) => _isRefreshing.value = value;
  set gradients(List<Color> value) => _gradients.value = value;
  set state(TimerState value) => _state.value = value;
  set warningRange(double value) => _warningRange.value = value;
  set remaining(Duration value) => _remaining.value = value;
  set isScrolling(bool value) => _isScrolling.value = value;

  Future<void> startSchedule(Schedule schedule) async {
    if (shiftAll) {
      await resolveTimeDifferent(schedule);
    }
    final sched = schedules.firstWhereOrNull((s) => s.id == schedule.id);
    await setCurrent(sched ?? schedule);
  }

  Future<void> setCurrent(Schedule schedule) async {
    _current.value = schedule;
    startCountdown();
    await pushToTimer();
  }

  Future<void> onNext() async {
    if (current == null) return;
    final indexOf = schedules.indexOf(current!);
    if (indexOf != -1 && indexOf != schedules.length - 1) {
      await startSchedule(schedules[indexOf + 1]);
    }
  }

  Future<void> resolveTimeDifferent(Schedule schedule) async {
    if (current == null) return;

    final now = DateTime.now();
    final currentEnd = current?.end ?? now;
    final newStart = schedule.start ?? now;

    final overflowTime = now.isAfter(currentEnd)
        ? now.difference(currentEnd)
        : Duration.zero;

    if (overflowTime == Duration.zero) return;

    final gapDifference = newStart.isAfter(currentEnd)
        ? newStart.difference(currentEnd)
        : Duration.zero;

    if (gapDifference >= overflowTime) return;

    final additionMs =
        overflowTime.inMilliseconds - gapDifference.inMilliseconds;

    final fromIndex = schedules.indexOf(schedule);
    if (fromIndex == -1) return;

    for (int i = fromIndex; i < schedules.length; i++) {
      final block = schedules[i];
      if (block.start == null || block.end == null) continue;
      schedules[i] = block.copyWith(
        start: block.start!.add(Duration(milliseconds: additionMs)),
        end: block.end!.add(Duration(milliseconds: additionMs)),
      );
    }
  }

  Future<void> applyTime({
    required bool isAddition,
    required Duration duration,
    required bool isShifting,
    required Schedule schedule,
  }) async {
    bool isCurrent = schedule == current;
    //TODO: APPLU PLUS ON A TIME THAT IS ALREADY 5 SECONDS IS NOT WORKING. SO REMOVE LIKE AN HOUR AND ADD AND IT WOUDL NOT WORK.

    final fromIndex = schedules.indexOf(schedule);
    if (fromIndex == -1) return;

    final blockStart = schedule.start;
    final blockEnd = schedule.end;
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

    debugPrint(resolved.toString());
    final updatedEnd = isAddition
        ? blockEnd.add(resolved)
        : blockEnd.subtract(resolved);

    schedules[fromIndex] = schedule.copyWith(end: updatedEnd);
    if (isCurrent) {
      _current.value = schedules[fromIndex];
    }

    if (!isShifting || resolved == .zero) {
      if (isCurrent) {
        await setCurrent(schedules[fromIndex]);
      }
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

    if (isCurrent) {
      await setCurrent(schedules[fromIndex]);
    }
  }

  Future<void> onPrevious() async {
    if (current == null) return;

    final indexOf = schedules.indexOf(current!);
    if (indexOf != -1 && indexOf - 1 <= 0) {
      final item = schedules[indexOf - 1];
      setCurrent(item);
    }
  }

  @override
  void onInit() {
    super.onInit();
    initSync();
    scrollController = ScrollController();
    refreshController = RefreshController(initialRefresh: false);
    refreshGradients(false, false);
    scrollController.addListener(onScroll);

    shiftAll = AppPreferences.shiftAll;
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
    final start = blockStart.isBefore(.now()) ? DateTime.now() : blockStart;
    await service.pushAndStart(
      host: 'http://${AppPreferences.deviceIp}',
      startDate: start,
      endDate: blockEnd.isBefore(start) ? .now().add(2.seconds) : blockEnd,
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

    final finalDeadline = bufferIncrease
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

  @override
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

  void deleteSchedule(Schedule? schedule) {
    if (schedule == null) return;
    schedules.remove(schedule);
    schedules.sort((a, b) => (a.start ?? .now()).compareTo(b.start ?? .now()));
    syncDelete(schedule.id ?? -1);
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
