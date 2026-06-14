// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';
import 'package:timer/features/splash/models/schedule/schedule.dart';
import 'package:timer/features/splash/presentation/bars/time_adjust_bar.dart';
import 'package:timer/features/splash/presentation/controller/dashboard_controller.dart';
import 'package:timer/features/splash/presentation/widgets/schedule_item.dart';
import 'package:timer/features/splash/presentation/widgets/timer_card.dart';

// once a schedule is created it is instantly synced across all devices on the network.

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

  Future<void> onApply(Duration duration, bool isShifting, bool isAddition) =>
      _guard(
        () => controller.applyTime(
          isAddition: isAddition,
          duration: duration,
          isShifting: isShifting,
        ),
      );

  Future<void> onPrevious() => _guard(() async {
    final passed = await controller.onPrevious();
    if (passed == true) context.showErrorSnackBar("Block time has passed.");
  });

  Future<void> onNext() => _guard(controller.onNext);

  Future<void> setCurrent(Schedule schedule) =>
      _guard(() => controller.setCurrent(schedule));

  Future<void> modifySchedule(Schedule schedule) =>
      _guard(() => controller.modifySchedule(schedule));

  @override
  Widget build(BuildContext context) {
    return context.responsiveBuilder(
      phone: _MobileLayout(
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
      desktop: _DesktopLayout(
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
    }
  }
}

// ─────────────────────────────────────────────
// MOBILE LAYOUT  (original, untouched logic)
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final String tag;
  final DashboardController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Duration, bool, bool) onApply;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final Future<void> Function(Schedule) setCurrent;
  final Future<void> Function(Schedule) modifySchedule;
  final Future<void> Function() getData;
  final void Function({Schedule? schedule, int? index}) openSchedule;

  const _MobileLayout({
    required this.tag,
    required this.controller,
    required this.onRefresh,
    required this.onApply,
    required this.onPrevious,
    required this.onNext,
    required this.setCurrent,
    required this.modifySchedule,
    required this.getData,
    required this.openSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      ignoreSafeArea: true,
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFAB(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: space16),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Obx(() {
      final isScrolling = controller.isScrolling;
      return AppFAB(
        title: 'Add Block',
        icon: Icons.add_rounded,
        isScrolling: isScrolling,
        onPressed: () => openSchedule(),
      );
    });
  }

  Column _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacer12,
        TimerCard(tag: tag),
        _buildTimeAdjustControls(context),
        _buildActionControls(context),
        _buildScheduleBody(context),
        verticalSpacer32 * 3,
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      elevation: 0,
      title: Text(
        appName.toUpperCase(),
        style: context.font700S22,
      ).fadeInAndMoveFromBottom(),
      actions: [
        _buildAvatar(context, 'JD', const Color(0xFF5B50D6)),
        _buildAvatar(context, 'MK', const Color(0xFF2E7D32), offset: true),
        _buildAvatar(context, '+3', context.textColor, offset: true),
        horizontalSpacer16,
      ],
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    String text,
    Color color, {
    bool offset = false,
    Color? textColor,
  }) {
    return Align(
      widthFactor: offset ? 0.6 : 1.0,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Text(
            text,
            style: context.font500S12.copyWith(
              color: textColor ?? lightColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ).fadeInAndMoveFromTop();
  }

  Widget _buildTimeAdjustControls(BuildContext context) {
    return Obx(() {
      final current = controller.current;
      if (current == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: space12),
        child: Row(
          children: [
            Expanded(
              child: _buildControlButton(
                context,
                '-xm',
                onPressed: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(d, b, false),
                ),
              ),
            ),
            horizontalSpacer12,
            Expanded(
              child: _buildControlButton(
                context,
                '+xm',
                onPressed: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(d, b, true),
                ),
              ),
            ),
          ],
        ).fadeInAndMoveFromTop(),
      );
    });
  }

  Widget _buildActionControls(BuildContext context) {
    return Obx(() {
      final current = controller.current;
      if (current == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: space24),
        child: Row(
          children: [
            Expanded(
              child: _buildControlButton(
                context,
                'Previous',
                icon: Icons.skip_previous_outlined,
                onPressed: onPrevious,
              ),
            ),
            horizontalSpacer12,
            Expanded(
              child: _buildControlButton(
                context,
                'Next',
                icon: Icons.skip_next_outlined,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildControlButton(
    BuildContext context,
    String text, {
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    return AppBtn.from(
      onPressed: onPressed ?? () {},
      icon: icon,
      text: text,
      bgColor: context.cardBackgroundColor,
      textColor: context.textColor,
      border: BorderSide(color: context.cardBorderColor),
    );
  }

  Widget _buildScheduleBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading)
        return _buildScheduleList(context, shimmer: true);
      if (controller.errorOccurred) return _buildErrorBody(context);
      if (controller.schedules.isEmpty) return _buildNoDataBody(context);
      return _buildScheduleList(context, schedules: controller.schedules);
    });
  }

  Widget _buildHeader(BuildContext context) {
    Widget header(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: space4),
      child: Text(text.toUpperCase(), style: context.font700S12),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: header('SCHEDULE')),
          Expanded(flex: 2, child: header('TIME')),
          Expanded(flex: 1, child: header('DUR.')),
        ],
      ),
    );
  }

  Widget _buildScheduleList(
    BuildContext context, {
    bool shimmer = false,
    List<Schedule>? schedules,
  }) {
    final itemCount = shimmer ? 8 : schedules!.length;
    final current = controller.current;
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(space6),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          context.divider,
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            separatorBuilder: (_, __) => context.divider,
            itemBuilder: (_, index) {
              final schedule = shimmer ? Schedule() : schedules![index];
              final schedulePast = controller.isSchedulePast(schedule);
              return ScheduleItem(
                schedule: schedule,
                isPast: schedulePast,
                isActive: current == schedule,
                shimmer: shimmer,
                onEdit: () => openSchedule(index: index, schedule: schedule),
                onLoad: () {
                  if (controller.isSchedulePast(schedule)) {
                    context.showErrorSnackBar("Block time has passed.");
                    return;
                  }
                  setCurrent(schedule);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataBody(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: context.height * .7,
      padding: const EdgeInsets.all(space16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(space6),
        color: context.cardBackgroundColor,
        border: Border.all(color: context.cardBorderColor),
      ),
      child: context.noDataWidget(
        description: 'Kindly add a schedule to the list.',
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: context.height * .7,
      padding: const EdgeInsets.all(space16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(space6),
        color: context.cardBackgroundColor,
        border: Border.all(color: context.cardBorderColor),
      ),
      child: context.errorWidget(onRetry: getData),
    );
  }
}

// ─────────────────────────────────────────────
// DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final String tag;
  final DashboardController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Duration, bool, bool) onApply;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final Future<void> Function(Schedule) setCurrent;
  final Future<void> Function(Schedule) modifySchedule;
  final Future<void> Function() getData;
  final void Function({Schedule? schedule, int? index}) openSchedule;

  const _DesktopLayout({
    required this.tag,
    required this.controller,
    required this.onRefresh,
    required this.onApply,
    required this.onPrevious,
    required this.onNext,
    required this.setCurrent,
    required this.modifySchedule,
    required this.getData,
    required this.openSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      ignoreSafeArea: true,
      body: Column(
        children: [
          _buildDesktopAppBar(context),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: space32,
                    vertical: space24,
                  ),
                  child: _buildDesktopBody(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Top app-bar (full-width, sticky) ──
  Widget _buildDesktopAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: space32),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(bottom: BorderSide(color: context.cardBorderColor)),
      ),
      child: Row(
        children: [
          // Brand / title
          Text(
            appName.toUpperCase(),
            style: context.font700S22,
          ).fadeInAndMoveFromBottom(),

          const Spacer(),

          // Avatars cluster
          _buildAvatar(context, 'JD', const Color(0xFF5B50D6)),
          _buildAvatar(context, 'MK', const Color(0xFF2E7D32), offset: true),
          _buildAvatar(context, '+3', context.textColor, offset: true),

          horizontalSpacer24,

          Obx(() {
            final isLoading = controller.isLoading;
            return Center(
              child: AppFAB(
                isScrolling: false,
                onPressed: isLoading ? () {} : () => openSchedule(),
                icon: Icons.add_rounded,
                title: 'Add Block',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    String text,
    Color color, {
    bool offset = false,
    Color? textColor,
  }) {
    return Align(
      widthFactor: offset ? 0.6 : 1.0,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Text(
            text,
            style: context.font500S12.copyWith(
              color: textColor ?? lightColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ).fadeInAndMoveFromTop();
  }

  /// ── Two-column master layout ──
  Widget _buildDesktopBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftPanel(context),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _buildRightPanel(context),
          ),
        ),
      ],
    );
  }

  /// Left panel: timer card, time-adjust controls, prev/next
  Widget _buildLeftPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TimerCard(tag: tag),
        _buildDesktopTimeAdjustControls(context),
        _buildDesktopActionControls(context),
      ],
    );
  }

  /// Right panel: schedule list with its own header
  Widget _buildRightPanel(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return _buildDesktopScheduleList(context, shimmer: true);
      }
      if (controller.errorOccurred) return _buildDesktopErrorBody(context);
      if (controller.schedules.isEmpty) return _buildDesktopNoDataBody(context);
      return _buildDesktopScheduleList(
        context,
        schedules: controller.schedules,
      );
    });
  }

  Widget _buildDesktopTimeAdjustControls(BuildContext context) {
    return Obx(() {
      final current = controller.current;
      if (current == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: space12),
        child: Row(
          children: [
            Expanded(
              child: _buildControlButton(
                context,
                '-xm',
                onPressed: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(d, b, false),
                ),
              ),
            ),
            horizontalSpacer12,
            Expanded(
              child: _buildControlButton(
                context,
                '+xm',
                onPressed: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(d, b, true),
                ),
              ),
            ),
          ],
        ).fadeInAndMoveFromTop(),
      );
    });
  }

  Widget _buildDesktopActionControls(BuildContext context) {
    return Obx(() {
      final current = controller.current;
      if (current == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: space24),
        child: Row(
          children: [
            Expanded(
              child: _buildControlButton(
                context,
                'Previous',
                icon: Icons.skip_previous_outlined,
                onPressed: onPrevious,
              ),
            ),
            horizontalSpacer12,
            Expanded(
              child: _buildControlButton(
                context,
                'Next',
                icon: Icons.skip_next_outlined,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildControlButton(
    BuildContext context,
    String text, {
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    return AppBtn.from(
      onPressed: onPressed ?? () {},
      icon: icon,
      text: text,
      bgColor: context.cardBackgroundColor,
      textColor: context.textColor,
      border: BorderSide(color: context.cardBorderColor),
    );
  }

  Widget _buildDesktopScheduleHeader(BuildContext context) {
    Widget header(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: space4),
      child: Text(text.toUpperCase(), style: context.font700S12),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: space16,
        vertical: space12,
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: header('SCHEDULE')),
          Expanded(flex: 2, child: header('TIME')),
          Expanded(flex: 1, child: header('DUR.')),
          // Actions column header
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildDesktopScheduleList(
    BuildContext context, {
    bool shimmer = false,
    List<Schedule>? schedules,
  }) {
    final itemCount = shimmer ? 8 : schedules!.length;
    final current = controller.current;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(space6),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // List header row
          _buildDesktopScheduleHeader(context),
          context.divider,

          // Items
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            separatorBuilder: (_, __) => context.divider,
            itemBuilder: (_, index) {
              final schedule = shimmer ? Schedule() : schedules![index];
              final schedulePast = controller.isSchedulePast(schedule);

              return DesktopScheduleRow(
                schedule: schedule,
                isPast: schedulePast,
                isActive: current == schedule,
                shimmer: shimmer,
                onEdit: () => openSchedule(index: index, schedule: schedule),
                onLoad: () {
                  if (controller.isSchedulePast(schedule)) {
                    context.showErrorSnackBar("Block time has passed.");
                    return;
                  }
                  setCurrent(schedule);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNoDataBody(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 480,
      padding: const EdgeInsets.all(space16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(space6),
        color: context.cardBackgroundColor,
        border: Border.all(color: context.cardBorderColor),
      ),
      child: context.noDataWidget(
        description: 'Kindly add a schedule to the list.',
      ),
    );
  }

  Widget _buildDesktopErrorBody(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 480,
      padding: const EdgeInsets.all(space16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(space6),
        color: context.cardBackgroundColor,
        border: Border.all(color: context.cardBorderColor),
      ),
      child: context.errorWidget(onRetry: getData),
    );
  }
}
