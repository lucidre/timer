import 'dart:math';
import 'package:timer/common_libs.dart';
import 'package:timer/features/presentation/controller/dashboard_controller.dart';
import 'package:timer/features/presentation/widgets/time_listener.dart';

class TimerCard extends StatefulWidget {
  final String tag;
  const TimerCard({super.key, required this.tag});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DashboardController>(tag: widget.tag);

    _ambientController = AnimationController(vsync: this, duration: 3.seconds)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final schedule = controller.current;

      if (schedule == null) return const SizedBox.shrink();

      final gradients = controller.gradients;

      return AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          final double flowValue = _ambientController.value;

          final beginAlignment = Alignment(-1.0 + flowValue, -1.0);
          final endAlignment = Alignment(1.0, 1.0 - flowValue);

          return AnimatedContainer(
            duration: medDuration,
            padding: const .all(space12),
            margin: const .only(bottom: space24),
            decoration: BoxDecoration(
              border: .all(color: gradients.first),
              gradient: LinearGradient(
                colors: gradients,
                begin: beginAlignment,
                end: endAlignment,
              ),
              borderRadius: .circular(space6),
              boxShadow: [
                BoxShadow(
                  color: gradients.last.withValues(
                    alpha: 0.15 + (flowValue * 0.25),
                  ),
                  blurRadius: 15 + (10 * flowValue),
                  spreadRadius: 2 + (4 * flowValue),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          );
        },

        child: Column(
          children: [
            buildTopItem(),
            verticalSpacer24,
            Text(
              schedule.name?.toUpperCase() ?? '',
              style: context.font700S14.copyWith(
                color: lightColor,
                letterSpacing: 1.2,
              ),
            ),
            verticalSpacer8,
            buildCountDown(),
          ],
        ),
      );
    });
  }

  FittedBox buildCountDown() {
    return FittedBox(
      fit: .scaleDown,
      child: Row(
        mainAxisSize: .min,
        children: [buildSign(), buildHours(), buildMinutes(), buildSeconds()],
      ),
    );
  }

  Obx buildSeconds() {
    return Obx(() {
      final secondsText = controller.formattedSeconds;
      if (secondsText.isEmpty) return SizedBox.shrink();
      return Row(
        crossAxisAlignment: .baseline,
        textBaseline: .alphabetic,
        children: secondsText
            .split('')
            .map(
              (char) => buildAnimatedCharacter(
                context,
                char,
                'seconds_${secondsText.indexOf(char)}',
              ),
            )
            .toList(),
      );
    });
  }

  Obx buildMinutes() {
    return Obx(() {
      final minutesText = controller.formattedMinutes;

      if (minutesText.isEmpty) return SizedBox.shrink();

      return Row(
        crossAxisAlignment: .baseline,
        textBaseline: .alphabetic,
        children: [
          ...minutesText
              .split('')
              .map(
                (char) => buildAnimatedCharacter(
                  context,
                  char,
                  'minutes_${minutesText.indexOf(char)}',
                ),
              ),

          buildSeparator(),
        ],
      );
    });
  }

  Obx buildHours() {
    return Obx(() {
      final hoursText = controller.formattedHours;
      if (hoursText.isEmpty) return SizedBox.shrink();
      return Row(
        crossAxisAlignment: .baseline,
        textBaseline: .alphabetic,
        children: [
          ...hoursText
              .split('')
              .map(
                (char) => buildAnimatedCharacter(
                  context,
                  char,
                  'hours_${hoursText.indexOf(char)}',
                ),
              ),
          buildSeparator(),
        ],
      );
    });
  }

  Obx buildSign() {
    return Obx(() {
      final signText = controller.timeSign;
      if (signText.isEmpty) return SizedBox.shrink();
      return buildAnimatedCharacter(context, signText, 'sign');
    });
  }

  Row buildTopItem() {
    final bool isOvertime = controller.isOvertime;
    final schedule = controller.current;
    final end = schedule?.end;
    final start = schedule?.start;

    return Row(
      children: [
        Icon(Icons.timer_sharp, color: lightColor, size: 16),
        horizontalSpacer4,
        CurrentTimeWidget(),
        const Spacer(),
        Icon(
          isOvertime ? Icons.error_outline : Icons.date_range_rounded,
          color: lightColor,
          size: 16,
        ),

        horizontalSpacer4,
        Text(
          '${$appUtil.formatTime(start)} – ${$appUtil.formatTime(end)}',
          style: context.font600S14.copyWith(
            color: lightColor,
            fontFamily: spaceGrotesk,
          ),
        ),
      ],
    );
  }

  Widget buildAnimatedCharacter(BuildContext context, String char, String key) {
    final bool isLabel = char == 'H' || char == 'M' || char == 'S';

    return AnimatedSwitcher(
      duration: medDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.0, 0.25), end: .zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },

      child: Text(
        char,
        key: ValueKey('${char}_$key'),
        style: context.font700S36.copyWith(
          color: lightColor,
          fontFamily: spaceGrotesk,
          fontSize: isLabel ? 50 : 90,
          fontWeight: isLabel ? .w400 : .bold,
          fontFeatures: const [.tabularFigures()],
          height: 1.1,
        ),
      ),
    );
  }

  Widget buildSeparator() {
    return Text(
      ':',
      style: context.font700S36.copyWith(
        color: lightColor,
        fontFamily: spaceGrotesk,
        fontSize: 60,
        fontFeatures: const [.tabularFigures()],
        height: 1.1,
      ),
    );
  }
}
