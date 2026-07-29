import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go('/role_selection');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque_rounded,
                size: 72,
                color: AppColors.secondaryLight,
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 24),
            Text(
              'DNA Tour',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).moveY(begin: 15, end: 0),
            const SizedBox(height: 8),
            Text(
              'Platform Terpadu Pemantauan & Panduan Ibadah Umrah',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.2,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
