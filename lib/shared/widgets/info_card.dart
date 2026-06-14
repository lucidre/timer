// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.context,
    required this.title,
    required this.child,
  });

  final BuildContext context;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: .antiAliasWithSaveLayer,
      padding: const .all(space10),
      decoration: BoxDecoration(
        border: .all(
          strokeAlign: BorderSide.strokeAlignInside,
          color: context.cardBorderColor,
        ),
        color: context.cardBackgroundColor,
        borderRadius: .circular(space10),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text(title, style: context.font600S14).fadeInAndMoveFromBottom(),
          verticalSpacer10,
          context.divider,
          verticalSpacer10,
          child,
        ],
      ),
    );
  }
}
