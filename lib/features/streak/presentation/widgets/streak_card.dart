import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';

/// A calming card displaying the current streak with a prominent
/// "Check In Today" button and a cool mint/sky-blue gradient.
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

    final streak = streaks.first;
    final isCheckedInToday = _isToday(streak.lastCheckIn);

    return Container(
      decoration: BoxDecoration(
        gradient: DisciplineColors.cardGradient,
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

            const SizedBox(height: 24),

            // Check-in button.
            Center(
              child: _CheckInButton(
                isCheckedIn: isCheckedInToday,
                onPressed: isCheckedInToday
                    ? null
                    : () => ref
                        .read(streakListProvider.notifier)
                        .checkIn(streak.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Whether the given [date] is today (local time, date-only).
  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// ─── Check-In Button with Scale Animation ────────────────────────────────────

class _CheckInButton extends StatefulWidget {
  const _CheckInButton({
    required this.isCheckedIn,
    required this.onPressed,
  });

  final bool isCheckedIn;
  final VoidCallback? onPressed;

  @override
  State<_CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<_CheckInButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _controller.forward();

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    if (widget.isCheckedIn) {
      // Already checked in — show muted completed state.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: DisciplineColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: DisciplineColors.accent.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Checked In Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DisciplineColors.accent.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Active button with scale animation.
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: DisciplineColors.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DisciplineColors.accent.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 22,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Check In Today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
        gradient: DisciplineColors.cardGradient,
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
