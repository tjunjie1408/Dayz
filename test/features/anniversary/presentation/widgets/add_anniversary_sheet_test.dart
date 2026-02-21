import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/data/models/anniversary.dart';
import 'package:dayz/features/anniversary/presentation/providers/anniversary_provider.dart';
import 'package:dayz/features/anniversary/presentation/widgets/add_anniversary_sheet.dart';

// ─── Mock Notifier ────────────────────────────────────────────────────────────

class MockAnniversaryNotifier extends Notifier<List<Anniversary>>
    with Mock
    implements AnniversaryNotifier {
  @override
  List<Anniversary> build() => [];
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildTestApp(AnniversaryNotifier mockNotifier) {
  return ProviderScope(
    overrides: [
      anniversaryListProvider.overrideWith(() => mockNotifier),
    ],
    child: MaterialApp(
      theme: lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Background'),
        ),
      ),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockAnniversaryNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockAnniversaryNotifier();
  });

  group('AddAnniversarySheet', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(_buildTestApp(mockNotifier));

      // Show the sheet by accessing the scaffold context
      final BuildContext context = tester.element(find.byType(Scaffold));
      AddAnniversarySheet.show(context);
      await tester.pumpAndSettle();

      expect(find.byType(AddAnniversarySheet), findsOneWidget);
      expect(find.text('New Anniversary 💕'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Note (Optional)'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('date picker opens when date row is tapped', (tester) async {
      await tester.pumpWidget(_buildTestApp(mockNotifier));

      final BuildContext context = tester.element(find.byType(Scaffold));
      AddAnniversarySheet.show(context);
      await tester.pumpAndSettle();

      // Tap the date selector row
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pumpAndSettle();

      // Verify the date picker dialog is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Select a date
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      // Select Date text should be replaced by a formatted date, so "Select Date" should be gone
      expect(find.text('Select Date'), findsNothing);
    });

    testWidgets('tapping save calls add on notifier and closes sheet', (tester) async {
      when(() => mockNotifier.add(
            title: any(named: 'title'),
            startDate: any(named: 'startDate'),
            note: any(named: 'note'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestApp(mockNotifier));

      final BuildContext context = tester.element(find.byType(Scaffold));
      AddAnniversarySheet.show(context);
      await tester.pumpAndSettle();

      // Enter Title
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'First Met',
      );

      // Enter Note
      await tester.enterText(
        find.widgetWithText(TextField, 'Note (Optional)'),
        'Cafe context',
      );

      // Select Date
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify notifier was called
      verify(() => mockNotifier.add(
            title: 'First Met',
            startDate: any(named: 'startDate'),
            note: 'Cafe context',
          )).called(1);

      // Verify sheet is closed
      expect(find.byType(AddAnniversarySheet), findsNothing);
    });

    testWidgets('does nothing if title or date is empty', (tester) async {
      await tester.pumpWidget(_buildTestApp(mockNotifier));

      final BuildContext context = tester.element(find.byType(Scaffold));
      AddAnniversarySheet.show(context);
      await tester.pumpAndSettle();

      // Try saving without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify no add called
      verifyNever(() => mockNotifier.add(
            title: any(named: 'title'),
            startDate: any(named: 'startDate'),
            note: any(named: 'note'),
          ));

      // Verify sheet remains open
      expect(find.byType(AddAnniversarySheet), findsOneWidget);
    });
  });
}
