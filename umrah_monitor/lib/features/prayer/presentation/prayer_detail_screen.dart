import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/prayer_model.dart';

class PrayerDetailScreen extends StatelessWidget {
  final PrayerModel prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doa & Dzikir')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.lock, size: 48, color: AppColors.textTertiaryLight),
              const SizedBox(height: 16),
              const Text(
                'Fitur Read Full & Virtues telah dinonaktifkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali ke Kumpulan Doa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
