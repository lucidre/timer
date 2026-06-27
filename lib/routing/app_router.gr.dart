// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:timer/common_libs.dart' as _i6;
import 'package:timer/features/models/schedule/schedule.dart' as _i7;
import 'package:timer/features/presentation/pages/dashboard.dart' as _i1;
import 'package:timer/features/presentation/pages/device_setup.dart'
    as _i2;
import 'package:timer/features/presentation/pages/schedule_form.dart'
    as _i3;
import 'package:timer/features/presentation/pages/splash.dart' as _i4;

/// generated route for
/// [_i1.DashboardScreen]
class DashboardRoute extends _i5.PageRouteInfo<void> {
  const DashboardRoute({List<_i5.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i2.DeviceSetupScreen]
class DeviceSetupRoute extends _i5.PageRouteInfo<void> {
  const DeviceSetupRoute({List<_i5.PageRouteInfo>? children})
    : super(DeviceSetupRoute.name, initialChildren: children);

  static const String name = 'DeviceSetupRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.DeviceSetupScreen();
    },
  );
}

/// generated route for
/// [_i3.ScheduleFormScreen]
class ScheduleFormRoute extends _i5.PageRouteInfo<ScheduleFormRouteArgs> {
  ScheduleFormRoute({
    _i6.Key? key,
    _i7.Schedule? schedule,
    DateTime? previousEndTime,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         ScheduleFormRoute.name,
         args: ScheduleFormRouteArgs(
           key: key,
           schedule: schedule,
           previousEndTime: previousEndTime,
         ),
         initialChildren: children,
       );

  static const String name = 'ScheduleFormRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScheduleFormRouteArgs>(
        orElse: () => const ScheduleFormRouteArgs(),
      );
      return _i3.ScheduleFormScreen(
        key: args.key,
        schedule: args.schedule,
        previousEndTime: args.previousEndTime,
      );
    },
  );
}

class ScheduleFormRouteArgs {
  const ScheduleFormRouteArgs({this.key, this.schedule, this.previousEndTime});

  final _i6.Key? key;

  final _i7.Schedule? schedule;

  final DateTime? previousEndTime;

  @override
  String toString() {
    return 'ScheduleFormRouteArgs{key: $key, schedule: $schedule, previousEndTime: $previousEndTime}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleFormRouteArgs) return false;
    return key == other.key &&
        schedule == other.schedule &&
        previousEndTime == other.previousEndTime;
  }

  @override
  int get hashCode =>
      key.hashCode ^ schedule.hashCode ^ previousEndTime.hashCode;
}

/// generated route for
/// [_i4.SplashScreen]
class SplashRoute extends _i5.PageRouteInfo<void> {
  const SplashRoute({List<_i5.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SplashScreen();
    },
  );
}
