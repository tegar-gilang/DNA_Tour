import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/user_model.dart';
import 'auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final selectedRole = authState.selectedRole ?? UserRole.pilgrim;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // App Logo / Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.compass, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'DNA Tour Platform',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 52),
              Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih peran Anda untuk memuat dasbor pemantauan, izin akses, serta layanan ibadah secara terpadu dan real-time.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRoleCard(
                      context: context,
                      role: UserRole.pilgrim,
                      title: UserRole.pilgrim.displayNameID,
                      description: UserRole.pilgrim.descriptionID,
                      icon: LucideIcons.user,
                      isSelected: selectedRole == UserRole.pilgrim,
                      onTap: () => ref.read(authProvider.notifier).selectRole(UserRole.pilgrim),
                    ),
                    const SizedBox(height: 14),
                    _buildRoleCard(
                      context: context,
                      role: UserRole.family,
                      title: UserRole.family.displayNameID,
                      description: UserRole.family.descriptionID,
                      icon: LucideIcons.heartHandshake,
                      isSelected: selectedRole == UserRole.family,
                      onTap: () => ref.read(authProvider.notifier).selectRole(UserRole.family),
                    ),
                    const SizedBox(height: 14),
                    _buildRoleCard(
                      context: context,
                      role: UserRole.tourLeader,
                      title: UserRole.tourLeader.displayNameID,
                      description: UserRole.tourLeader.descriptionID,
                      icon: LucideIcons.flag,
                      isSelected: selectedRole == UserRole.tourLeader,
                      onTap: () => ref.read(authProvider.notifier).selectRole(UserRole.tourLeader),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    elevation: 6,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjutkan ke Halaman Masuk',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                      ),
                      const SizedBox(width: 10),
                      const Icon(LucideIcons.arrowRight, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryDark.withValues(alpha: 0.3) : AppColors.primaryContainer)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.8)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.08)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected && !isDark ? AppColors.primaryDark : (isDark ? Colors.white : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isSelected && !isDark
                          ? AppColors.primaryDark.withValues(alpha: 0.8)
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
