import 'package:hive/hive.dart';

import '../models/streak.dart';

/// Repository that wraps a [Box<Streak>] for persistence.
///
/// This thin layer enables easy mocking in unit tests and potential
/// future migration away from Hive.
class StreakRepository {
  final Box<Streak> _box;

  /// Creates a repository backed by the given Hive [box].
  StreakRepository(this._box);

  /// Returns all streaks in the box.
  List<Streak> getAll() => _box.values.toList();

  /// Returns the streak with the given [id], or `null` if not found.
  Streak? getById(String id) => _box.get(id);

  /// Adds a [streak] to the box, keyed by its [Streak.id].
  Future<void> add(Streak streak) async {
    await _box.put(streak.id, streak);
  }

  /// Updates an existing [streak] in the box.
  Future<void> update(Streak streak) async {
    await _box.put(streak.id, streak);
  }

  /// Deletes the streak with the given [id] from the box.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
