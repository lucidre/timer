import 'package:timer/common_libs.dart';

class AppHero extends StatelessWidget {
  const AppHero({
    super.key,
    required this.tag,
    required this.child,
    this.enableHero = true,
  });

  final Widget child;
  final bool enableHero;
  final String tag;

  @override
  Widget build(BuildContext context) => enableHero
      ? Hero(
          createRectTween: (begin, end) => RectTween(begin: begin!, end: end!),
          tag: tag,
          child: child,
        )
      : child;
}
