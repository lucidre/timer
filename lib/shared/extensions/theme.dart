import '../../../common_libs.dart';

extension DeviceTheme on BuildContext {
  // ─── Brightness ──────────────────────────────────────────────────────────────

  Brightness get _platformBrightness => MediaQuery.of(this).platformBrightness;
  bool get $isLightMode => _platformBrightness == .light;
  bool get $isDarkMode => _platformBrightness == .dark;

  // ─── Semantic Colors ─────────────────────────────────────────────────────────

  Color get themedPrimaryColor =>
      $isDarkMode ? lighterPrimaryColor : primaryColor;
  Color get textColor => $isDarkMode ? lightColor : mainTextColor;
  Color get subtitleColor => $isDarkMode ? lightColor : subtitleTextColor;
  Color get destructiveColor => $isDarkMode ? destructive300 : destructive500;
  Color get hintColor => $isDarkMode ? neutral500 : hintTextColor;
  Color get iconColor => $isDarkMode ? lightColor : primaryColor;
  Color get dividerColor => textColor.withValues(alpha: .1);

  // ─── Background Colors ───────────────────────────────────────────────────────

  Color get backgroundColor =>
      $isDarkMode ? darkBackgroundColor : lightBackgroundColor;
  Color get cardBackgroundColor =>
      $isDarkMode ? cardBackgroundDark : cardBackgroundLight;
  Color get inputBackgroundColor => cardBackgroundColor;
  Color get shimmerBaseColor => $isDarkMode ? neutral800 : neutral200;
  Color get shimmerHighlightColor => $isDarkMode ? neutral700 : neutral100;

  // ─── Border Colors ───────────────────────────────────────────────────────────

  Color get cardBorderColor => $isDarkMode ? cardBorderDark : neutral100;
  Color get inputBorderColor => cardBorderColor;
  Color get inputFocusedBorderColor => themedPrimaryColor;

  // ─── Overlay Colors ──────────────────────────────────────────────────────────

  Color get overlayColor => $isDarkMode ? scrimDark : scrim;

  Color get disabledContainerColor =>
      $isDarkMode ? neutral800 : disabledBackgroundColor;

  // ─── Widgets ─────────────────────────────────────────────────────────────────

  Widget get divider => Divider(height: 1, color: dividerColor);

  Widget get thickDivider =>
      Divider(color: dividerColor, height: 8, thickness: 8);

  InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: inputBackgroundColor,
    errorMaxLines: 5,
    contentPadding: const .all(space6),
    errorStyle: font500S12.copyWith(color: destructiveColor),
    hintStyle: font500S14.copyWith(color: textColor.withValues(alpha: 0.7)),
    labelStyle: font500S12,
    helperStyle: font500S12,
    prefixStyle: font500S12,
    suffixStyle: font500S12,
    counterStyle: font500S14,
    floatingLabelStyle: font500S12,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(space6),
      borderSide: BorderSide(color: inputBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(space6),
      borderSide: BorderSide(color: inputBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(space6),
      borderSide: BorderSide(color: inputFocusedBorderColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(space6),
      borderSide: BorderSide(width: .8, color: destructiveColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(space6),
      borderSide: BorderSide(width: .8, color: destructiveColor),
    ),
  );

  // ─── Light Theme ─────────────────────────────────────────────────────────────

  ThemeData get lightTheme {
    final base = ThemeData.light();

    final appBarTheme = AppBarTheme(
      backgroundColor: lightBackgroundColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textColor, size: 16),
    );
    final colorScheme = ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightBackgroundColor,
      error: destructiveColor,
    );
    final cardThemeData = CardThemeData(
      color: cardBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor),
      ),
    );
    final dividerThemeData = DividerThemeData(
      color: dividerColor,
      thickness: 1,
    );
    final dialogThemeData = const DialogThemeData(
      backgroundColor: neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(space12)),
      ),
    );
    final textSelectionTheme = base.textSelectionTheme.copyWith(
      cursorColor: themedPrimaryColor,
    );
    final floatingActionButtonTheme = base.floatingActionButtonTheme.copyWith(
      backgroundColor: secondaryColor,
    );

    final iconTheme = base.iconTheme.copyWith(color: textColor, size: 16);

    final textTheme = base.textTheme.copyWith(bodyLarge: font500S14);

    return ThemeData(
      appBarTheme: appBarTheme,
      scaffoldBackgroundColor: lightBackgroundColor,
      textSelectionTheme: textSelectionTheme,
      textTheme: textTheme,
      colorScheme: colorScheme,
      canvasColor: lightBackgroundColor,
      cardColor: cardBackgroundColor,
      cardTheme: cardThemeData,
      dividerTheme: dividerThemeData,
      dialogTheme: dialogThemeData,
      floatingActionButtonTheme: floatingActionButtonTheme,
      iconTheme: iconTheme,
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────────────────

  ThemeData get darkTheme {
    final base = ThemeData.dark();

    final appBarTheme = AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textColor, size: 16),
    );

    final textSelectionTheme = base.textSelectionTheme.copyWith(
      cursorColor: themedPrimaryColor,
    );

    final colorSheme = ColorScheme.fromSwatch().copyWith(
      primary: darkBackgroundColor,
      secondary: secondaryColor,
      surface: darkBackgroundColor,
      error: destructiveColor,
    );
    final cardThemeData = CardThemeData(
      color: cardBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor),
      ),
    );
    final dividerThemeData = DividerThemeData(
      color: dividerColor,
      thickness: 1,
    );
    final dialogThemeData = const DialogThemeData(
      backgroundColor: neutral800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(space12)),
      ),
    );
    final floatingActionButtonTheme = base.floatingActionButtonTheme.copyWith(
      backgroundColor: secondaryColor,
    );
    final iconTheme = ThemeData.dark().iconTheme.copyWith(
      color: textColor,
      size: 16,
    );

    final textTheme = base.textTheme.copyWith(bodyLarge: font500S14);

    return ThemeData(
      appBarTheme: appBarTheme,
      scaffoldBackgroundColor: darkBackgroundColor,
      textSelectionTheme: textSelectionTheme,
      colorScheme: colorSheme,
      canvasColor: darkBackgroundColor,
      cardColor: cardBackgroundColor,
      cardTheme: cardThemeData,
      dividerTheme: dividerThemeData,
      dialogTheme: dialogThemeData,
      textTheme: textTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      iconTheme: iconTheme,

      inputDecorationTheme: inputDecorationTheme,
    );
  }
}
