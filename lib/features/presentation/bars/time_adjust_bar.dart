import 'package:timer/common_libs.dart';

// ─────────────────────────────────────────────────────────────
// PUBLIC HELPER — replaces the raw context.showBottomBar() call
// in DashboardScreen for both platforms.
//
// Usage (same call-site for mobile & desktop):
//   showTimeAdjuster(context, onApply: onApply);
// ─────────────────────────────────────────────────────────────
void showTimeAdjuster(
  BuildContext context, {
  required Function(Duration, bool) onApply,
}) {
  if (ResponsiveHelper.isDesktop(context)) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .45),
      builder: (_) => _DesktopAdjusterDialog(onApply: onApply),
    );
  } else {
    context.showBottomBar(child: TimeAdjusterBar(onApply: onApply));
  }
}

// ─────────────────────────────────────────────────────────────
// ORIGINAL WIDGET — completely unchanged
// ─────────────────────────────────────────────────────────────
class TimeAdjusterBar extends StatelessWidget {
  final Function(Duration, bool) onApply;

  const TimeAdjusterBar({super.key, required this.onApply});

  Widget divider(BuildContext context) => Container(
    width: 1,
    height: 90,
    color: context.textColor.withValues(alpha: .3),
  );

  @override
  Widget build(BuildContext context) {
    final hours = 0.obs;
    final mins = 0.obs;
    final secs = 0.obs;
    final cascade = false.obs;

    return Container(
      padding: const EdgeInsets.all(space16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(space6)),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: context.textColor.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(2),
            ),
          ).fadeInAndMoveFromTop(),

          Row(
            children: [
              Expanded(
                child: _TimeSpinner(label: 'HRS', max: 23, value: hours),
              ),
              divider(context),
              Expanded(
                child: _TimeSpinner(label: 'MIN', max: 59, value: mins),
              ),
              divider(context),
              Expanded(
                child: _TimeSpinner(label: 'SEC', max: 59, value: secs),
              ),
            ],
          ),

          verticalSpacer24,
          buildSwitch(cascade, context),
          verticalSpacer24,

          Obx(() {
            final empty =
                hours.value == 0 && mins.value == 0 && secs.value == 0;
            return AnimatedOpacity(
              opacity: empty ? 0.6 : 1.0,
              duration: fastDuration,
              child: AppBtn.from(
                onPressed: empty
                    ? () {}
                    : () {
                        AppHaptics.mediumImpact();
                        onApply(
                          Duration(
                            hours: hours.value,
                            minutes: mins.value,
                            seconds: secs.value,
                          ),
                          cascade.value,
                        );
                        context.pop();
                      },
                text: 'Apply',
              ),
            );
          }),
          verticalSpacer24,
        ],
      ),
    );
  }

  Row buildSwitch(RxBool cascade, BuildContext context) {
    return Row(
      children: [
        Obx(
          () => GestureDetector(
            onTap: () {
              cascade.value = !cascade.value;
              AppHaptics.selectionClick();
            },
            child: AnimatedContainer(
              duration: fastDuration,
              curve: Curves.easeInOut,
              width: 60,
              height: space32,
              padding: const EdgeInsets.all(space4 / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(space32),
                color: cascade.value
                    ? context.themedPrimaryColor
                    : context.textColor.withValues(alpha: .2),
              ),
              child: AnimatedAlign(
                duration: fastDuration,
                curve: Curves.easeInOut,
                alignment: cascade.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: context.textColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),

        horizontalSpacer12,

        Expanded(
          child: Text(
            'Shift all other blocks under by this time',
            style: context.font600S14.copyWith(letterSpacing: 0.1),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DESKTOP DIALOG WRAPPER
// Centers the adjuster content in a constrained dialog card.
// Adds a title row + explicit close button — better for mouse.
// All spinner / switch / apply logic is reused from _TimeSpinner
// and the shared helpers below (no duplication of logic).
// ─────────────────────────────────────────────────────────────
class _DesktopAdjusterDialog extends StatelessWidget {
  final Function(Duration, bool) onApply;

  const _DesktopAdjusterDialog({required this.onApply});

  Widget _divider(BuildContext context) => Container(
    width: 1,
    height: 90,
    color: context.textColor.withValues(alpha: .3),
  );

  @override
  Widget build(BuildContext context) {
    final hours = 0.obs;
    final mins = 0.obs;
    final secs = 0.obs;
    final cascade = false.obs;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(space24),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(space12),
            border: Border.all(color: context.cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .25),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title row ──────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: context.textColor.withValues(alpha: .7),
                  ),
                  horizontalSpacer8,
                  Expanded(
                    child: Text('Adjust Time', style: context.font700S16),
                  ),
                  // Close button
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: context.textColor.withValues(alpha: .5),
                      ),
                    ),
                  ),
                ],
              ),

              verticalSpacer24,

              // ── Spinners ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _TimeSpinner(label: 'HRS', max: 23, value: hours),
                  ),
                  _divider(context),
                  Expanded(
                    child: _TimeSpinner(label: 'MIN', max: 59, value: mins),
                  ),
                  _divider(context),
                  Expanded(
                    child: _TimeSpinner(label: 'SEC', max: 59, value: secs),
                  ),
                ],
              ),

              verticalSpacer24,

              // ── Cascade switch ─────────────────────────
              _buildSwitch(cascade, context),

              verticalSpacer24,

              // ── Action row: Cancel + Apply ─────────────
              Obx(() {
                final empty =
                    hours.value == 0 && mins.value == 0 && secs.value == 0;
                return Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: AppBtn.from(
                        onPressed: () => context.pop(),
                        text: 'Cancel',
                        bgColor: context.cardBackgroundColor,
                        textColor: context.textColor,
                        border: BorderSide(color: context.cardBorderColor),
                      ),
                    ),
                    horizontalSpacer12,
                    // Apply
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: empty ? 0.5 : 1.0,
                        duration: fastDuration,
                        child: AppBtn.from(
                          onPressed: empty
                              ? () {}
                              : () {
                                  AppHaptics.mediumImpact();
                                  onApply(
                                    Duration(
                                      hours: hours.value,
                                      minutes: mins.value,
                                      seconds: secs.value,
                                    ),
                                    cascade.value,
                                  );
                                  context.pop();
                                },
                          text: 'Apply',
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(RxBool cascade, BuildContext context) {
    return Row(
      children: [
        Obx(
          () => GestureDetector(
            onTap: () {
              cascade.value = !cascade.value;
              AppHaptics.selectionClick();
            },
            child: AnimatedContainer(
              duration: fastDuration,
              curve: Curves.easeInOut,
              width: 60,
              height: space32,
              padding: const EdgeInsets.all(space4 / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(space32),
                color: cascade.value
                    ? context.themedPrimaryColor
                    : context.textColor.withValues(alpha: .2),
              ),
              child: AnimatedAlign(
                duration: fastDuration,
                curve: Curves.easeInOut,
                alignment: cascade.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: context.textColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        horizontalSpacer12,
        Expanded(
          child: Text(
            'Shift all other blocks under by this time',
            style: context.font600S14.copyWith(letterSpacing: 0.1),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED — Scroll-wheel time spinner (unchanged from original)
// ─────────────────────────────────────────────────────────────
class _TimeSpinner extends StatefulWidget {
  final String label;
  final int max;
  final RxInt value;

  const _TimeSpinner({
    required this.label,
    required this.max,
    required this.value,
  });

  @override
  State<_TimeSpinner> createState() => _TimeSpinnerState();
}

class _TimeSpinnerState extends State<_TimeSpinner> {
  late final FixedExtentScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: widget.value.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: context.font600S12.copyWith(
            letterSpacing: 1.2,
            color: context.textColor.withValues(alpha: .5),
          ),
        ),
        verticalSpacer8,
        SizedBox(
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection highlight
              Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Fade top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 28,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.cardBackgroundColor.withValues(alpha: .4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Fade bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 28,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          context.cardBackgroundColor.withValues(alpha: .4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Wheel
              ListWheelScrollView.useDelegate(
                controller: _ctrl,
                itemExtent: 36,
                perspective: 0.004,
                diameterRatio: 1.6,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  widget.value.value = i;
                  AppHaptics.selectionClick();
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.max + 1,
                  builder: (context, i) {
                    return Obx(() {
                      final selected = widget.value.value == i;
                      return Center(
                        child: AnimatedDefaultTextStyle(
                          duration: fastDuration,
                          style: context.font700S16.copyWith(
                            color: selected
                                ? lightColor
                                : context.textColor.withValues(alpha: .4),
                            fontSize: selected ? 22 : 18,
                            fontFamily: spaceGrotesk,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          child: Text(i.toString().padLeft(2, '0')),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
