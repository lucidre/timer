import 'package:timer/features/models/schedule/schedules.dart';

abstract class SplashRepository {
  Future<Schedules> getSchedule();
  Future<void> start(String host);
  Future<void> reset(String host);
  Future<void> sendTimerSettings({
    required String host,
    required int hours,
    required int minutes,
    required int seconds,
    required int warningPercent,
  });
  Future<void> pushAndStart({
    required String host,
    required DateTime startDate,
    required DateTime endDate,
    int warningPercent = 10,
  });

  Future<void> syncTime(String host);
}
