// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';

class ItemAndTitle extends StatelessWidget {
  const ItemAndTitle({
    super.key,
    required this.context,
    required this.title,
    required this.value,
  });

  final BuildContext context;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(title, style: context.font500S12),
        Text(value.isNotEmpty ? value : '-', style: context.font600S14),
      ],
    ).fadeInAndMoveFromBottom();
  }
}
