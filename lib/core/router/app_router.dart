import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';

/// Application router configuration.
///
/// Uses [GoRouter] with a single route (`/`) pointing to [HomeScreen].
/// Exposed as a Riverpod provider so it can be consumed by the root [App]
/// widget via `ref.watch`.
final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  ),
);
