// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';
import 'package:timer/features/presentation/bars/time_adjust_bar.dart';
import 'package:timer/features/presentation/controller/dashboard_controller.dart';
import 'package:timer/features/presentation/widgets/schedule_item.dart';
import 'package:timer/features/presentation/widgets/timer_card.dart';

class DashboardDesktopLayout extends StatelessWidget {
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

  const DashboardDesktopLayout({
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
      body: Column(
        children: [
          _buildDesktopAppBar(context),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const .symmetric(
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

  Widget _buildDesktopAppBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const .symmetric(horizontal: space32),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(bottom: BorderSide(color: context.cardBorderColor)),
      ),
      child: Row(
        children: [
          Text(
            appName.toUpperCase(),
            style: context.font700S22,
          ).fadeInAndMoveFromBottom(),

          const Spacer(),
          buildAddAllSwitch(context),
          horizontalSpacer16,

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

  Widget buildAddAllSwitch(BuildContext context) {
    return Center(
      child: Obx(() {
        final isShiftAll = controller.shiftAll;
        return Container(
          padding: .only(
            top: space4,
            bottom: space4,
            right: space4,
            left: space8,
          ),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            border: .all(color: context.cardBorderColor),
            borderRadius: .circular(space16),
          ),
          child: Row(
            children: [
              Text(
                'SHIFT ALL',
                style: context.font600S16.copyWith(
                  color: isShiftAll
                      ? context.themedPrimaryColor
                      : context.textColor,
                ),
              ),
              horizontalSpacer6,
              Switch.adaptive(
                value: isShiftAll,
                onChanged: (val) => controller.shiftAll = val,
                thumbColor: .all(context.textColor),
                trackColor: .resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.themedPrimaryColor;
                  }
                  return context.textColor.withValues(alpha: .2);
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
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

  Widget _buildLeftPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        TimerCard(tag: tag),
        _buildDesktopTimeAdjustControls(context),
        _buildDesktopActionControls(context),
      ],
    );
  }

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

  Widget _buildDesktopActionControls(BuildContext context) {
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

  Widget _buildDesktopScheduleHeader(BuildContext context) {
    Widget header(String text) => Padding(
      padding: const .symmetric(horizontal: space4),
      child: Text(text.toUpperCase(), style: context.font700S12),
    );

    return Padding(
      padding: const .symmetric(horizontal: space16, vertical: space12),
      child: Row(
        children: [
          Expanded(flex: 2, child: header('SCHEDULE')),
          Expanded(flex: 2, child: header('TIME')),
          Expanded(flex: 1, child: header('DURATION')),
          const SizedBox(width: 200),
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
        borderRadius: .circular(space6),
        border: .all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          _buildDesktopScheduleHeader(context),
          context.divider,

          // Items
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            separatorBuilder: (_, _) => context.divider,
            itemBuilder: (_, index) {
              final schedule = shimmer ? Schedule() : schedules![index];
              final schedulePast = controller.isSchedulePast(schedule);

              return DesktopScheduleRow(
                schedule: schedule,
                isPast: schedulePast,
                isActive: current == schedule,
                shimmer: shimmer,
                onEdit: () => openSchedule(index: index, schedule: schedule),
                onLoad: () => setCurrent(schedule),
                onAdd: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(schedule, d, b, true),
                ),
                onRemove: () => showTimeAdjuster(
                  context,
                  onApply: (d, b) => onApply(schedule, d, b, false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNoDataBody(BuildContext context) {
    return Container(
      alignment: .center,
      height: 480,
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

  Widget _buildDesktopErrorBody(BuildContext context) {
    return Container(
      alignment: .center,
      height: 480,
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
