import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';

class ScheduleItem extends StatefulWidget {
  final Schedule schedule;
  final bool isActive;
  final bool isPast;
  final bool shimmer;
  final VoidCallback onEdit;
  final VoidCallback onLoad;

  const ScheduleItem({
    super.key,
    required this.schedule,
    this.isActive = false,
    this.isPast = false,
    this.shimmer = false,
    required this.onEdit,
    required this.onLoad,
  });

  @override
  State<ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<ScheduleItem> {
  final itemKey = GlobalKey();

  void _showContextMenu() {
    AppHaptics.mediumImpact();

    late final TutorialCoachMark coach;

    coach = createContextCoach(
      context: context,
      itemKey: itemKey,
      actions: [
        ContextActionModel(
          icon: Icons.edit_rounded,
          label: 'Edit',
          onTap: () {
            coach.skip();
            widget.onEdit.call();
          },
        ),
        ContextActionModel(
          icon: Icons.play_arrow_rounded,
          label: 'Start',
          onTap: () {
            coach.skip();
            widget.onLoad.call();
          },
        ),
        ContextActionModel(
          icon: Icons.add_rounded,
          label: 'Add X',
          onTap: () {
            coach.skip();
            // widget.onLoad.call();
          },
        ),
        ContextActionModel(
          icon: Icons.remove_rounded,
          label: 'Remove X',
          onTap: () {
            coach.skip();
            // widget.onLoad.call();
          },
        ),
      ],
    );

    coach.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: itemKey,
      color: widget.isActive ? primaryColor : null,

      child: InkWell(
        onTap: widget.shimmer ? null : _showContextMenu,
        child: Padding(
          padding: const .symmetric(horizontal: space16, vertical: space20),
          child: AppShimmer(
            enabled: widget.shimmer,
            child: widget.shimmer ? buildShimmerItem() : buildBody(context),
          ).fadeInAndMoveFromBottom(),
        ),
      ),
    );
  }

  Widget buildShimmerItem() {
    return Row(
      children: [
        buildSpacer(flex: 2, child: ShimmerItem()),
        buildSpacer(flex: 2, child: ShimmerItem()),
        buildSpacer(flex: 1, child: ShimmerItem()),
        // buildSpacer(flex: 1, child: ShimmerItem()),
      ],
    );
  }

  Widget buildSpacer({
    required int flex,
    required Widget child,
    bool ignoreSpace = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const .symmetric(horizontal: space4),
        child: widget.shimmer || ignoreSpace
            ? child
            : FittedBox(fit: .scaleDown, alignment: .centerLeft, child: child),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final textColor = widget.isActive
        ? lightColor
        : context.textColor.withValues(alpha: widget.isPast ? .5 : 1);

    /*     final increase = widget.schedule.bufferIncrease ?? false;
    final bufferColor = widget.isActive
        ? (increase ? success300 : destructive300)
        : (increase ? success700 : destructive700); */

    final end = widget.schedule.end;
    final start = widget.schedule.start;

    // final buffer = widget.schedule.buffer;
    return Row(
      crossAxisAlignment: .start,
      children: [
        buildSpacer(
          flex: 2,
          ignoreSpace: true,
          child: Text(
            widget.schedule.name ?? '',
            maxLines: 1,
            overflow: .ellipsis,
            style: context.font600S14.copyWith(
              color: textColor,
              fontWeight: widget.isActive ? .bold : null,
            ),
          ),
        ),
        buildSpacer(
          flex: 2,
          child: Text(
            '${$appUtil.formatTime(start)} – ${$appUtil.formatTime(end)}',
            style: context.font500S14.copyWith(
              color: textColor,
              fontFamily: spaceGrotesk,
              fontWeight: widget.isActive ? .bold : null,
            ),
          ),
        ),
        buildSpacer(
          flex: 1,
          child: Text(
            $appUtil.formatTimeDifference(start, end),
            style: context.font500S14.copyWith(
              color: textColor,
              fontFamily: spaceGrotesk,
              fontWeight: widget.isActive ? .bold : null,
            ),
          ),
        ),
        /*         buildSpacer(
          flex: 1,
          child: Text(
            buffer == null || buffer.inSeconds == 0
                ? ''
                : (increase ? '+' : '-') + $appUtil.formatDuration(buffer),
            style: context.font500S14.copyWith(
              color: bufferColor,
              fontFamily: spaceGrotesk,
              fontWeight: widget.isActive ? .bold : null,
            ),
          ),
        ), */
      ],
    );
  }
}

class DesktopScheduleRow extends StatefulWidget {
  final Schedule schedule;
  final bool isActive;
  final bool isPast;
  final bool shimmer;
  final VoidCallback onEdit;
  final VoidCallback onLoad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const DesktopScheduleRow({
    super.key,
    required this.schedule,
    this.isActive = false,
    this.isPast = false,
    this.shimmer = false,
    required this.onEdit,
    required this.onLoad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<DesktopScheduleRow> createState() => _DesktopScheduleRowState();
}

class _DesktopScheduleRowState extends State<DesktopScheduleRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color rowBg = widget.isActive
        ? primaryColor
        : _hovered
        ? context.cardBorderColor.withValues(alpha: 0.35)
        : Colors.transparent;

    final textColor = widget.isActive
        ? lightColor
        : context.textColor.withValues(alpha: widget.isPast ? .5 : 1);

    final end = widget.schedule.end;
    final start = widget.schedule.start;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: rowBg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: space16,
            vertical: space16,
          ),
          child: widget.shimmer
              ? AppShimmer(enabled: true, child: _buildShimmerRow())
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Schedule name
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: space4),
                        child: Text(
                          widget.schedule.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.font600S14.copyWith(
                            color: textColor,
                            fontWeight: widget.isActive
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ),
                    ),
                    // Time range
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: space4),
                        child: Text(
                          '${$appUtil.formatTime(start)} – ${$appUtil.formatTime(end)}',
                          style: context.font500S14.copyWith(
                            color: textColor,
                            fontFamily: spaceGrotesk,
                            fontWeight: widget.isActive
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ),
                    ),
                    // Duration
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: space4),
                        child: Text(
                          $appUtil.formatTimeDifference(start, end),
                          style: context.font500S14.copyWith(
                            color: textColor,
                            fontFamily: spaceGrotesk,
                            fontWeight: widget.isActive
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ),
                    ),
                    // Inline action buttons (desktop-only)
                    AnimatedOpacity(
                      opacity: (_hovered || widget.isActive) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: SizedBox(
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildControlButton(
                              context,
                              '-xm',
                              onPressed: () => widget.onRemove(),
                            ),
                            horizontalSpacer6,
                            _buildControlButton(
                              context,
                              '+xm',
                              onPressed: () => widget.onAdd(),
                            ),
                            horizontalSpacer6,
                            _ActionIconBtn(
                              icon: Icons.edit_rounded,
                              tooltip: 'Edit',
                              color: widget.isActive
                                  ? lightColor
                                  : context.textColor,
                              onPressed: widget.onEdit,
                            ),
                            horizontalSpacer8,
                            _ActionIconBtn(
                              icon: Icons.play_arrow_rounded,
                              tooltip: 'Start',
                              color: widget.isActive
                                  ? lightColor
                                  : primaryColor,
                              onPressed: widget.onLoad,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    String text, {
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: .circular(space6),
      child: Padding(
        padding: const .all(space6),
        child: Text(text, style: context.font600S14),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Row(
      children: [
        Expanded(flex: 2, child: ShimmerItem()),
        horizontalSpacer8,
        Expanded(flex: 2, child: ShimmerItem()),
        horizontalSpacer8,
        Expanded(flex: 1, child: ShimmerItem()),
        const SizedBox(width: 80),
      ],
    );
  }
}

/// Small icon button used in desktop schedule rows
class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
