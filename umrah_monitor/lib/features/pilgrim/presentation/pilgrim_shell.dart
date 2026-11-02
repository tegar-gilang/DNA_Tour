import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/custom_widgets.dart';

class PilgrimShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PilgrimShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppleGlassNavbar(
        currentIndex: navigationShell.currentIndex,
        onItemSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          AppleNavbarItem(icon: Icons.home_rounded, label: 'Beranda'),
          AppleNavbarItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
          AppleNavbarItem(icon: Icons.map_rounded, label: 'Peta'),
          AppleNavbarItem(icon: Icons.campaign_rounded, label: 'Pesan'),
          AppleNavbarItem(icon: Icons.person_rounded, label: 'Profil'),
        ],
      ),
    );
  }
}
