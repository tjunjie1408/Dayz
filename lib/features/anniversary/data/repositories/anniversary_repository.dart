import 'package:hive/hive.dart';

import '../models/anniversary.dart';

/// Repository that wraps a [Box<Anniversary>] for persistence.
///
/// This thin layer enables easy mocking in unit tests and potential
/// future migration away from Hive.
class AnniversaryRepository {
  final Box<Anniversary> _box;

  /// Creates a repository backed by the given Hive [box].
  AnniversaryRepository(this._box);

  /// Returns all anniversaries in the box.
  List<Anniversary> getAll() => _box.values.toList();

  /// Returns the anniversary with the given [id], or `null` if not found.
  Anniversary? getById(String id) => _box.get(id);

  /// Adds an [anniversary] to the box, keyed by its [Anniversary.id].
  Future<void> add(Anniversary anniversary) async {
    await _box.put(anniversary.id, anniversary);
  }

  /// Updates an existing [anniversary] in the box.
  Future<void> update(Anniversary anniversary) async {
    await _box.put(anniversary.id, anniversary);
  }

  /// Deletes the anniversary with the given [id] from the box.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
