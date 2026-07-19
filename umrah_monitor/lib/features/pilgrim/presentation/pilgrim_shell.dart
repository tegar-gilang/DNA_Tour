import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        items: const [
          AppleNavbarItem(icon: LucideIcons.home, label: 'Beranda'),
          AppleNavbarItem(icon: LucideIcons.calendar, label: 'Jadwal'),
          AppleNavbarItem(icon: LucideIcons.mapPin, label: 'Peta'),
          AppleNavbarItem(icon: LucideIcons.messageSquare, label: 'Pesan'),
          AppleNavbarItem(icon: LucideIcons.user, label: 'Profil'),
        ],
      ),
    );
  }
}
