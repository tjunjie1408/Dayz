import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/features/anniversary/data/models/anniversary.dart';
import 'package:dayz/features/anniversary/data/repositories/anniversary_repository.dart';
import 'package:dayz/features/anniversary/presentation/providers/anniversary_provider.dart';

class MockAnniversaryRepository extends Mock
    implements AnniversaryRepository {}

void main() {
  late MockAnniversaryRepository mockRepo;

  final testAnniversary = Anniversary(
    id: 'test-1',
    title: 'Together Since',
    startDate: DateTime(2024, 1, 15),
    note: 'Our story',
  );

  setUpAll(() {
    registerFallbackValue(testAnniversary);
  });

  setUp(() {
    mockRepo = MockAnniversaryRepository();
  });

  ProviderContainer createContainer() {
    when(() => mockRepo.getAll()).thenReturn([]);
    return ProviderContainer(
      overrides: [
        anniversaryRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  ProviderContainer createContainerWith(List<Anniversary> items) {
    when(() => mockRepo.getAll()).thenReturn(items);
    return ProviderContainer(
      overrides: [
        anniversaryRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('AnniversaryNotifier', () {
    test('initial state is empty list when repo is empty', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(anniversaryListProvider);

      expect(state, isEmpty);
      verify(() => mockRepo.getAll()).called(1);
    });

    test('initial state loads items from repo', () {
      final container = createContainerWith([testAnniversary]);
      addTearDown(container.dispose);

      final state = container.read(anniversaryListProvider);

      expect(state, [testAnniversary]);
    });

    test('add creates item and updates state', () async {
      when(() => mockRepo.add(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(anniversaryListProvider.notifier).add(
            title: 'New Anniversary',
            startDate: DateTime(2025, 6, 1),
            note: 'Test note',
          );

      final state = container.read(anniversaryListProvider);
      expect(state, hasLength(1));
      expect(state.first.title, 'New Anniversary');
      expect(state.first.startDate, DateTime(2025, 6, 1));
      expect(state.first.note, 'Test note');
      verify(() => mockRepo.add(any())).called(1);
    });

    test('update modifies item in state and persists', () async {
      when(() => mockRepo.update(any())).thenAnswer((_) async {});

      final container = createContainerWith([testAnniversary]);
      addTearDown(container.dispose);

      final updated = testAnniversary.copyWith(title: 'Updated Title');
      await container
          .read(anniversaryListProvider.notifier)
          .update(updated);

      final state = container.read(anniversaryListProvider);
      expect(state.first.title, 'Updated Title');
      verify(() => mockRepo.update(any())).called(1);
    });

    test('delete removes item from state and repo', () async {
      when(() => mockRepo.delete('test-1')).thenAnswer((_) async {});

      final container = createContainerWith([testAnniversary]);
      addTearDown(container.dispose);

      await container
          .read(anniversaryListProvider.notifier)
          .delete('test-1');

      final state = container.read(anniversaryListProvider);
      expect(state, isEmpty);
      verify(() => mockRepo.delete('test-1')).called(1);
    });

    test('loadAll refreshes state from repo', () async {
      when(() => mockRepo.add(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      // Add an item first.
      await container.read(anniversaryListProvider.notifier).add(
            title: 'First',
            startDate: DateTime(2024, 1, 1),
          );

      expect(container.read(anniversaryListProvider), hasLength(1));

      // Simulate repo now returning something different.
      when(() => mockRepo.getAll()).thenReturn([testAnniversary]);

      container.read(anniversaryListProvider.notifier).loadAll();

      final state = container.read(anniversaryListProvider);
      expect(state, [testAnniversary]);
    });
  });
}
