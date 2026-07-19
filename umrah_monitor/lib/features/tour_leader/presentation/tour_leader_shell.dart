import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/custom_widgets.dart';

class TourLeaderShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const TourLeaderShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppleGlassNavbar(
        currentIndex: navigationShell.currentIndex,
        onItemSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        items: const [
          AppleNavbarItem(icon: LucideIcons.layoutDashboard, label: 'Dasbor'),
          AppleNavbarItem(icon: LucideIcons.users, label: 'Jamaah'),
          AppleNavbarItem(icon: LucideIcons.calendarRange, label: 'Jadwal'),
          AppleNavbarItem(icon: LucideIcons.mapPin, label: 'Peta'),
          AppleNavbarItem(icon: LucideIcons.user, label: 'Profil'),
        ],
      ),
    );
  }
}
