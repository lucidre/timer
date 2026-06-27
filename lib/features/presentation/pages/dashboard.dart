// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';
import 'package:timer/features/presentation/controller/dashboard_controller.dart';
import 'package:timer/features/presentation/pages/child/dashboard_desktop_layout.dart';
import 'package:timer/features/presentation/pages/child/dashboard_mobile_layout.dart';
import 'package:timer/features/presentation/pages/schedule_form.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final tag = UniqueKey().toString();
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(.new(), tag: tag);
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
  }

  @override
  void dispose() {
    Get.delete<DashboardController>(tag: tag);
    super.dispose();
  }

  Future<void> getData() async {
    try {
      await controller.getData();
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (e) {
      AppLogger.error('dashboard', e.toString());
      context.showErrorSnackBar('An error occurred, please retry.');
    }
  }

  Future<void> onRefresh() async {
    try {
      await controller.onRefresh();
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (e) {
      context.showErrorSnackBar('An error occurred, please retry.');
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on DashboardControllerErrors catch (e) {
      if (e == DashboardControllerErrors.nullTime) {
        context.showErrorSnackBar('Time is null please restart block.');
      }
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (_) {
      context.showErrorSnackBar('An error occurred pushing to timer.');
    }
  }

  Future<void> onApply(
    Schedule schedule,
    Duration duration,
    bool isShifting,
    bool isAddition,
  ) => _guard(
    () => controller.applyTime(
      schedule: schedule,
      isAddition: isAddition,
      duration: duration,
      isShifting: isShifting,
    ),
  );

  Future<void> onPrevious() => _guard(controller.onPrevious);

  Future<void> onNext() => _guard(controller.onNext);

  Future<void> setCurrent(Schedule schedule) =>
      _guard(() => controller.setCurrent(schedule));

  Future<void> modifySchedule(Schedule schedule) =>
      _guard(() => controller.modifySchedule(schedule));

  @override
  Widget build(BuildContext context) {
    return context.responsiveBuilder(
      phone: DashboardMobileLayout(
        tag: tag,
        controller: controller,
        onRefresh: onRefresh,
        onApply: onApply,
        onPrevious: onPrevious,
        onNext: onNext,
        setCurrent: setCurrent,
        modifySchedule: modifySchedule,
        getData: getData,
        openSchedule: openSchedule,
      ),
      desktop: DashboardDesktopLayout(
        tag: tag,
        controller: controller,
        onRefresh: onRefresh,
        onApply: onApply,
        onPrevious: onPrevious,
        onNext: onNext,
        setCurrent: setCurrent,
        modifySchedule: modifySchedule,
        getData: getData,
        openSchedule: openSchedule,
      ),
    );
  }

  void openSchedule({Schedule? schedule, int? index}) async {
    final result = await context.pushRoute(
      ScheduleFormRoute(
        schedule: schedule,
        previousEndTime: controller.previousDate(index: index),
      ),
    );

    if (result is Schedule) {
      if (schedule == null) {
        controller.insertSchedule(result);
      } else {
        modifySchedule(result);
      }
    } else if (result == scheduleFormScreenDelete) {
      controller.deleteSchedule(schedule);
    }
  }
}
