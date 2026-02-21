import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/anniversary.dart';
import '../../data/repositories/anniversary_repository.dart';

const _uuid = Uuid();

/// Provider for the Hive box backing anniversary storage.
///
/// This is overridden in `main.dart` with the pre-opened box.
final anniversaryBoxProvider = Provider<Box<Anniversary>>(
  (ref) => throw UnimplementedError(
    'anniversaryBoxProvider must be overridden with an opened Hive box.',
  ),
);

/// Provider for the [AnniversaryRepository].
final anniversaryRepositoryProvider = Provider<AnniversaryRepository>(
  (ref) => AnniversaryRepository(ref.watch(anniversaryBoxProvider)),
);

/// Notifier that manages a list of [Anniversary] items.
///
/// Reads from and writes to the [AnniversaryRepository] to keep
/// in-memory state and Hive storage in sync.
class AnniversaryNotifier extends Notifier<List<Anniversary>> {
  @override
  List<Anniversary> build() {
    return ref.watch(anniversaryRepositoryProvider).getAll();
  }

  /// Adds a new anniversary with the given [title], [startDate], and [note].
  Future<void> add({
    required String title,
    required DateTime startDate,
    String? note,
  }) async {
    final anniversary = Anniversary(
      id: _uuid.v4(),
      title: title,
      startDate: startDate,
      note: note,
    );
    await ref.read(anniversaryRepositoryProvider).add(anniversary);
    state = [...state, anniversary];
  }

  /// Updates an existing anniversary by replacing the one with matching id.
  Future<void> update(Anniversary updated) async {
    await ref.read(anniversaryRepositoryProvider).update(updated);
    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
  }

  /// Deletes the anniversary with the given [id].
  Future<void> delete(String id) async {
    await ref.read(anniversaryRepositoryProvider).delete(id);
    state = state.where((item) => item.id != id).toList();
  }

  /// Reloads all anniversaries from the repository.
  void loadAll() {
    state = ref.read(anniversaryRepositoryProvider).getAll();
  }
}

/// Provider for the list of anniversaries.
final anniversaryListProvider =
    NotifierProvider<AnniversaryNotifier, List<Anniversary>>(
  AnniversaryNotifier.new,
);
