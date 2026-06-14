import 'package:timer/common_libs.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool skipAnim;
  const SectionHeader(this.title, {super.key, this.skipAnim = false});

  @override
  Widget build(BuildContext context) {
    return skipAnim ? body(context) : body(context).fadeInAndMoveFromBottom();
  }

  Padding body(BuildContext context) {
    return Padding(
      padding: const .only(bottom: space12, left: space4, top: space12),
      child: Text(
        title.toUpperCase(),
        style: context.font700S12.copyWith(
          color: context.textColor.withValues(
            alpha: context.$isDarkMode ? .9 : 0.8,
          ),

          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
