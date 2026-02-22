import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';
import 'package:dayz/features/streak/presentation/screens/streak_detail_screen.dart';

// ─── Mock Notifiers ───────────────────────────────────────────────────────────

class MockStreakNotifier extends Notifier<List<Streak>>
    with Mock
    implements StreakNotifier {
  final List<Streak> _initial;

  MockStreakNotifier(this._initial);

  @override
  List<Streak> build() => _initial;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildStreakDetailScreen(MockStreakNotifier notifier, String streakId) {
  return ProviderScope(
    overrides: [streakListProvider.overrideWith(() => notifier)],
    child: MaterialApp(
      theme: lightTheme,
      home: StreakDetailScreen(streakId: streakId),
    ),
  );
}

// ─── Test Suite ───────────────────────────────────────────────────────────────

void main() {
  group('StreakDetailScreen', () {
    testWidgets(
      'renders Not Found state when streakid is missing',
      (tester) async {
        final mockNotifier = MockStreakNotifier([]);

        await tester.pumpWidget(
          _buildStreakDetailScreen(mockNotifier, 'non-existent-id'),
        );

        expect(find.text('Streak Not Found'), findsOneWidget);
        expect(find.text('This streak could not be loaded.'), findsOneWidget);
      },
    );

    testWidgets(
      'renders the streak detail correctly',
      (tester) async {
        final streak = Streak(
          id: 'str-1',
          title: 'Daily Writing',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: DateTime(2024, 6, 1), // not today
          currentStreak: 15,
          history: [DateTime(2024, 6, 1)],
        );

        final mockNotifier = MockStreakNotifier([streak]);

        await tester.pumpWidget(
          _buildStreakDetailScreen(mockNotifier, 'str-1'),
        );

        expect(find.text('Daily Writing'), findsOneWidget);
        expect(find.text('15'), findsWidgets); // currentStreak and potentially day 15 on calendar
        expect(find.text('days'), findsOneWidget);

        // the "Check In Today" text should be present.
        expect(find.text('Check In Today'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping "Check In Today" calls checkIn on notifier',
      (tester) async {
        final testStreak = Streak(
          id: 'str-2',
          title: 'Yoga',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: DateTime(2020, 1, 1), // not today
          currentStreak: 5,
        );

        final mockNotifier = MockStreakNotifier([testStreak]);
        when(() => mockNotifier.checkIn(any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          _buildStreakDetailScreen(mockNotifier, 'str-2'),
        );

        await tester.tap(find.text('Check In Today'));
        await tester.pumpAndSettle();

        verify(() => mockNotifier.checkIn('str-2')).called(1);
      },
    );

    testWidgets(
      'renders "Checked In Today" state when lastCheckIn is today',
      (tester) async {
        final today = DateTime.now();
        final testStreak = Streak(
          id: 'str-3',
          title: 'Coding',
          startDate: DateTime(2024, 6, 1),
          lastCheckIn: today,
          currentStreak: 7,
          history: [today],
        );

        final mockNotifier = MockStreakNotifier([testStreak]);

        await tester.pumpWidget(
          _buildStreakDetailScreen(mockNotifier, 'str-3'),
        );

        expect(find.text('Checked In Today'), findsOneWidget);
        expect(find.text('Check In Today'), findsNothing);
      },
    );
  });
}
