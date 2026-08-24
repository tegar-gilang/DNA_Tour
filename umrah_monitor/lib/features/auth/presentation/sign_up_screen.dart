import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/user_model.dart';
import 'auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _passportController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _groupCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi Nama Lengkap, Email, dan Kata Sandi.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok. Silakan periksa kembali.')),
      );
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Ketentuan Layanan & Kebijakan Privasi.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Mengalihkan ke Dasbor...'),
          backgroundColor: AppColors.successGreen,
        ),
      );

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
    final selectedRole = ref.watch(authProvider).selectedRole ?? UserRole.pilgrim;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        title: Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Role Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedRole == UserRole.pilgrim
                          ? LucideIcons.userCheck
                          : (selectedRole == UserRole.family ? LucideIcons.heartHandshake : LucideIcons.flag),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mendaftar sebagai: ${selectedRole.displayNameID}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Lengkapi Data Diri',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Isi formulir di bawah ini agar terhubung secara aman dengan kloter, mutawif, dan pemantauan keluarga.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Form Container
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Nama Lengkap sesuai Paspor / KTP', isDark),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Contoh: H. Ahmad Zaki Al-Farizi',
                      icon: LucideIcons.user,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel('Nomor Paspor / NIK', isDark),
                    _buildTextField(
                      controller: _passportController,
                      hint: 'Nomor paspor atau NIK KTP Anda',
                      icon: LucideIcons.creditCard,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel('Alamat Email Aktif', isDark),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'email.anda@domain.com',
                      icon: LucideIcons.mail,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel('Nomor Telepon / WhatsApp Aktif', isDark),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+62 812-xxxx-xxxx',
                      icon: LucideIcons.phone,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel('Kode Kloter / Rombongan (Opsional)', isDark),
                    _buildTextField(
                      controller: _groupCodeController,
                      hint: 'Contoh: Kloter 4 Al-Barakah',
                      icon: LucideIcons.users,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel('Kata Sandi Baru', isDark),
                    _buildPasswordField(
                      controller: _passwordController,
                      hint: 'Minimal 8 karakter',
                      obscure: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel('Konfirmasi Kata Sandi', isDark),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Ulangi kata sandi di atas',
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // Terms check
                    InkWell(
                      onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeTerms,
                              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Saya menyetujui Ketentuan Layanan, Kebijakan Privasi, dan Berbagi Lokasi Real-Time DNA Tour.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Daftar & Aktifkan Akun',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.arrowRight, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Back to Login link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah memiliki akun?',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Masuk di Sini',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimaryLight),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimaryLight),
        decoration: InputDecoration(
          prefixIcon: const Icon(LucideIcons.lock, size: 18, color: AppColors.textSecondaryLight),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: AppColors.textSecondaryLight,
            ),
            onPressed: onToggle,
          ),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
