import 'package:hive/hive.dart';

part 'streak.g.dart';

/// A model representing a streak-based tracker (e.g., habit, discipline).
///
/// All [DateTime] values are stored as **date-only local time**
/// (year, month, day) to prevent midnight-crossing calculation bugs.
@HiveType(typeId: 1)
class Streak extends HiveObject {
  /// Unique identifier for this streak.
  @HiveField(0)
  final String id;

  /// Display title for the streak (e.g., "Morning Run").
  @HiveField(1)
  final String title;

  /// The date when the streak was first created, stored as date-only.
  @HiveField(2)
  final DateTime startDate;

  /// The last date the user checked in, stored as date-only.
  /// `null` means no check-in has occurred yet.
  @HiveField(3)
  final DateTime? lastCheckIn;

  /// The current consecutive streak count.
  @HiveField(4)
  final int currentStreak;

  /// The longest streak ever achieved for this tracker.
  @HiveField(5)
  final int longestStreak;

  /// The dates when the user successfully checked in (truncated to local date).
  @HiveField(6)
  final List<DateTime> history;

  /// The index of the color assigned to this streak.
  @HiveField(7, defaultValue: 0)
  final int colorIndex;

  Streak({
    required this.id,
    required this.title,
    required DateTime startDate,
    DateTime? lastCheckIn,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<DateTime>? history,
    this.colorIndex = 0,
  })  : startDate = DateTime(startDate.year, startDate.month, startDate.day),
        history = history ?? [],
        lastCheckIn = lastCheckIn != null
            ? DateTime(
                lastCheckIn.year, lastCheckIn.month, lastCheckIn.day)
            : null;

  /// Calculates the number of days since [startDate] using truncated
  /// local dates.
  int get daysSinceStart {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    return todayOnly.difference(startDate).inDays;
  }

  /// Performs a check-in for today.
  ///
  /// - If already checked in today, returns `this` unchanged (idempotent).
  /// - Otherwise, increments [currentStreak] and updates [longestStreak]
  ///   if the new streak exceeds it.
  ///
  /// Uses [now] parameter for testability; defaults to `DateTime.now()`.
  Streak checkIn({DateTime? now}) {
    final today = now ?? DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Same-day check-in is a no-op.
    if (lastCheckIn != null &&
        lastCheckIn!.year == todayOnly.year &&
        lastCheckIn!.month == todayOnly.month &&
        lastCheckIn!.day == todayOnly.day) {
      return this;
    }

    final newStreak = currentStreak + 1;
    final newLongest =
        newStreak > longestStreak ? newStreak : longestStreak;

    return Streak(
      id: id,
      title: title,
      startDate: startDate,
      lastCheckIn: todayOnly,
      currentStreak: newStreak,
      longestStreak: newLongest,
      history: [...history, todayOnly],
      colorIndex: colorIndex,
    );
  }

  /// Resets the current streak to zero while preserving [longestStreak].
  Streak reset() {
    return Streak(
      id: id,
      title: title,
      startDate: startDate,
      lastCheckIn: null,
      currentStreak: 0,
      longestStreak: longestStreak,
      history: history,
      colorIndex: colorIndex,
    );
  }

  /// Creates a copy of this streak with the given fields replaced.
  Streak copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? lastCheckIn,
    int? currentStreak,
    int? longestStreak,
    List<DateTime>? history,
    int? colorIndex,
  }) {
    return Streak(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      history: history ?? this.history,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Streak &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Streak(id: $id, title: $title, '
      'startDate: $startDate, lastCheckIn: $lastCheckIn, '
      'currentStreak: $currentStreak, longestStreak: $longestStreak, '
      'history: $history, colorIndex: $colorIndex)';
}
