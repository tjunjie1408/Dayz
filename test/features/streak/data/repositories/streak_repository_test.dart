import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/data/repositories/streak_repository.dart';

class MockBox extends Mock implements Box<Streak> {}

void main() {
  late MockBox mockBox;
  late StreakRepository repository;

  final streak = Streak(
    id: 'test-1',
    title: 'Morning Run',
    startDate: DateTime(2024, 1, 1),
    currentStreak: 5,
    longestStreak: 10,
  );

  setUpAll(() {
    registerFallbackValue(streak);
  });

  setUp(() {
    mockBox = MockBox();
    repository = StreakRepository(mockBox);
  });

  group('StreakRepository', () {
    test('getAll returns all items from the box', () {
      when(() => mockBox.values).thenReturn([streak]);

      final result = repository.getAll();

      expect(result, [streak]);
      verify(() => mockBox.values).called(1);
    });

    test('getAll returns empty list when box is empty', () {
      when(() => mockBox.values).thenReturn([]);

      final result = repository.getAll();

      expect(result, isEmpty);
    });

    test('getById returns correct item', () {
      when(() => mockBox.get('test-1')).thenReturn(streak);

      final result = repository.getById('test-1');

      expect(result, streak);
      verify(() => mockBox.get('test-1')).called(1);
    });

    test('getById returns null for non-existent id', () {
      when(() => mockBox.get('non-existent')).thenReturn(null);

      final result = repository.getById('non-existent');

      expect(result, isNull);
    });

    test('add puts item in box with id as key', () async {
      when(() => mockBox.put('test-1', streak))
          .thenAnswer((_) async {});

      await repository.add(streak);

      verify(() => mockBox.put('test-1', streak)).called(1);
    });

    test('update puts updated item in box', () async {
      final updated = streak.copyWith(currentStreak: 6);
      when(() => mockBox.put('test-1', updated))
          .thenAnswer((_) async {});

      await repository.update(updated);

      verify(() => mockBox.put('test-1', updated)).called(1);
    });

    test('delete removes item by id', () async {
      when(() => mockBox.delete('test-1')).thenAnswer((_) async {});

      await repository.delete('test-1');

      verify(() => mockBox.delete('test-1')).called(1);
    });
  });
}
