import 'package:flutter/material.dart';
import '../../pilgrim/presentation/pilgrim_schedule_screen.dart';

class FamilyUpdatesScreen extends StatelessWidget {
  const FamilyUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PilgrimScheduleScreen(isFamilyView: true);
  }
}
