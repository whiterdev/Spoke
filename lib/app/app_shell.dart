import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _paths = ['/', '/routes', '/record', '/bikes', '/profile'];

  int get _selectedIndex {
    if (location == '/record' || location.startsWith('/record/')) return 2;
    final index = _paths.indexOf(location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => context.go(_paths[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.route_outlined),
          selectedIcon: Icon(Icons.route_rounded),
          label: 'Historial',
        ),
        NavigationDestination(
          icon: _RecordNavIcon(),
          selectedIcon: _RecordNavIcon(),
          label: 'Grabar',
        ),
        NavigationDestination(
          icon: Icon(Icons.pedal_bike_outlined),
          selectedIcon: Icon(Icons.pedal_bike_rounded),
          label: 'Bicis',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    ),
  );
}

class _RecordNavIcon extends StatelessWidget {
  const _RecordNavIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Icon(
      Icons.play_arrow_rounded,
      color: AppColors.background,
      size: 23,
    ),
  );
}
