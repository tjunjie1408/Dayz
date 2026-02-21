import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/data/repositories/streak_repository.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  late MockStreakRepository mockRepo;

  final testStreak = Streak(
    id: 'test-1',
    title: 'Morning Run',
    startDate: DateTime(2024, 1, 1),
    currentStreak: 5,
    longestStreak: 10,
  );

  setUpAll(() {
    registerFallbackValue(testStreak);
  });

  setUp(() {
    mockRepo = MockStreakRepository();
  });

  ProviderContainer createContainer() {
    when(() => mockRepo.getAll()).thenReturn([]);
    return ProviderContainer(
      overrides: [
        streakRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  ProviderContainer createContainerWith(List<Streak> items) {
    when(() => mockRepo.getAll()).thenReturn(items);
    return ProviderContainer(
      overrides: [
        streakRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('StreakNotifier', () {
    test('initial state is empty list when repo is empty', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(streakListProvider);

      expect(state, isEmpty);
      verify(() => mockRepo.getAll()).called(1);
    });

    test('initial state loads items from repo', () {
      final container = createContainerWith([testStreak]);
      addTearDown(container.dispose);

      final state = container.read(streakListProvider);

      expect(state, [testStreak]);
    });

    test('add creates streak and updates state', () async {
      when(() => mockRepo.add(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(streakListProvider.notifier).add(
            title: 'New Streak',
            startDate: DateTime(2025, 1, 1),
          );

      final state = container.read(streakListProvider);
      expect(state, hasLength(1));
      expect(state.first.title, 'New Streak');
      expect(state.first.currentStreak, 0);
      expect(state.first.longestStreak, 0);
      verify(() => mockRepo.add(any())).called(1);
    });

    test('checkIn updates correct streak in state', () async {
      when(() => mockRepo.getById('test-1')).thenReturn(testStreak);
      when(() => mockRepo.update(any())).thenAnswer((_) async {});

      final container = createContainerWith([testStreak]);
      addTearDown(container.dispose);

      await container.read(streakListProvider.notifier).checkIn('test-1');

      final state = container.read(streakListProvider);
      expect(state.first.currentStreak, 6);
      verify(() => mockRepo.update(any())).called(1);
    });

    test('checkIn on non-existent id does nothing', () async {
      when(() => mockRepo.getById('bad-id')).thenReturn(null);

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(streakListProvider.notifier).checkIn('bad-id');

      final state = container.read(streakListProvider);
      expect(state, isEmpty);
      verifyNever(() => mockRepo.update(any()));
    });

    test('reset updates correct streak in state', () async {
      when(() => mockRepo.getById('test-1')).thenReturn(testStreak);
      when(() => mockRepo.update(any())).thenAnswer((_) async {});

      final container = createContainerWith([testStreak]);
      addTearDown(container.dispose);

      await container.read(streakListProvider.notifier).reset('test-1');

      final state = container.read(streakListProvider);
      expect(state.first.currentStreak, 0);
      expect(state.first.longestStreak, 10); // preserved
      verify(() => mockRepo.update(any())).called(1);
    });

    test('delete removes streak from state and repo', () async {
      when(() => mockRepo.delete('test-1')).thenAnswer((_) async {});

      final container = createContainerWith([testStreak]);
      addTearDown(container.dispose);

      await container.read(streakListProvider.notifier).delete('test-1');

      final state = container.read(streakListProvider);
      expect(state, isEmpty);
      verify(() => mockRepo.delete('test-1')).called(1);
    });

    test('loadAll refreshes state from repo', () async {
      when(() => mockRepo.add(any())).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(streakListProvider.notifier).add(
            title: 'First',
            startDate: DateTime(2024, 1, 1),
          );

      expect(container.read(streakListProvider), hasLength(1));

      when(() => mockRepo.getAll()).thenReturn([testStreak]);

      container.read(streakListProvider.notifier).loadAll();

      final state = container.read(streakListProvider);
      expect(state, [testStreak]);
    });
  });
}
