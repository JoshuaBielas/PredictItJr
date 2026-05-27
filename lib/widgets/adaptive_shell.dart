import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double kWideBreakpoint = 600.0;

class _TabDestination {
  const _TabDestination({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

const _tabs = [
  _TabDestination(label: 'Markets', icon: Icons.show_chart),
  _TabDestination(label: 'Portfolio', icon: Icons.account_balance_wallet),
  _TabDestination(label: 'Profile', icon: Icons.person),
];

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    // Decide on WIDTH, not Platform. Rotate the emulator and this
    // re-runs with a different `width` — the layout switches live.
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= kWideBreakpoint;
    return wide ? _wide(context) : _narrow(context);
  }

  Widget _narrow(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }

  Widget _wide(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _go,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final t in _tabs)
                NavigationRailDestination(
                  icon: Icon(t.icon),
                  label: Text(t.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}