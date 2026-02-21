import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/presentation/widgets/anniversary_card.dart';
import 'package:dayz/features/streak/presentation/providers/streak_provider.dart';
import 'package:dayz/features/streak/presentation/widgets/streak_card.dart';

/// The main home screen of the Dayz app.
///
/// Displays the [AnniversaryCard] at the top, followed by the
/// [StreakCard], inside a vertically scrolling list with generous padding.
/// A FAB opens a themed "Add Streak" dialog.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // App header.
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Dayz',
                      style:
                          Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    const Spacer(),
                    // Subtle settings icon.
                    IconButton(
                      onPressed: () {
                        // TODO: Navigate to settings.
                      },
                      icon: Icon(
                        Icons.tune_rounded,
                        color: CanvasColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card list.
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.list(
                children: const [
                  SizedBox(height: 12),

                  // Anniversary card — romantic hero.
                  AnniversaryCard(),

                  SizedBox(height: 20),

                  // Streak card — discipline tracker.
                  StreakCard(),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),

      // ─── Floating Action Button ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        key: const Key('addStreakFab'),
        onPressed: () => _showAddStreakDialog(context, ref),
        backgroundColor: DisciplineColors.accent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // ─── Add Streak Dialog ────────────────────────────────────────────────────

  void _showAddStreakDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: CanvasColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog header.
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      'New Streak',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: DisciplineColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Title input field.
                TextField(
                  key: const Key('streakTitleField'),
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: CanvasColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Morning Run, Reading…',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: CanvasColors.textMuted,
                    ),
                    filled: true,
                    fillColor: CanvasColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: DisciplineColors.accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Action buttons.
                Row(
                  children: [
                    // Cancel.
                    Expanded(
                      child: TextButton(
                        key: const Key('cancelStreakBtn'),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: CanvasColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Save button.
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('saveStreakBtn'),
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          ref.read(streakListProvider.notifier).add(
                                title: title,
                                startDate: DateTime.now(),
                              );

                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DisciplineColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
