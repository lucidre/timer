import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Returns a value based on the current breakpoint.
  /// Falls back to [tablet] for desktop if [desktop] is not provided,
  /// and falls back to [phone] for tablet if [tablet] is not provided.
  static T value<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? phone;
    if (isTablet(context)) return tablet ?? phone;
    return phone;
  }
}

extension ResponsiveBuilder on BuildContext {
  Widget responsiveBuilder({
    required Widget phone,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (ResponsiveHelper.isDesktop(this)) return desktop ?? tablet ?? phone;
    if (ResponsiveHelper.isTablet(this)) return tablet ?? phone;
    return phone;
  }
}
