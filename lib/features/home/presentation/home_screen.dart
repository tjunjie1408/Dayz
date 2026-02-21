import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/presentation/widgets/anniversary_card.dart';
import 'package:dayz/features/streak/presentation/widgets/streak_card.dart';

/// The main home screen of the Dayz app.
///
/// Displays the [AnniversaryCard] at the top, followed by the
/// [StreakCard], inside a vertically scrolling list with generous padding.
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
    );
  }
}
