import 'package:timer/features/models/schedule/schedules.dart';

import '../repositories/splash_repository.dart';

class SplashService {
  final SplashRepository repository;

  SplashService(this.repository);

  Future<Schedules> getSchedule() => repository.getSchedule();
  Future<void> start(String host) => repository.start(host);
  Future<void> reset(String host) => repository.reset(host);
  Future<void> sendTimerSettings({
    required String host,
    required int hours,
    required int minutes,
    required int seconds,
    required int warningPercent,
  }) => repository.sendTimerSettings(
    host: host,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    warningPercent: warningPercent,
  );

  Future<void> pushAndStart({
    required String host,
    required DateTime startDate,
    required DateTime endDate,
    int warningPercent = 10,
  }) => repository.pushAndStart(
    host: host,
    startDate: startDate,
    endDate: endDate,
  );

  Future<void> syncTime(String host) => repository.syncTime(host);
}
