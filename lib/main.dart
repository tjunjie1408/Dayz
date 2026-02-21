import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/anniversary/data/models/anniversary.dart';
import 'features/anniversary/presentation/providers/anniversary_provider.dart';
import 'features/streak/data/models/streak.dart';
import 'features/streak/presentation/providers/streak_provider.dart';

/// Entry point for the Dayz app.
///
/// All Hive initialization (adapter registration and box opening) completes
/// **before** [runApp] is called, ensuring boxes are ready at app start.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter.
  await Hive.initFlutter();

  // Register type adapters.
  Hive.registerAdapter(AnniversaryAdapter());
  Hive.registerAdapter(StreakAdapter());

  // Open boxes — must complete before runApp.
  final anniversaryBox =
      await Hive.openBox<Anniversary>('anniversaries');
  final streakBox = await Hive.openBox<Streak>('streaks');

  runApp(
    ProviderScope(
      overrides: [
        anniversaryBoxProvider.overrideWithValue(anniversaryBox),
        streakBoxProvider.overrideWithValue(streakBox),
      ],
      child: const App(),
    ),
  );
}
