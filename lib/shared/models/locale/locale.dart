import 'package:flutter/material.dart';

class AppLocale {
  final String rawName;

  final String translatedName;
  final Locale? locale;

  AppLocale({
    required this.rawName,
    required this.translatedName,
    required this.locale,
  });

  @override
  int get hashCode =>
      rawName.hashCode ^ translatedName.hashCode ^ locale.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocale &&
          runtimeType == other.runtimeType &&
          rawName == other.rawName &&
          locale == other.locale &&
          translatedName == other.translatedName;
}
