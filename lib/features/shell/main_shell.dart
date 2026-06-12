import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/offline_banner.dart';
import '../alerts/alerts_screen.dart';
import '../analytics/analytics_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../device/device_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Global offline banner — slides in automatically when offline
          const OfflineBanner(),
          // Main tab content
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.ring_volume_outlined),
            selectedIcon: Icon(Icons.ring_volume),
            label: 'Device',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

List<Widget> get mainShellBranches => const [
      DashboardScreen(),
      AnalyticsScreen(),
      AlertsScreen(),
      DeviceScreen(),
      ProfileScreen(),
    ];
