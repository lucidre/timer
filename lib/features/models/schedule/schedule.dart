import 'dart:convert';
import 'package:collection/collection.dart';

class Schedule {
  int? id;
  String? name;
  bool? bufferIncrease;
  DateTime? start;
  DateTime? end;
  Duration? buffer;
  DateTime? createdAt;
  DateTime? updatedAt;

  Schedule({
    this.id,
    this.name,
    this.bufferIncrease,
    this.start,
    this.end,
    this.buffer,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() {
    return 'Schedule(id: $id, name: $name, bufferIncrease: $bufferIncrease, '
        'start: $start, end: $end, buffer: $buffer, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  factory Schedule.fromMap(Map<String, dynamic> data) => Schedule(
    id: data['id'] as int?,
    name: data['name'] as String?,
    bufferIncrease: data['bufferIncrease'] as bool?,
    start: data['start'] == null
        ? null
        : DateTime.parse(data['start'] as String),
    end: data['end'] == null ? null : DateTime.parse(data['end'] as String),
    buffer: data['buffer'] == null
        ? null
        : Duration(microseconds: data['buffer'] as int),
    createdAt: data['createdAt'] == null
        ? null
        : DateTime.parse(data['createdAt'] as String),
    updatedAt: data['updatedAt'] == null
        ? null
        : DateTime.parse(data['updatedAt'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'bufferIncrease': bufferIncrease,
    'start': start?.toIso8601String(),
    'end': end?.toIso8601String(),
    'buffer': buffer?.inMicroseconds,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Schedule.fromJson(String data) {
    return Schedule.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  Schedule copyWith({
    int? id,
    String? name,
    DateTime? start,
    DateTime? end,
    Duration? buffer,
    bool? bufferIncrease,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      start: start ?? this.start,
      end: end ?? this.end,
      buffer: buffer ?? this.buffer,
      bufferIncrease: bufferIncrease ?? this.bufferIncrease,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convenience constructor — stamps createdAt + updatedAt automatically.
  /// Use this when creating a brand-new schedule.
  ///
  ///   final s = Schedule.create(name: 'Morning', start: ..., end: ...);
  factory Schedule.create({
    int? id,
    String? name,
    bool? bufferIncrease,
    DateTime? start,
    DateTime? end,
    Duration? buffer,
  }) {
    final now = DateTime.now();
    return Schedule(
      id: id,
      name: name,
      bufferIncrease: bufferIncrease,
      start: start,
      end: end,
      buffer: buffer,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns a copy with updatedAt stamped to now.
  /// Use this on every edit before persisting / broadcasting.
  ///
  ///   final updated = schedule.touch(name: 'New name');
  Schedule touch({
    int? id,
    String? name,
    DateTime? start,
    DateTime? end,
    Duration? buffer,
    bool? bufferIncrease,
  }) {
    return copyWith(
      id: id,
      name: name,
      start: start,
      end: end,
      buffer: buffer,
      bufferIncrease: bufferIncrease,
      updatedAt: DateTime.now(), // always stamp
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Schedule) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      start.hashCode ^
      end.hashCode ^
      buffer.hashCode ^
      bufferIncrease.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
