import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/data/models/anniversary.dart';
import 'package:dayz/features/anniversary/presentation/providers/anniversary_provider.dart';
import 'package:dayz/features/home/presentation/home_screen.dart';
import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';

/// End-to-end integration test for the Dayz app.
///
/// Scenario: User opens the app → sees empty state → taps FAB →
/// enters a streak title → saves → sees the streak card →
/// taps "Check In Today" → sees "Checked In Today".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─── Hive Setup & Teardown ──────────────────────────────────────────────

  late Directory tempDir;
  late Box<Anniversary> anniversaryBox;
  late Box<Streak> streakBox;

  setUp(() async {
    // Use a fresh temp directory for each test to ensure isolation.
    tempDir = await Directory.systemTemp.createTemp('dayz_integration_');
    Hive.init(tempDir.path);

    // Register adapters only once (Hive throws if registered twice).
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnniversaryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(StreakAdapter());
    }

    // Open clean boxes.
    anniversaryBox = await Hive.openBox<Anniversary>('anniversaries');
    streakBox = await Hive.openBox<Streak>('streaks');
  });

  tearDown(() async {
    await anniversaryBox.clear();
    await streakBox.clear();
    await Hive.close();
    // Clean up temp directory.
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // ─── Helper ─────────────────────────────────────────────────────────────

  /// Builds the full app with real Hive boxes injected via ProviderScope.
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        anniversaryBoxProvider.overrideWithValue(anniversaryBox),
        streakBoxProvider.overrideWithValue(streakBox),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const HomeScreen(),
      ),
    );
  }

  // ─── Test ───────────────────────────────────────────────────────────────

  testWidgets(
    'Full flow: empty state → add streak → check in',
    (tester) async {
      // ── 1. ARRANGE — Launch the app ──────────────────────────────────────
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // ── 2. ASSERT — Verify empty states are visible ──────────────────────
      // Anniversary empty state.
      expect(
        find.text('Start tracking your\nspecial day'),
        findsOneWidget,
        reason: 'Anniversary empty-state prompt should be visible.',
      );

      // Streak empty state.
      expect(
        find.text('Start building your\ndiscipline'),
        findsOneWidget,
        reason: 'Streak empty-state prompt should be visible.',
      );

      // The FAB should be present.
      expect(
        find.byKey(const Key('addStreakFab')),
        findsOneWidget,
        reason: 'The add-streak FAB should be on screen.',
      );

      // ── 3. ACT — Tap the FAB to open the "Add Streak" dialog ────────────
      await tester.tap(find.byKey(const Key('addStreakFab')));
      await tester.pumpAndSettle();

      // Verify the dialog is showing.
      expect(
        find.text('New Streak'),
        findsOneWidget,
        reason: 'The "New Streak" dialog should appear.',
      );

      // ── 4. ACT — Enter a streak title and save ───────────────────────────
      final titleField = find.byKey(const Key('streakTitleField'));
      expect(titleField, findsOneWidget);

      await tester.enterText(titleField, 'Morning Run');
      await tester.pumpAndSettle();

      // Tap the Save button.
      await tester.tap(find.byKey(const Key('saveStreakBtn')));
      await tester.pumpAndSettle();

      // ── 5. ASSERT — The dialog is dismissed & streak card is visible ─────
      expect(
        find.text('New Streak'),
        findsNothing,
        reason: 'Dialog should be dismissed after saving.',
      );

      // The streak card should now show the title.
      expect(
        find.text('Morning Run'),
        findsOneWidget,
        reason: 'Streak card should display the title "Morning Run".',
      );

      // The streak empty-state prompt should be gone.
      expect(
        find.text('Start building your\ndiscipline'),
        findsNothing,
        reason: 'Streak empty-state should disappear after adding a streak.',
      );

      // The current streak should start at 0.
      expect(
        find.text('0'),
        findsOneWidget,
        reason: 'A newly created streak should have a count of 0.',
      );

      // The "Check In Today" button should be visible.
      expect(
        find.text('Check In Today'),
        findsOneWidget,
        reason: '"Check In Today" button should appear for an un-checked streak.',
      );

      // ── 6. ACT — Tap "Check In Today" ────────────────────────────────────
      await tester.tap(find.text('Check In Today'));
      await tester.pumpAndSettle();

      // ── 7. ASSERT — Check-in was successful ──────────────────────────────
      // The button should now show the "Checked In Today" completed state.
      expect(
        find.text('Checked In Today'),
        findsOneWidget,
        reason: '"Checked In Today" label should appear after checking in.',
      );

      // The active button text must be gone.
      expect(
        find.text('Check In Today'),
        findsNothing,
        reason: 'Active check-in button should disappear after checking in.',
      );

      // The streak count should now be 1.
      expect(
        find.text('1'),
        findsOneWidget,
        reason: 'Streak count should be 1 after the first check-in.',
      );

      // The "Best" badge should also read 1.
      expect(
        find.text('Best: 1 days'),
        findsOneWidget,
        reason: 'Best streak should be 1 after the first check-in.',
      );

      // ── 8. VERIFY — Data persisted in Hive ──────────────────────────────
      final persistedStreaks = streakBox.values.toList();
      expect(persistedStreaks, hasLength(1));
      expect(persistedStreaks.first.title, 'Morning Run');
      expect(persistedStreaks.first.currentStreak, 1);
      expect(persistedStreaks.first.lastCheckIn, isNotNull);
    },
  );
}
