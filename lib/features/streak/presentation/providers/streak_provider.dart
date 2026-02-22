import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/streak.dart';
import '../../data/repositories/streak_repository.dart';

const _uuid = Uuid();

/// Provider for the Hive box backing streak storage.
///
/// This is overridden in `main.dart` with the pre-opened box.
final streakBoxProvider = Provider<Box<Streak>>(
  (ref) => throw UnimplementedError(
    'streakBoxProvider must be overridden with an opened Hive box.',
  ),
);

/// Provider for the [StreakRepository].
final streakRepositoryProvider = Provider<StreakRepository>(
  (ref) => StreakRepository(ref.watch(streakBoxProvider)),
);

/// Notifier that manages a list of [Streak] items.
///
/// Reads from and writes to the [StreakRepository] to keep
/// in-memory state and Hive storage in sync.
class StreakNotifier extends Notifier<List<Streak>> {
  @override
  List<Streak> build() {
    return ref.watch(streakRepositoryProvider).getAll();
  }

  /// Adds a new streak with the given [title], [startDate], and [colorIndex].
  Future<void> add({
    required String title,
    required DateTime startDate,
    int colorIndex = 0,
  }) async {
    final streak = Streak(
      id: const Uuid().v4(),
      title: title,
      startDate: startDate,
      colorIndex: colorIndex,
    );
    await ref.read(streakRepositoryProvider).add(streak);
    state = [...state, streak];
    debugPrint('Total streaks in state: ${state.length}');
  }

  /// Performs a check-in on the streak with the given [id].
  ///
  /// Same-day check-ins are idempotent (no-op).
  Future<void> checkIn(String id) async {
    final repo = ref.read(streakRepositoryProvider);
    final streak = repo.getById(id);
    if (streak == null) return;

    final updated = streak.checkIn();
    if (identical(updated, streak)) return; // Same-day, no change.

    await repo.update(updated);
    state = [
      for (final item in state)
        if (item.id == id) updated else item,
    ];
  }

  /// Resets the streak with the given [id] to zero.
  ///
  /// Preserves [Streak.longestStreak].
  Future<void> reset(String id) async {
    final repo = ref.read(streakRepositoryProvider);
    final streak = repo.getById(id);
    if (streak == null) return;

    final updated = streak.reset();
    await repo.update(updated);
    state = [
      for (final item in state)
        if (item.id == id) updated else item,
    ];
  }

  /// Deletes the streak with the given [id].
  Future<void> delete(String id) async {
    await ref.read(streakRepositoryProvider).delete(id);
    state = state.where((item) => item.id != id).toList();
  }

  /// Reloads all streaks from the repository.
  void loadAll() {
    state = ref.read(streakRepositoryProvider).getAll();
  }
}

/// Provider for the list of streaks.
final streakListProvider =
    NotifierProvider<StreakNotifier, List<Streak>>(
  StreakNotifier.new,
);
