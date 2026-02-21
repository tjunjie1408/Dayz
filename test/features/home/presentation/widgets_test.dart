import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/data/models/anniversary.dart';
import 'package:dayz/features/anniversary/presentation/providers/anniversary_provider.dart';
import 'package:dayz/features/anniversary/presentation/widgets/anniversary_card.dart';
import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';
import 'package:dayz/features/streak/presentation/widgets/streak_card.dart';

// ─── Mock Notifiers ───────────────────────────────────────────────────────────

/// A mock [StreakNotifier] so we can verify that [checkIn] is called.
class MockStreakNotifier extends Notifier<List<Streak>>
    with Mock
    implements StreakNotifier {
  final List<Streak> _initial;

  MockStreakNotifier(this._initial);

  @override
  List<Streak> build() => _initial;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Wraps [AnniversaryCard] in a testable widget tree with the given notifier.
Widget _buildAnniversaryCard(AnniversaryNotifier Function() createNotifier) {
  return ProviderScope(
    overrides: [anniversaryListProvider.overrideWith(createNotifier)],
    child: MaterialApp(
      theme: lightTheme,
      home: const Scaffold(
        body: SingleChildScrollView(child: AnniversaryCard()),
      ),
    ),
  );
}

/// Wraps [StreakCard] in a testable widget tree with the given notifier.
Widget _buildStreakCard(StreakNotifier Function() createNotifier) {
  return ProviderScope(
    overrides: [streakListProvider.overrideWith(createNotifier)],
    child: MaterialApp(
      theme: lightTheme,
      home: const Scaffold(
        body: SingleChildScrollView(child: StreakCard()),
      ),
    ),
  );
}

// ─── Test Suite ───────────────────────────────────────────────────────────────

void main() {
  // ─── AnniversaryCard ─────────────────────────────────────────────────────

  group('AnniversaryCard', () {
    testWidgets(
      'renders empty state prompt when anniversary list is empty',
      (tester) async {
        // Arrange — override the provider to return an empty list.
        await tester.pumpWidget(
          _buildAnniversaryCard(() => _FakeAnniversaryNotifier([])),
        );

        // Assert — the empty-state card shows a prompt to add an anniversary.
        expect(find.text('💕'), findsOneWidget);
        expect(
          find.text('Start tracking your\nspecial day'),
          findsOneWidget,
        );
        expect(
          find.text('Tap + to add your first anniversary'),
          findsOneWidget,
        );

        // The "days together" text should NOT be visible.
        expect(find.textContaining('days together'), findsNothing);
      },
    );

    testWidgets(
      'displays "days together" text when an Anniversary object is provided',
      (tester) async {
        // Arrange — create a test anniversary with a known start date.
        final testAnniversary = Anniversary(
          id: 'ann-1',
          title: 'Together Since',
          startDate: DateTime(2024, 1, 1),
          note: 'Our story begins',
        );
        final expectedDays = testAnniversary.daysSinceStart;

        await tester.pumpWidget(
          _buildAnniversaryCard(
            () => _FakeAnniversaryNotifier([testAnniversary]),
          ),
        );

        // Assert — day count is rendered.
        expect(find.text('$expectedDays'), findsOneWidget);

        // Assert — the "days together" / "day together" label is shown.
        expect(
          find.text(expectedDays == 1 ? 'day together' : 'days together'),
          findsOneWidget,
        );

        // Assert — the title is visible.
        expect(find.text('Together Since'), findsOneWidget);

        // Assert — the note is displayed, wrapped in quotes.
        expect(find.text('"Our story begins"'), findsOneWidget);

        // Assert — the empty-state prompt should NOT appear.
        expect(
          find.text('Tap + to add your first anniversary'),
          findsNothing,
        );
      },
    );
  });

  // ─── StreakCard ───────────────────────────────────────────────────────────

  group('StreakCard', () {
    testWidgets(
      'renders the correct currentStreak number',
      (tester) async {
        // Arrange — a streak with 42 consecutive days.
        final testStreak = Streak(
          id: 'str-1',
          title: 'Morning Run',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: DateTime(2024, 6, 2), // NOT today → button active.
          currentStreak: 42,
          longestStreak: 50,
        );

        await tester.pumpWidget(
          _buildStreakCard(() => _FakeStreakNotifier([testStreak])),
        );

        // Assert — the hero streak number is displayed.
        expect(find.text('42'), findsOneWidget);

        // Assert — plural "days streak" label (since 42 ≠ 1).
        expect(find.text('days streak'), findsOneWidget);

        // Assert — longest streak badge.
        expect(find.text('Best: 50 days'), findsOneWidget);

        // Assert — the title is visible.
        expect(find.text('Morning Run'), findsOneWidget);

        // Assert — the "Check In Today" button is visible (not checked in).
        expect(find.text('Check In Today'), findsOneWidget);
      },
    );

    testWidgets(
      'renders singular "day streak" label when currentStreak is 1',
      (tester) async {
        // Arrange — a streak with exactly 1 consecutive day.
        final testStreak = Streak(
          id: 'str-2',
          title: 'Read a Book',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: DateTime(2024, 6, 2),
          currentStreak: 1,
          longestStreak: 1,
        );

        await tester.pumpWidget(
          _buildStreakCard(() => _FakeStreakNotifier([testStreak])),
        );

        // Assert — singular label.
        expect(find.text('1'), findsOneWidget);
        expect(find.text('day streak'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping "Check In Today" calls checkIn on the mocked StreakNotifier',
      (tester) async {
        // Arrange — a streak whose lastCheckIn is NOT today, so the
        // button should be active.
        final testStreak = Streak(
          id: 'str-3',
          title: 'Meditation',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: DateTime(2020, 1, 1), // definitely not today
          currentStreak: 5,
          longestStreak: 10,
        );

        final mockNotifier = MockStreakNotifier([testStreak]);

        // Stub `checkIn` to succeed silently.
        when(() => mockNotifier.checkIn(any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          _buildStreakCard(() => mockNotifier),
        );

        // Sanity check — the button text is visible.
        expect(find.text('Check In Today'), findsOneWidget);

        // Act — simulate a tap on the "Check In Today" button.
        // The button uses GestureDetector with onTapUp, so we perform
        // a full tap gesture (tapDown + tapUp).
        await tester.tap(find.text('Check In Today'));
        await tester.pumpAndSettle();

        // Assert — checkIn was called exactly once with the streak id.
        verify(() => mockNotifier.checkIn('str-3')).called(1);
      },
    );

    testWidgets(
      'renders empty state prompt when streak list is empty',
      (tester) async {
        // Arrange — override the provider to return an empty list.
        await tester.pumpWidget(
          _buildStreakCard(() => _FakeStreakNotifier([])),
        );

        // Assert — the empty-state card shows a prompt.
        expect(find.text('🔥'), findsOneWidget);
        expect(
          find.text('Start building your\ndiscipline'),
          findsOneWidget,
        );
        expect(
          find.text('Tap + to create your first streak'),
          findsOneWidget,
        );

        // The streak counter should NOT be visible.
        expect(find.textContaining('days streak'), findsNothing);
        expect(find.textContaining('day streak'), findsNothing);
      },
    );

    testWidgets(
      'renders "Checked In Today" state when lastCheckIn is today',
      (tester) async {
        // Arrange — set lastCheckIn to today so the button should be disabled.
        final today = DateTime.now();
        final testStreak = Streak(
          id: 'str-4',
          title: 'Journaling',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: today,
          currentStreak: 7,
          longestStreak: 14,
        );

        await tester.pumpWidget(
          _buildStreakCard(() => _FakeStreakNotifier([testStreak])),
        );

        // Assert — "Checked In Today" is shown instead of the active button.
        expect(find.text('Checked In Today'), findsOneWidget);
        // The active "Check In Today" text should NOT appear.
        expect(find.text('Check In Today'), findsNothing);
      },
    );
  });
}

// ─── Fake Notifier Implementations ────────────────────────────────────────────

/// A simple [AnniversaryNotifier] that returns a predetermined list,
/// avoiding any Hive or repository dependencies.
class _FakeAnniversaryNotifier extends AnniversaryNotifier {
  final List<Anniversary> _initial;

  _FakeAnniversaryNotifier(this._initial);

  @override
  List<Anniversary> build() => _initial;
}

/// A simple [StreakNotifier] that returns a predetermined list,
/// avoiding any Hive or repository dependencies.
class _FakeStreakNotifier extends StreakNotifier {
  final List<Streak> _initial;

  _FakeStreakNotifier(this._initial);

  @override
  List<Streak> build() => _initial;
}
