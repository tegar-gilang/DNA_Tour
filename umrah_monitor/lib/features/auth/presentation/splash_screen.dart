import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/user_model.dart';
import 'auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final timerFuture = Future.delayed(const Duration(milliseconds: 2200));
    final sessionFuture = ref.read(authProvider.notifier).restoreSession();

    await Future.wait([timerFuture, sessionFuture]);

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      if (authState.selectedRole == UserRole.tourLeader) {
        context.go('/tour_leader');
        return;
      } else if (authState.selectedRole == UserRole.family) {
        context.go('/family');
        return;
      } else if (authState.selectedRole == UserRole.pilgrim) {
        context.go('/pilgrim');
        return;
      }
    }

    context.go('/role_selection');
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
                    blurRadius: 6,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque_rounded,
                size: 72,
                color: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DNA Tour',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform Terpadu Pemantauan & Panduan Ibadah Umrah',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
