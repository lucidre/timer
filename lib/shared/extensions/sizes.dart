import 'package:timer/common_libs.dart';

extension DeviceDetails on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);
  Size get _size => _mediaQuery.size;
  double get bottom => _mediaQuery.viewInsets.bottom;
  double get top => _mediaQuery.padding.top;
  double get screenHeight => _size.height;
  double get screenWidth => _size.width;
  double get topPadding => _mediaQuery.padding.top;
  TextScaler get textScaler => MediaQuery.of(this).textScaler;

  Theme dateTheme(Widget child) {
    final theme = Theme.of(this);
    final data = theme.copyWith(
      colorScheme: $isDarkMode
          ? .dark(
              primary: themedPrimaryColor,
              secondary: themedPrimaryColor,
              onSecondary: lightColor,
              onPrimary: lightColor,
            )
          : .light(
              primary: themedPrimaryColor,
              secondary: themedPrimaryColor,
              onPrimary: lightColor,
              onSecondary: lightColor,
            ),
    );
    return Theme(data: data, child: child);
  }

  void unfocus() => FocusScope.of(this).requestFocus(FocusNode());

  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);
}
