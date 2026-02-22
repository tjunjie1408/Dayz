import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/streak/data/models/streak.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';

/// A beautifully themed screen displaying a streak's details,
/// including a custom monthly calendar for tracking history.
class StreakDetailScreen extends ConsumerWidget {
  const StreakDetailScreen({super.key, required this.streakId});

  final String streakId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streaks = ref.watch(streakListProvider);

    // Find the streak
    final streak = streaks.firstWhere(
      (s) => s.id == streakId,
      orElse: () => Streak(
        id: 'error',
        title: 'Not Found',
        startDate: DateTime.now(),
      ),
    );

    if (streak.id == 'error') {
      return Scaffold(
        appBar: AppBar(title: const Text('Streak Not Found')),
        body: const Center(child: Text('This streak could not be loaded.')),
      );
    }

    final isCheckedInToday = _isToday(streak.lastCheckIn);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (Header)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    streak.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DisciplineColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${streak.currentStreak}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 72,
                            fontWeight: FontWeight.w200,
                            color: DisciplineColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          streak.currentStreak == 1 ? 'day' : 'days',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: DisciplineColors.accent.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Middle Section (Calendar)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _StreakCalendar(
                  history: streak.history,
                  colorIndex: streak.colorIndex,
                ),
              ),
            ),

            // Bottom Section (Check-In Button)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SafeArea(
                top: false,
                child: _DetailCheckInButton(
                  isCheckedIn: isCheckedInToday,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    ref.read(streakListProvider.notifier).checkIn(streak.id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// A custom calendar widget displaying checked-in dates with soft pastel backgrounds.
class _StreakCalendar extends StatelessWidget {
  const _StreakCalendar({
    required this.history,
    required this.colorIndex,
  });

  final List<DateTime> history;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historySet = history
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: softCardShadow,
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: DateTime.now(),
        rowHeight: 42,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: DisciplineColors.accent,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: DisciplineColors.accent.withOpacity(0.5),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: DisciplineColors.accent.withOpacity(0.5),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: DisciplineColors.accent.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: DisciplineColors.accent.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        enabledDayPredicate: (day) {
          // Disable future dates
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dayNormalized = DateTime(day.year, day.month, day.day);
          return !dayNormalized.isAfter(today);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, historySet,
                isToday: false, colorIndex: colorIndex);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, historySet,
                isToday: true, colorIndex: colorIndex);
          },
          disabledBuilder: (context, day, focusedDay) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, Set<DateTime> historySet,
      {required bool isToday, required int colorIndex}) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final isCheckedIn = historySet.contains(normalizedDay);
    final streakColor = DisciplineColors
        .streakColors[colorIndex % DisciplineColors.streakColors.length];

    if (isCheckedIn) {
      return Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: streakColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: streakColor.withOpacity(0.6),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const Positioned(
              bottom: 2,
              right: 6,
              child: Text('🔥', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday ? Colors.grey.shade100 : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: DisciplineColors.accent.withOpacity(0.2), width: 1.5)
            : null,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

/// The prominent "Check-In" button for the detail screen.
class _DetailCheckInButton extends StatefulWidget {
  const _DetailCheckInButton({
    required this.isCheckedIn,
    required this.onPressed,
  });

  final bool isCheckedIn;
  final VoidCallback? onPressed;

  @override
  State<_DetailCheckInButton> createState() => _DetailCheckInButtonState();
}

class _DetailCheckInButtonState extends State<_DetailCheckInButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    if (!widget.isCheckedIn) {
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    if (widget.isCheckedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: DisciplineColors.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: DisciplineColors.accent.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Text(
              'Checked In Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DisciplineColors.accent.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: DisciplineColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: DisciplineColors.accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Check In Today',
                style: TextStyle(
                  fontSize: 18,
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
