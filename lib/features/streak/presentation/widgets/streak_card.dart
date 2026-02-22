import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';
import 'package:dayz/features/shared/presentation/widgets/card_options_sheet.dart';
import 'package:dayz/features/shared/presentation/widgets/safe_delete_dialog.dart';

/// Container widget that watches [streakListProvider] and renders
/// a [SingleStreakCard] for every streak, or an empty-state placeholder.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = ref.watch(streakListProvider);
    final theme = Theme.of(context);

    // Empty state.
    if (streaks.isEmpty) {
      return _EmptyStreakCard(theme: theme);
    }

    // Render ALL streaks as individual cards.
    return Column(
      children: [
        for (int i = 0; i < streaks.length; i++) ...[
          SingleStreakCard(streak: streaks[i]),
          if (i < streaks.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// A single streak card with tap-to-detail and long-press options.
class SingleStreakCard extends ConsumerWidget {
  const SingleStreakCard({super.key, required this.streak});

  final Streak streak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          GoRouter.of(context).push('/streak/${streak.id}');
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          CardOptionsSheet.show(
            context: context,
            onEdit: () {
              // TODO: Implement Edit Streak Sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Streak coming soon!')),
              );
            },
            onDelete: () async {
              final confirm = await SafeDeleteDialog.show(context);
              if (confirm) {
                ref.read(streakListProvider.notifier).delete(streak.id);
              }
            },
          );
        },
        borderRadius: cardBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: DisciplineColors.streakColors[
                streak.colorIndex % DisciplineColors.streakColors.length],
            borderRadius: cardBorderRadius,
            boxShadow: softCardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header.
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        streak.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: DisciplineColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Streak counter — hero.
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${streak.currentStreak}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 80,
                          fontWeight: FontWeight.w100,
                          color: DisciplineColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        streak.currentStreak == 1 ? 'day streak' : 'days streak',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: DisciplineColors.accent.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Longest streak badge.
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: DisciplineColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Best: ${streak.longestStreak} days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DisciplineColors.accent.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyStreakCard extends StatelessWidget {
  const _EmptyStreakCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DisciplineColors.streakColors[0],
        borderRadius: cardBorderRadius,
        boxShadow: softCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 16),
            Text(
              'Start building your\ndiscipline',
              style: theme.textTheme.titleMedium?.copyWith(
                color: DisciplineColors.accent.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first streak',
              style: theme.textTheme.bodySmall?.copyWith(
                color: DisciplineColors.accent.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
