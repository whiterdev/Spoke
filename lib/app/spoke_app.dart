import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'app_theme.dart';
import '../data/local/app_database_provider.dart';
import '../features/bikes/bikes_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/record/record_screen.dart';
import '../features/record/ride_bike_selection_screen.dart';
import '../features/routes/routes_screen.dart';

class SpokeApp extends StatelessWidget {
  const SpokeApp({super.key});

  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const RoutesScreen(),
          ),
          GoRoute(
            path: '/record',
            builder: (context, state) => const RideBikeSelectionScreen(),
          ),
          GoRoute(
            path: '/record/map',
            builder: (context, state) => RecordScreen(
              initialBikeId: int.tryParse(
                state.uri.queryParameters['bikeId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/bikes',
            builder: (context, state) => const BikesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Spoke',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    routerConfig: _router,
    builder: (context, child) => Consumer(
      builder: (context, ref, _) => ref
          .watch(riderProfileProvider)
          .when(
            data: (profile) => profile == null
                ? Navigator(
                    onGenerateRoute: (settings) => MaterialPageRoute<void>(
                      settings: settings,
                      builder: (_) => const OnboardingScreen(),
                    ),
                  )
                : child ?? const SizedBox.shrink(),
            loading: () => const _StartupScreen(),
            error: (error, stackTrace) => _StartupScreen(
              onRetry: () => ref.invalidate(riderProfileProvider),
            ),
          ),
    ),
  );
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: onRetry == null
          ? const CircularProgressIndicator(color: AppColors.accent)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No se pudo iniciar Spoke',
                  style: TextStyle(color: AppColors.primaryText),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: onRetry, child: const Text('Reintentar')),
              ],
            ),
    ),
  );
}
