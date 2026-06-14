import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timer/common_libs.dart';
import 'package:intl/intl.dart';

// ─── Global Instance ─────────────────────────────────────────────────────────

final $appUtil = AppUtils();

// ─── App Utils ────────────────────────────────────────────────────────────────

class AppUtils {
  // ─── Config ─────────────────────────────────────────────────────────────────

  String get mapKey =>
      dotenv.env[Platform.isIOS ? 'iosMapKey' : 'androidMapKey'] ?? '';

  // ─── Validation ──────────────────────────────────────────────────────────────

  bool isEmailValid(String? v) => RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@+[a-zA-Z0-9]+\.[a-zA-Z]",
  ).hasMatch(v ?? '');

  bool isNameValid(String? v) =>
      RegExp(r'^[a-zA-Z\-]{2,70}$').hasMatch(v ?? '');

  bool isUsernameValid(String? v) =>
      RegExp(r'^[a-zA-Z0-9\-\_]{2,70}$').hasMatch(v ?? '');

  bool isPhoneValid(String? v) =>
      RegExp(r'^[+]{0,1}[0-9]{6,19}$').hasMatch(v ?? '');

  bool isZipCodeValid(String? v) =>
      RegExp(r'^[a-zA-Z0-9\- ]{3,15}$').hasMatch(v ?? '');

  bool isTagValid(String? v) =>
      RegExp(r'^[a-zA-Z0-9\-_()#.,\/ ]{2,255}$').hasMatch(v ?? '');

  bool isAddressValid(String? v) =>
      RegExp(r'^[a-zA-Z0-9\-_()#.,\/ ]{2,100}$').hasMatch(v ?? '');

  // ─── Number ────────────────────────────────────────────────────────────────

  String simplifyNumber(int number) {
    if (number >= 1000000) {
      final value = number / 1000000;
      return '${_format(value)}M';
    } else if (number >= 1000) {
      final value = number / 1000;
      return '${_format(value)}k';
    }
    return number.toString();
  }

  String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  // ─── Currency ────────────────────────────────────────────────────────────────

  String formatCurrency(String currency, double? price) {
    final formatted = NumberFormat('#,##0.00', 'en_US').format(price ?? 0.0);
    return currency.length == 1
        ? '$currency$formatted'
        : '$currency $formatted';
  }

  // ─── Date Formatting ─────────────────────────────────────────────────────────

  /// Jan 01, 2024
  String formatDate(DateTime? date) =>
      date != null ? DateFormat('MMM dd, yyyy').format(date) : '';

  /// January 01, 2024
  String formatDateFull(DateTime? date) =>
      date != null ? DateFormat('MMMM dd, yyyy').format(date) : '';

  /// 12:00 PM
  String formatTimeDifference(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '00:00:00';

    final Duration difference = end.difference(start).abs();

    final String hours = difference.inHours == 0
        ? ''
        : difference.inHours.toString().padLeft(2, '0');
    final String minutes = (difference.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final String seconds = (difference.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );

    return '${hours.isEmpty ? '' : '${hours}h:'}${minutes}m:${seconds}s';
  }

  /// 12:00 PM
  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00:00';

    final String hours = duration.inHours == 0
        ? ''
        : duration.inHours.toString().padLeft(2, '0');
    final String minutes = (duration.inMinutes % 60).toString().padLeft(1, '0');
    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '${hours.isEmpty ? '' : '${hours}h:'}${minutes}m:${seconds}s';
  }

  /// 12:00 PM
  String formatTime(DateTime? date) =>
      date != null ? DateFormat('h:mm a').format(date) : '';

  /// 12:00 PM; Jan 01, 2024
  String formatDateWithTime(DateTime? date) =>
      date != null ? DateFormat('h:mm a, MMM dd, yyyy').format(date) : '';

  String formatTimeMajorly(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      // For older notifications, show the absolute time
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// 01/01/2024
  String formatDateSlashed(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  /// 2024-01-01
  String formatDateHyphened(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  /// 2024-01-01 12:00:00
  String formatDateHyphenedWithTime(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

  /// 12:00:00
  String formatTimeOnly(DateTime date) => DateFormat('hh:mm:ss a').format(date);

  /// 01 Jan, 2024
  String formatDateFromString(String? date) {
    if (date == null) return '';
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(date));
    } catch (_) {
      return '';
    }
  }

  /// Jan 01, 2024 from millisecond timestamp
  String formatDateFromTimestamp(int timestamp) {
    try {
      return DateFormat(
        'MMM dd, yyyy',
      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
    } catch (_) {
      return '';
    }
  }

  /// Shows time if today, date otherwise
  String formatSmart(DateTime? date) {
    if (date == null) return '';
    return _isToday(date)
        ? DateFormat('h:mm a').format(date)
        : DateFormat('MMM dd, yyyy').format(date);
  }

  /// Shows time if today, dd/MM/yyyy otherwise — for chat
  String formatChat(DateTime? date) {
    if (date == null) return '';
    return _isToday(date)
        ? DateFormat('h:mm a').format(date)
        : DateFormat('dd/MM/yyyy').format(date);
  }

  /// January — from timestamp
  String monthFromTimestamp(int timestamp) {
    try {
      return DateFormat(
        'MMMM',
      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
    } catch (_) {
      return 'January';
    }
  }

  /// 2024 — from timestamp
  String yearFromTimestamp(int timestamp) {
    try {
      return DateFormat(
        'yyyy',
      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
    } catch (_) {
      return DateTime.now().year.toString();
    }
  }

  /// January 01, 2024 — from day/month/year strings
  String formatFullDateFromParts(String d, String m, String year) {
    try {
      final day = d.trim().padLeft(2, '0');
      final month = m.trim().padLeft(2, '0');
      return DateFormat(
        'MMMM dd, yyyy',
      ).format(DateTime.parse('$year-$month-$day'));
    } catch (_) {
      return '';
    }
  }

  // ─── Date + Time Combination ─────────────────────────────────────────────────

  /// Combines a date and time into yyyy-MM-dd HH:mm:ss
  String combineDateAndTime(DateTime date, TimeOfDay time) =>
      formatDateHyphenedWithTime(_combine(date, time));

  /// Combines a date and time into h:mm a; MMM dd, yyyy
  String combineDateAndTimeReadable(DateTime date, TimeOfDay time) =>
      formatDateWithTime(_combine(date, time));

  // ─── Parsing ─────────────────────────────────────────────────────────────────

  DateTime? parseHyphenedDate(String date) =>
      DateFormat('yyyy-MM-dd').tryParse(date);

  DateTime? parseTime(String time) => DateFormat('h:mm a').tryParse(time);

  // ─── Private Helpers ─────────────────────────────────────────────────────────

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
