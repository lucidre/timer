import 'package:flutter_animate/flutter_animate.dart';
import 'package:timer/common_libs.dart';

extension WidgetAnimation on Widget {
  Widget fadeInAndMoveFromTop({
    Duration? delay,
    Duration? animationDuration,
    Offset? offset,
  }) => animate(delay: delay)
      .move(
        duration: animationDuration ?? fastDuration,
        begin: offset ?? const Offset(0, -10),
      )
      .fade(duration: animationDuration ?? fastDuration);

  Widget fadeInAndMoveFromBottom({
    Duration? delay,
    Duration? animationDuration,
    Offset? offset,
  }) => animate(delay: delay)
      .move(
        duration: animationDuration ?? fastDuration,
        begin: offset ?? const Offset(0, 10),
      )
      .fade(duration: animationDuration ?? fastDuration);

  Widget fadeInAndMoveFromRight({
    Duration? delay,
    Duration? animationDuration,
    Offset? offset,
  }) => animate(delay: delay)
      .move(
        duration: animationDuration ?? fastDuration,
        begin: offset ?? const Offset(10, 0),
      )
      .fade(duration: animationDuration ?? fastDuration);

  Widget fadeIn({Duration? delay, Duration? animationDuration, Curve? curve}) =>
      animate(delay: delay).fade(
        duration: animationDuration ?? fastDuration,
        curve: curve ?? Curves.decelerate,
      );
}
