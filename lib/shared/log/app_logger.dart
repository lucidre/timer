import 'package:timer/common_libs.dart' show debugPrint;

void $log(String tag, Object? value) => AppLogger.log(tag, value);
void $error(String tag, Object? value) => AppLogger.error(tag, value);
void $warning(String tag, Object? value) => AppLogger.warning(tag, value);

class AppLogger {
  static bool enabled = true;

  static void log(String tag, Object? message) {
    if (!enabled) return;
    debugPrint('[$tag] $message');
  }

  static void error(String tag, Object? message) {
    if (!enabled) return;
    debugPrint('[ERROR][$tag] $message');
  }

  static void warning(String tag, Object? message) {
    if (!enabled) return;
    debugPrint('[WARNING][$tag] $message');
  }
}
