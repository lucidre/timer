import 'package:flutter/material.dart';
import 'package:timer/shared/constants/colors.dart';
import 'package:timer/shared/constants/numbers.dart';
import 'package:timer/shared/constants/spacers.dart';
import 'package:timer/shared/extensions/font.dart';
import 'package:timer/shared/widgets/app_haptics.dart';

import '../constants/duration.dart';

class AppFAB extends StatelessWidget {
  final bool isScrolling;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? title;
  final Color? bgColor;
  const AppFAB({
    super.key,
    required this.isScrolling,
    required this.onPressed,
    this.icon,
    this.title,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: fastDuration,
      curve: Curves.easeInOut,
      offset: isScrolling ? const Offset(0, 1) : Offset.zero,
      child: AnimatedOpacity(
        duration: fastDuration,
        opacity: isScrolling ? 0.0 : 1.0,
        child: InkWell(
          borderRadius: .circular(space16),
          onTap: () {
            AppHaptics.mediumImpact();
            onPressed();
          },
          child: Container(
            padding: const .all(space4),
            decoration: BoxDecoration(
              color: (bgColor ?? primaryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(space16),
              border: .all(
                color: (bgColor ?? primaryColor).withValues(alpha: 0.2),
              ),
            ),
            child: Container(
              padding: const .symmetric(horizontal: space16, vertical: space12),
              decoration: BoxDecoration(
                color: (bgColor ?? primaryColor),
                borderRadius: .circular(space12),
                boxShadow: [
                  BoxShadow(
                    color: (bgColor ?? primaryColor).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: .min,
                children: [
                  if (icon != null) Icon(icon, color: lightColor, size: 22),
                  if (title != null && icon != null) horizontalSpacer8,
                  if (title != null)
                    Text(
                      title!,
                      style: context.font700S14.copyWith(color: lightColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
