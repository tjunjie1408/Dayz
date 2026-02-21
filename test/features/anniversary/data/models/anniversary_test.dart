import 'package:flutter_test/flutter_test.dart';

import 'package:dayz/features/anniversary/data/models/anniversary.dart';

void main() {
  group('Anniversary', () {
    test('creates with correct fields', () {
      final anniversary = Anniversary(
        id: 'test-1',
        title: 'Together Since',
        startDate: DateTime(2024, 1, 15),
        note: 'Our first date',
      );

      expect(anniversary.id, 'test-1');
      expect(anniversary.title, 'Together Since');
      expect(anniversary.startDate, DateTime(2024, 1, 15));
      expect(anniversary.note, 'Our first date');
    });

    test('startDate stores date-only (truncates time component)', () {
      final anniversary = Anniversary(
        id: 'test-2',
        title: 'Test',
        startDate: DateTime(2024, 6, 15, 14, 30, 45), // with time
      );

      // Time component should be truncated.
      expect(anniversary.startDate.hour, 0);
      expect(anniversary.startDate.minute, 0);
      expect(anniversary.startDate.second, 0);
      expect(anniversary.startDate, DateTime(2024, 6, 15));
    });

    test('calculates days since start with truncated local dates', () {
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);

      // 10 days ago.
      final tenDaysAgo = todayOnly.subtract(const Duration(days: 10));
      final anniversary = Anniversary(
        id: 'test-3',
        title: 'Test',
        startDate: tenDaysAgo,
      );

      expect(anniversary.daysSinceStart, 10);
    });

    test('daysSinceStart is 0 for today', () {
      final anniversary = Anniversary(
        id: 'test-4',
        title: 'Test',
        startDate: DateTime.now(),
      );

      expect(anniversary.daysSinceStart, 0);
    });

    test('copyWith creates modified copy', () {
      final original = Anniversary(
        id: 'test-5',
        title: 'Original',
        startDate: DateTime(2024, 1, 1),
        note: 'old note',
      );

      final modified = original.copyWith(title: 'Modified', note: 'new note');

      expect(modified.id, 'test-5'); // unchanged
      expect(modified.title, 'Modified');
      expect(modified.startDate, DateTime(2024, 1, 1)); // unchanged
      expect(modified.note, 'new note');
    });

    test('copyWith without arguments returns equivalent copy', () {
      final original = Anniversary(
        id: 'test-6',
        title: 'Test',
        startDate: DateTime(2024, 3, 20),
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.startDate, original.startDate);
      expect(copy.note, original.note);
    });

    test('equality is based on id', () {
      final a = Anniversary(
        id: 'same-id',
        title: 'First',
        startDate: DateTime(2024, 1, 1),
      );
      final b = Anniversary(
        id: 'same-id',
        title: 'Second',
        startDate: DateTime(2025, 6, 15),
      );
      final c = Anniversary(
        id: 'different-id',
        title: 'First',
        startDate: DateTime(2024, 1, 1),
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString returns readable representation', () {
      final anniversary = Anniversary(
        id: 'test-7',
        title: 'Test',
        startDate: DateTime(2024, 1, 15),
      );

      final str = anniversary.toString();
      expect(str, contains('Anniversary'));
      expect(str, contains('test-7'));
      expect(str, contains('Test'));
    });
  });
}
