import 'package:shimmer/shimmer.dart';
import 'package:timer/common_libs.dart';

class AppShimmer extends StatelessWidget {
  final bool enabled;
  final Color? shimmerColor;
  final Widget child;
  final Widget? shimmerChild;

  const AppShimmer({
    super.key,
    required this.enabled,
    required this.child,
    this.shimmerChild,
    this.shimmerColor,
  });

  @override
  Widget build(BuildContext context) {
    return enabled
        ? Shimmer.fromColors(
            baseColor:
                shimmerColor?.withValues(alpha: .9) ??
                context.textColor.withValues(alpha: 0.1),
            highlightColor:
                shimmerColor?.withValues(alpha: .4) ??
                context.textColor.withValues(alpha: 0.2),
            child: enabled ? (shimmerChild ?? child) : child,
          )
        : child;
  }
}

class ShimmerItem extends StatelessWidget {
  final double? width;
  final double? height;
  final double? radius;
  const ShimmerItem({super.key, this.width, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? space12,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(radius ?? space6),
      ),
    );
  }
}
