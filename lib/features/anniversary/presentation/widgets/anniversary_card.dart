import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/presentation/providers/anniversary_provider.dart';

import 'add_anniversary_sheet.dart';

/// A visually striking card showing "Days Together" with a romantic
/// peach/pink gradient and large day counter typography.
class AnniversaryCard extends ConsumerWidget {
  const AnniversaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anniversaries = ref.watch(anniversaryListProvider);
    final theme = Theme.of(context);

    // Empty state — gentle prompt to create first anniversary.
    if (anniversaries.isEmpty) {
      return _EmptyAnniversaryCard(theme: theme);
    }

    final anniversary = anniversaries.first;
    final days = anniversary.daysSinceStart;
    final formattedDate = DateFormat.yMMMd().format(anniversary.startDate);

    return Container(
      decoration: BoxDecoration(
        gradient: RomanticColors.cardGradient,
        borderRadius: cardBorderRadius,
        boxShadow: softCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with emoji, title, and add button.
            Row(
              children: [
                const Text('💕', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    anniversary.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: RomanticColors.roseDark.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => AddAnniversarySheet.show(context),
                  icon: const Icon(Icons.edit_calendar),
                  color: RomanticColors.roseDark.withValues(alpha: 0.7),
                  tooltip: 'Edit Anniversary',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // The big day counter — hero element.
            Center(
              child: Column(
                children: [
                  Text(
                    '$days',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.w100,
                      color: RomanticColors.roseDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days == 1 ? 'day together' : 'days together',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: RomanticColors.roseDark.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Footer — start date.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: RomanticColors.roseDark.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 6),
                Text(
                  'Since $formattedDate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: RomanticColors.roseDark.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),

            // Optional note.
            if (anniversary.note != null &&
                anniversary.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '"${anniversary.note}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: RomanticColors.roseDark.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Placeholder card when no anniversary has been created yet.
class _EmptyAnniversaryCard extends StatelessWidget {
  const _EmptyAnniversaryCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RomanticColors.cardGradient,
        borderRadius: cardBorderRadius,
        boxShadow: softCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => AddAnniversarySheet.show(context),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 28,
                color: RomanticColors.roseDark.withValues(alpha: 0.7),
                tooltip: 'Add Anniversary',
              ),
            ),
            const Text('💕', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 16),
            Text(
              'Start tracking your\nspecial day',
              style: theme.textTheme.titleMedium?.copyWith(
                color: RomanticColors.roseDark.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first anniversary',
              style: theme.textTheme.bodySmall?.copyWith(
                color: RomanticColors.roseDark.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
