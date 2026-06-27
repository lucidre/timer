import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';

class ScheduleFormController extends GetxController {
  final Schedule? existing;
  final DateTime? previous;
  final bool isEditMode;

  ScheduleFormController({this.existing, this.previous})
    : isEditMode = existing != null;

  late final GlobalKey<FormState> formKey;
  late final TextEditingController nameController;

  final _startDate = DateTime.now().obs;
  final _endDate = DateTime.now().add(const Duration(minutes: 5)).obs;

  final _durationMode = true.obs;
  final _duration = const Duration(minutes: 5).obs;
  final _buffer = Duration.zero.obs;

  bool get durationMode => _durationMode.value;
  DateTime get startDate => _startDate.value;
  DateTime get endDate => _endDate.value;
  Duration get duration => _duration.value;
  Duration get buffer => _buffer.value;

  set duration(Duration value) => _duration.value = value;
  set buffer(Duration value) => _buffer.value = value;
  set durationMode(bool value) => _durationMode.value = value;
  set startDate(DateTime value) => _startDate.value = value;
  set endDate(DateTime value) => _endDate.value = value;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    _initializeForm();

    ever(_startDate, (_) => _syncEndOrDuration());
    ever(_duration, (_) {
      if (durationMode) {
        endDate = startDate.add(duration);
      }
    });
  }

  void _initializeForm() {
    if (isEditMode) {
      nameController.text = existing?.name ?? '';
      startDate = existing?.start ?? .now();
      endDate = existing?.end ?? startDate.add(const Duration(minutes: 5));
      buffer = existing?.buffer ?? .zero;
      duration = endDate.difference(startDate);
    } else {
      startDate = previous ?? .now();

      _syncEndOrDuration();
    }
  }

  void _syncEndOrDuration() {
    if (durationMode) {
      endDate = startDate.add(duration);
    } else {
      duration = endDate.difference(startDate);
    }
  }

  void snapToPreviousEndTime() {
    if (previous != null) {
      startDate = previous!;
    }
  }

  void updateStartDate(DateTime picked) {
    startDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      startDate.hour,
      startDate.minute,
    );
  }

  void updateStartTime(DateTime picked) {
    startDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      picked.hour,
      picked.minute,
    );
  }

  void updateEndDate(DateTime picked) {
    endDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      endDate.hour,
      endDate.minute,
    );
  }

  void updateEndTime(DateTime picked) {
    durationMode = false;
    endDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      picked.hour,
      picked.minute,
    );
    _syncEndOrDuration();
  }

  void setDuration(int minutes) {
    durationMode = true;
    duration = Duration(minutes: minutes);
  }

  Schedule saveSchedule() {
    final formValid = formKey.currentState?.validate() ?? false;
    if (!formValid) {
      throw ScheduleFormControllerErrors.fillAllFields;
    }

    final name = nameController.text.trim();
    final id = existing?.id ?? DateTime.now().microsecondsSinceEpoch;
    final increase = existing?.bufferIncrease ?? false;

    final result = Schedule(
      id: id,
      name: name,
      start: startDate,
      end: endDate,
      buffer: buffer,
      bufferIncrease: increase,
    );

    return result;
  }
}

enum ScheduleFormControllerErrors { fillAllFields, requestInProgress }
