import 'package:timer/features/splash/models/schedule/schedules.dart';
import 'package:timer/shared/api/network_methods.dart';
import 'package:timer/shared/api/network_response.dart';

class SplashDataSource {
  Future<Schedules> getSchedule() async {
    await Future.delayed(Duration(seconds: 3));
    return .new(data: []);
  }

  Future<NetworkResponse> _send({
    required String host,
    required String path,
  }) async => await $get(path, host: host);

  Future<void> start(String host) async {
    final response = await _send(host: host, path: '/start');
    if (response.isError) {
      throw response.data['msg'] ?? '';
    }
  }

  Future<void> reset(String host) async {
    final response = await _send(host: host, path: '/reset');
    if (response.isError) {
      throw response.data['msg'] ?? '';
    }
  }

  Future<void> sendTimerSettings({
    required String host,
    required int hours,
    required int minutes,
    required int seconds,
    required int warningPercent,
  }) async {
    final response = await _send(
      host: host,
      path: '/hour=$hours&minute=$minutes&second=$seconds&warn=$warningPercent',
    );
    if (response.isError) {
      throw response.data['msg'] ?? '';
    }
  }

  Future<void> pushAndStart({
    required String host,
    required DateTime startDate,
    required DateTime endDate,
    int warningPercent = 10,
  }) async {
    final duration = endDate.difference(startDate);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    await sendTimerSettings(
      host: host,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      warningPercent: warningPercent,
    );

    await start(host);
  }

  Future<void> syncTime(String host) async {
    final now = DateTime.now();
    final payload =
        'TIME_AUTO:'
        '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}'
        ':${_pad(now.day)}:${_pad(now.month)}'
        ':${(now.year % 100).toString().padLeft(2, '0')}';
    final response = await _send(host: host, path: '/$payload');

    if (response.isError) {
      throw response.data['msg'] ?? '';
    }
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}
