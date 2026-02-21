import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/features/anniversary/data/models/anniversary.dart';
import 'package:dayz/features/anniversary/data/repositories/anniversary_repository.dart';

class MockBox extends Mock implements Box<Anniversary> {}

void main() {
  late MockBox mockBox;
  late AnniversaryRepository repository;

  final anniversary = Anniversary(
    id: 'test-1',
    title: 'Together Since',
    startDate: DateTime(2024, 1, 15),
    note: 'Our story',
  );

  setUpAll(() {
    registerFallbackValue(anniversary);
  });

  setUp(() {
    mockBox = MockBox();
    repository = AnniversaryRepository(mockBox);
  });

  group('AnniversaryRepository', () {
    test('getAll returns all items from the box', () {
      when(() => mockBox.values).thenReturn([anniversary]);

      final result = repository.getAll();

      expect(result, [anniversary]);
      verify(() => mockBox.values).called(1);
    });

    test('getAll returns empty list when box is empty', () {
      when(() => mockBox.values).thenReturn([]);

      final result = repository.getAll();

      expect(result, isEmpty);
    });

    test('getById returns correct item', () {
      when(() => mockBox.get('test-1')).thenReturn(anniversary);

      final result = repository.getById('test-1');

      expect(result, anniversary);
      verify(() => mockBox.get('test-1')).called(1);
    });

    test('getById returns null for non-existent id', () {
      when(() => mockBox.get('non-existent')).thenReturn(null);

      final result = repository.getById('non-existent');

      expect(result, isNull);
    });

    test('add puts item in box with id as key', () async {
      when(() => mockBox.put('test-1', anniversary))
          .thenAnswer((_) async {});

      await repository.add(anniversary);

      verify(() => mockBox.put('test-1', anniversary)).called(1);
    });

    test('update puts updated item in box', () async {
      final updated = anniversary.copyWith(title: 'Updated Title');
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
