import 'package:hive/hive.dart';

part 'anniversary.g.dart';

/// A model representing a tracked anniversary or milestone date.
///
/// All [DateTime] values are stored as **date-only local time**
/// (year, month, day) to prevent midnight-crossing calculation bugs.
@HiveType(typeId: 0)
class Anniversary extends HiveObject {
  /// Unique identifier for this anniversary.
  @HiveField(0)
  final String id;

  /// Display title for the anniversary (e.g., "Together Since").
  @HiveField(1)
  final String title;

  /// The starting date, stored as date-only local time.
  @HiveField(2)
  final DateTime startDate;

  /// An optional note or description.
  @HiveField(3)
  final String? note;

  Anniversary({
    required this.id,
    required this.title,
    required DateTime startDate,
    this.note,
  }) : startDate = DateTime(startDate.year, startDate.month, startDate.day);

  /// Calculates the number of days since [startDate] using truncated
  /// local dates to avoid timezone and midnight-crossing issues.
  int get daysSinceStart {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    return todayOnly.difference(startDate).inDays;
  }

  /// Creates a copy of this anniversary with the given fields replaced.
  Anniversary copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    String? note,
  }) {
    return Anniversary(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Anniversary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Anniversary(id: $id, title: $title, '
      'startDate: $startDate, note: $note)';
}
