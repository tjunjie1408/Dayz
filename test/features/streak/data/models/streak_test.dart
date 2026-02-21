import 'package:flutter_test/flutter_test.dart';

import 'package:dayz/features/streak/data/models/streak.dart';

void main() {
  group('Streak', () {
    test('creates with default values', () {
      final streak = Streak(
        id: 'test-1',
        title: 'Morning Run',
        startDate: DateTime(2024, 1, 1),
      );

      expect(streak.id, 'test-1');
      expect(streak.title, 'Morning Run');
      expect(streak.startDate, DateTime(2024, 1, 1));
      expect(streak.lastCheckIn, isNull);
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
    });

    test('startDate and lastCheckIn store date-only', () {
      final streak = Streak(
        id: 'test-2',
        title: 'Test',
        startDate: DateTime(2024, 6, 15, 14, 30, 45),
        lastCheckIn: DateTime(2024, 6, 20, 23, 59, 59),
      );

      expect(streak.startDate, DateTime(2024, 6, 15));
      expect(streak.startDate.hour, 0);
      expect(streak.lastCheckIn, DateTime(2024, 6, 20));
      expect(streak.lastCheckIn!.hour, 0);
    });

    test('checkIn increments streak', () {
      final streak = Streak(
        id: 'test-3',
        title: 'Test',
        startDate: DateTime(2024, 1, 1),
        currentStreak: 5,
        longestStreak: 10,
      );

      final checked = streak.checkIn(now: DateTime(2024, 2, 1));

      expect(checked.currentStreak, 6);
      expect(checked.lastCheckIn, DateTime(2024, 2, 1));
    });

    test('checkIn on same day is idempotent', () {
      final checkInDate = DateTime(2024, 6, 15);
      final streak = Streak(
        id: 'test-4',
        title: 'Test',
        startDate: DateTime(2024, 1, 1),
        lastCheckIn: checkInDate,
        currentStreak: 3,
        longestStreak: 5,
      );

      // Check in again on the same day — should return same instance.
      final result = streak.checkIn(now: DateTime(2024, 6, 15, 23, 59));

      expect(identical(result, streak), isTrue);
      expect(result.currentStreak, 3); // unchanged
    });

    test('checkIn updates longest streak when exceeded', () {
      final streak = Streak(
        id: 'test-5',
        title: 'Test',
        startDate: DateTime(2024, 1, 1),
        currentStreak: 9,
        longestStreak: 9,
      );

      final checked = streak.checkIn(now: DateTime(2024, 2, 1));

      expect(checked.currentStreak, 10);
      expect(checked.longestStreak, 10);
    });

    test('checkIn does not update longest streak when not exceeded', () {
      final streak = Streak(
        id: 'test-6',
        title: 'Test',
        startDate: DateTime(2024, 1, 1),
        currentStreak: 3,
        longestStreak: 20,
      );

      final checked = streak.checkIn(now: DateTime(2024, 2, 1));

      expect(checked.currentStreak, 4);
      expect(checked.longestStreak, 20); // unchanged
    });

    test('reset sets streak to zero but preserves longest', () {
      final streak = Streak(
        id: 'test-7',
        title: 'Test',
        startDate: DateTime(2024, 1, 1),
        lastCheckIn: DateTime(2024, 6, 15),
        currentStreak: 15,
        longestStreak: 30,
      );

      final result = streak.reset();

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 30); // preserved
      expect(result.lastCheckIn, isNull);
      expect(result.id, streak.id);
      expect(result.title, streak.title);
    });

    test('daysSinceStart uses truncated local dates', () {
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);
      final sevenDaysAgo = todayOnly.subtract(const Duration(days: 7));

      final streak = Streak(
        id: 'test-8',
        title: 'Test',
        startDate: sevenDaysAgo,
      );

      expect(streak.daysSinceStart, 7);
    });

    test('daysSinceStart is 0 for today', () {
      final streak = Streak(
        id: 'test-9',
        title: 'Test',
        startDate: DateTime.now(),
      );

      expect(streak.daysSinceStart, 0);
    });

    test('copyWith creates modified copy', () {
      final original = Streak(
        id: 'test-10',
        title: 'Original',
        startDate: DateTime(2024, 1, 1),
        currentStreak: 5,
        longestStreak: 10,
      );

      final modified = original.copyWith(
        title: 'Modified',
        currentStreak: 0,
      );

      expect(modified.id, 'test-10');
      expect(modified.title, 'Modified');
      expect(modified.currentStreak, 0);
      expect(modified.longestStreak, 10);
    });

    test('equality is based on id', () {
      final a = Streak(
        id: 'same-id',
        title: 'First',
        startDate: DateTime(2024, 1, 1),
      );
      final b = Streak(
        id: 'same-id',
        title: 'Second',
        startDate: DateTime(2025, 6, 15),
      );
      final c = Streak(
        id: 'different-id',
        title: 'First',
        startDate: DateTime(2024, 1, 1),
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString returns readable representation', () {
      final streak = Streak(
        id: 'test-11',
        title: 'Test',
        startDate: DateTime(2024, 1, 1),
      );

      final str = streak.toString();
      expect(str, contains('Streak'));
      expect(str, contains('test-11'));
    });
  });
}
