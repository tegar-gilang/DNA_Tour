import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/user_model.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(authProvider).selectedRole ?? UserRole.pilgrim;
      if (role == UserRole.pilgrim) {
        _idController.text = UserModel.demoPilgrim.id;
      } else if (role == UserRole.family) {
        _idController.text = UserModel.demoFamily.id;
      } else {
        _idController.text = UserModel.demoTourLeader.id;
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    await ref.read(authProvider.notifier).login(
          id: _idController.text.trim(),
        );

    if (mounted) {
      final role = ref.read(authProvider).selectedRole ?? UserRole.pilgrim;
      if (role == UserRole.pilgrim) {
        context.go('/pilgrim');
      } else if (role == UserRole.family) {
        context.go('/family');
      } else {
        context.go('/tour_leader');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final selectedRole = authState.selectedRole ?? UserRole.pilgrim;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String getRoleIdLabel() {
      if (selectedRole == UserRole.pilgrim) return 'ID Jamaah';
      if (selectedRole == UserRole.family) return 'ID Keluarga';
      return 'ID Pembimbing';
    }
    final idLabel = getRoleIdLabel();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Sleek Role & Status Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedRole == UserRole.pilgrim
                              ? LucideIcons.userCheck
                              : (selectedRole == UserRole.family ? LucideIcons.heartHandshake : LucideIcons.shieldCheck),
                          size: 16,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Akses Peran: ${selectedRole.displayNameID}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),

              // Title Greeting
              Text(
                'Assalamu\'alaikum,',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Silakan masuk untuk mengakses dasbor pemantauan, lokasi real-time, dan layanan ibadah Umrah Anda.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Minimalist Apple Glass Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _idController,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(LucideIcons.user, size: 19, color: AppColors.primary),
                          hintText: 'Masukkan $idLabel Anda',
                          hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondaryLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: authState.isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: authState.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Masuk ke Dasbor',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.arrowRight, size: 22, color: Colors.white),
                    ],
                  ),
          ),
        ),
    ],
  ),
),
);
  }
}
