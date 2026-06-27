import 'dart:convert';
import 'schedule.dart';
import 'package:collection/collection.dart';

class Schedules {
  bool? success;
  List<Schedule>? data;
  String? msg;

  Schedules({this.success, this.data, this.msg});

  @override
  String toString() => 'Schedules(success: $success, data: $data, msg: $msg)';

  factory Schedules.fromMap(Map<String, dynamic> data) => Schedules(
    success: data['success'] as bool?,
    data: (data['data'] as List<dynamic>?)
        ?.map((e) => Schedule.fromMap(e as Map<String, dynamic>))
        .toList(),
    msg: data['msg'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'success': success,
    'data': data?.map((e) => e.toMap()).toList(),
    'msg': msg,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Schedules].
  factory Schedules.fromJson(String data) {
    return Schedules.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Schedules] to a JSON string.
  String toJson() => json.encode(toMap());

  Schedules copyWith({bool? success, List<Schedule>? data, String? msg}) {
    return Schedules(
      success: success ?? this.success,
      data: data ?? this.data,
      msg: msg ?? this.msg,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Schedules) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => success.hashCode ^ data.hashCode ^ msg.hashCode;
}
