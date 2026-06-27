import 'package:timer/common_libs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _preference;

  static Future init() async =>
      _preference = await SharedPreferences.getInstance();

  // ── Keys ──────────────────────────────────────────────────────────────────

  static const _onBoardingKey = 'onBoardingStatus';
  static const _deviceNameKey = 'device_name';
  static const _deviceIdKey = 'device_id';
  static const _deviceIpKey = 'device_ip';
  static const _deviceLastSeen = 'device_last_seen';
  static const _shiftAll = 'shift_all';

  // ── Setters ───────────────────────────────────────────────────────────────

  static Future setOnBoardingStatus({required bool status}) async =>
      await _preference?.setBool(_onBoardingKey, status);

  static Future setDeviceName(String value) async =>
      await _preference?.setString(_deviceNameKey, value);

  static Future setDeviceId(String value) async =>
      await _preference?.setString(_deviceIdKey, value);

  static Future setDeviceIp(String value) async =>
      await _preference?.setString(_deviceIpKey, value);

  static Future setShiftAll(bool value) async =>
      await _preference?.setBool(_shiftAll, value);

  static Future setDeviceLastSeen(DateTime value) async =>
      await _preference?.setInt(_deviceLastSeen, value.millisecondsSinceEpoch);

  // ── Getters ───────────────────────────────────────────────────────────────

  static bool get onBoardingStatus =>
      _preference?.getBool(_onBoardingKey) ?? false;
  static String get deviceName => _preference?.getString(_deviceNameKey) ?? '';
  static String get deviceId => _preference?.getString(_deviceIdKey) ?? '';
  static String get deviceIp => _preference?.getString(_deviceIpKey) ?? '';
  static bool get shiftAll => _preference?.getBool(_shiftAll) ?? true;
  static DateTime? get deviceLastSeen {
    final ms = _preference?.getInt(_deviceLastSeen);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }
}
