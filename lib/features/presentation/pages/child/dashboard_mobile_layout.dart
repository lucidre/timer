// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';
import 'package:timer/features/presentation/bars/time_adjust_bar.dart';
import 'package:timer/features/presentation/controller/dashboard_controller.dart';
import 'package:timer/features/presentation/widgets/schedule_item.dart';
import 'package:timer/features/presentation/widgets/timer_card.dart';

class DashboardMobileLayout extends StatelessWidget {
  final String tag;
  final DashboardController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Schedule, Duration, bool, bool) onApply;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final Future<void> Function(Schedule) setCurrent;
  final Future<void> Function(Schedule) modifySchedule;
  final Future<void> Function() getData;
  final void Function({Schedule? schedule, int? index}) openSchedule;

  const DashboardMobileLayout({
    super.key,
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
        padding: const .symmetric(horizontal: space16),
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
      crossAxisAlignment: .start,
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
    );
  }

  Widget _buildTimeAdjustControls(BuildContext context) {
    return Obx(() {
      final current = controller.current;
      if (current == null) return const SizedBox.shrink();
      return Padding(
        padding: const .only(bottom: space12),
        child: Row(
          children: [
            Expanded(
              child: _buildControlButton(
                context,
                '-xm',
                onPressed: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(current, d, b, false),
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
                  onApply: (d, b) => onApply(current, d, b, true),
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
        padding: const .only(bottom: space24),
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
      if (controller.isLoading) {
        return _buildScheduleList(context, shimmer: true);
      }
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
      padding: const .all(space16),
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
        borderRadius: .circular(space6),
        border: .all(color: context.cardBorderColor),
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
            separatorBuilder: (_, _) => context.divider,
            itemBuilder: (_, index) {
              final schedule = shimmer ? Schedule() : schedules![index];
              final schedulePast = controller.isSchedulePast(schedule);
              return ScheduleItem(
                schedule: schedule,
                isPast: schedulePast,
                isActive: current == schedule,
                shimmer: shimmer,
                onEdit: () => openSchedule(index: index, schedule: schedule),
                onLoad: () => setCurrent(schedule),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataBody(BuildContext context) {
    return Container(
      alignment: .center,
      height: context.height * .7,
      padding: const .all(space16),
      decoration: BoxDecoration(
        borderRadius: .circular(space6),
        color: context.cardBackgroundColor,
        border: .all(color: context.cardBorderColor),
      ),
      child: context.noDataWidget(
        description: 'Kindly add a schedule to the list.',
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context) {
    return Container(
      alignment: .center,
      height: context.height * .7,
      padding: const .all(space16),
      decoration: BoxDecoration(
        borderRadius: .circular(space6),
        color: context.cardBackgroundColor,
        border: .all(color: context.cardBorderColor),
      ),
      child: context.errorWidget(onRetry: getData),
    );
  }
}
