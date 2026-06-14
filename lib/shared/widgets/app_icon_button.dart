import 'package:timer/common_libs.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool ignoreTap;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? color;
  const AppIconButton({
    super.key,
    this.onPressed,
    this.ignoreTap = false,
    this.icon,
    this.iconWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer(
        ignoring: ignoreTap,
        child: IconButton(
          onPressed: () => onPressed?.call(),
          padding: .zero,
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            backgroundColor: context.cardBackgroundColor,
            side: BorderSide(color: context.cardBorderColor),
            shape: RoundedRectangleBorder(borderRadius: .circular(space16)),
            fixedSize: const Size(35, 35),
          ),
          icon:
              iconWidget ??
              Icon(icon, color: color ?? context.textColor, size: 18),
        ),
      ).fadeInAndMoveFromTop(),
    );
  }
}

class AppGlassIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const AppGlassIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: const .all(space6),
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        backgroundColor: lightColor.withValues(alpha: .3),
        side: BorderSide(color: lightColor.withValues(alpha: .7)),
        shape: RoundedRectangleBorder(borderRadius: .circular(space16)),
        fixedSize: const Size(35, 35),
      ),
      icon: Icon(icon, color: iconColor ?? lightColor, size: 18),
    ).fadeInAndMoveFromTop();
  }
}
