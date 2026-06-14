import 'package:timer/common_libs.dart';

class ContextActionModel {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  ContextActionModel({
    required this.icon,
    required this.label,
    this.color = secondaryColor,
    required this.onTap,
  });
}

class AppContextActions extends StatelessWidget {
  final List<ContextActionModel> actions;

  const AppContextActions({super.key, required this.actions});

  Widget buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: .min,
        children: [
          Container(
            padding: .all(space12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: .circular(space12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: lightColor, size: 26),
          ),
          verticalSpacer4,
          Text(label, style: context.font500S14.copyWith(color: lightColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];
      widgets.add(
        buildButton(
          icon: action.icon,
          label: action.label,
          color: action.color,
          onTap: action.onTap,
          context: context,
        ),
      );
      if (i < actions.length - 1) widgets.add(horizontalSpacer12);
    }

    return Row(mainAxisSize: .min, children: widgets);
  }
}

TutorialCoachMark createContextCoach({
  required BuildContext context,
  required GlobalKey itemKey,
  required List<ContextActionModel> actions,
}) {
  final renderBox = context.findRenderObject() as RenderBox;
  final cardPosition = renderBox.localToGlobal(.zero);

  final isNearTop = cardPosition.dy < context.screenHeight * 0.4;
  final isNearRight = cardPosition.dx > context.screenWidth * 0.5;
  final ContentAlign align = isNearTop ? .bottom : .top;

  return TutorialCoachMark(
    targets: [
      TargetFocus(
        keyTarget: itemKey,
        shape: .RRect,
        radius: space6,
        enableOverlayTab: true,
        borderSide: BorderSide(color: context.themedPrimaryColor),
        contents: [
          TargetContent(
            align: align,
            child: Align(
              alignment: isNearRight ? .centerRight : .centerLeft,
              child: AppContextActions(actions: actions),
            ),
          ),
        ],
      ),
    ],
    colorShadow: Colors.black,
    opacityShadow: context.$isDarkMode ? .5 : .3,
    hideSkip: true,
    paddingFocus: 0,
    imageFilter: .blur(sigmaX: 4, sigmaY: 4),
  );
}
