// ignore_for_file: use_build_context_synchronously
import 'dart:math' as math;
import 'package:timer/common_libs.dart';
import '../controller/splash_controller.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnim;
  late final Animation<int> _typingAnim;
  late final Animation<double> _bgRotateAnim;
  late final Animation<double> _bgScaleAnim;

  final tag = UniqueKey().toString();
  late final SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SplashController(), tag: tag);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _setupStaggeredAnimations();

    _controller.forward().then((_) {
      if (mounted) context.router.replace(const DeviceSetupRoute());
    });
  }

  void _setupStaggeredAnimations() {
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    _typingAnim = IntTween(begin: 0, end: appName.length).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.60, curve: Curves.linear),
      ),
    );

    _bgRotateAnim = Tween<double>(begin: 0.0, end: 0.5 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _bgScaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SplashController>(tag: tag);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      ignoreSafeArea: true,
      enableInternetBanner: false,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildBackgroundTimer(context),
                _buildTypingText(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundTimer(BuildContext context) {
    final double iconSize = ResponsiveHelper.value(
      context,
      phone: 350.0,
      tablet: 450.0,
      desktop: 580.0,
    );

    return Transform.scale(
      scale: _bgScaleAnim.value,
      child: Transform.rotate(
        angle: _bgRotateAnim.value,
        child: Icon(
          Icons.timer_outlined,
          size: iconSize,
          color: context.textColor.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildTypingText(BuildContext context) {
    final ignoreAnim = _typingAnim.value >= appName.length;
    final String typedText = appName.toUpperCase().substring(
      0,
      ignoreAnim ? appName.length : _typingAnim.value,
    );

    final double fontSize = ResponsiveHelper.value(
      context,
      phone: 80.0,
      tablet: 96.0,
      desktop: 124.0,
    );

    return Text(
      '$typedText${!ignoreAnim ? '_' : ' '}',
      style: context.font700S36.copyWith(
        fontSize: fontSize,
        color: context.themedPrimaryColor,
        height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontFamily: spaceGrotesk,
      ),
    );
  }
}
