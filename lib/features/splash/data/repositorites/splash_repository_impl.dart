import 'package:timer/features/splash/models/schedule/schedules.dart';
import 'package:timer/shared/api/app_exceptions.dart';

import '../../domain/repositories/splash_repository.dart';
import '../data_sources/splash_data_source.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashDataSource remoteDataSource;

  SplashRepositoryImpl(this.remoteDataSource);

  @override
  Future<Schedules> getSchedule() async {
    try {
      final response = await remoteDataSource.getSchedule();
      return response;
    } catch (exception) {
      throw AppExceptions.from(exception);
    }
  }

  @override
  Future<void> pushAndStart({
    required String host,
    required DateTime startDate,
    required DateTime endDate,
    int warningPercent = 10,
  }) async {
    try {
      final response = await remoteDataSource.pushAndStart(
        host: host,
        startDate: startDate,
        endDate: endDate,
      );
      return response;
    } catch (exception) {
      throw AppExceptions.from(exception);
    }
  }

  @override
  Future<void> reset(String host) async {
    try {
      final response = await remoteDataSource.reset(host);
      return response;
    } catch (exception) {
      throw AppExceptions.from(exception);
    }
  }

  @override
  Future<void> sendTimerSettings({
    required String host,
    required int hours,
    required int minutes,
    required int seconds,
    required int warningPercent,
  }) async {
    try {
      final response = await remoteDataSource.sendTimerSettings(
        host: host,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        warningPercent: warningPercent,
      );
      return response;
    } catch (exception) {
      throw AppExceptions.from(exception);
    }
  }

  @override
  Future<void> start(String host) async {
    try {
      final response = await remoteDataSource.start(host);
      return response;
    } catch (exception) {
      throw AppExceptions.from(exception);
    }
  }

  @override
  Future<void> syncTime(String host) async {
    try {
      final response = await remoteDataSource.syncTime(host);
      return response;
    } catch (exception) {
      throw AppExceptions.from(exception);
    }
  }
}
