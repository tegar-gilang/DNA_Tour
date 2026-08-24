import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../auth/presentation/auth_provider.dart';

class PilgrimProfileScreen extends ConsumerStatefulWidget {
  const PilgrimProfileScreen({super.key});

  @override
  ConsumerState<PilgrimProfileScreen> createState() => _PilgrimProfileScreenState();
}

class _PilgrimProfileScreenState extends ConsumerState<PilgrimProfileScreen> {
  bool _notificationsEnabled = true;
  bool _locationPermissionEnabled = true;
  String _selectedLanguage = 'English (Bahasa Indonesia)';

  void _showDigitalIdModal(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Kartu ID Digital Resmi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Diverifikasi Kementerian Haji & Umrah Saudi. Terhubung melalui Tour Leader.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Digital ID Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      user?.name ?? 'Jamaah Umrah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.groupCode ?? 'Kloter 4 VIP',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // QR Code SISKOPATUH
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=SISKOPATUH-${user?.id ?? '123456'}',
                        width: 150,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.qr_code_2,
                          size: 150,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan untuk verifikasi SISKOPATUH',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StatusBadge(label: 'TERVERIFIKASI & AKTIF', color: AppColors.successGreen),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Tutup Kartu'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Jamaah',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Identitas Jamaah, Itinerary & Riwayat Medis',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => _showDigitalIdModal(context, user),
                      icon: const Icon(LucideIcons.creditCard, size: 20, color: AppColors.successGreen),
                      tooltip: 'Digital ID Card',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Brief Hero Profile Summary Card (Same as Home Page without Prayer Reminder)
            RoleProfileSummaryCard(
              name: user?.name ?? 'H. Ahmad Zaki Al-Farizi',
              roleSubtitle: user?.groupCode ?? 'Kloter 4 Al-Barakah',
              avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
              isVerified: false,
              statusChips: const [],
              currentLocation: 'Masjidil Haram, Makkah',
              unreadCount: 3,
            ),
            const SizedBox(height: 26),

            // 1. Personal Information Section
            SectionHeader(title: 'Informasi Pribadi'),
            AppleCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildDetailRow(icon: LucideIcons.user, label: 'Nama Lengkap', value: user?.name ?? 'Jamaah Umrah'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.creditCard, label: 'ID Jamaah', value: user?.id ?? 'PL-88210'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.bookOpen, label: 'Nomor Paspor', value: 'X-99821014 (Berlaku)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.fileCheck, label: 'Nomor Visa Umrah', value: 'VSA-2026-99210-SA'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.flag, label: 'Kewarganegaraan', value: 'Indonesia'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.users, label: 'Jenis Kelamin', value: 'Pria (Male)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.calendar, label: 'Tanggal Lahir', value: '14 Mei 1978 (48 Thn)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.phone, label: 'Nomor Telepon', value: user?.phone ?? '+62 812-3456-7890'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.alertCircle, label: 'Kontak Darurat', value: 'Keluarga Jamaah (+62 811-9988-7766)'),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 2. Journey Information Section
            SectionHeader(title: 'Rincian Perjalanan'),
            AppleCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildDetailRow(icon: LucideIcons.users, label: 'Kloter Saat Ini', value: user?.groupCode ?? 'Kloter 4 Al-Barakah VIP'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.userCheck, label: 'Pembimbing (Mutawif)', value: 'Ust. H. Muhammad Ridwan (TL)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.user, label: 'Mutawif Lokal', value: 'Ust. Ibrahim Al-Madani'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.packageCheck, label: 'Paket Umrah', value: '12 Hari VIP Umrah Plus Ziyarah'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.building, label: 'Hotel Penginapan', value: user?.hotelName ?? 'Swissôtel Al Maqam Makkah'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.planeTakeoff, label: 'Tanggal Keberangkatan', value: '10 Juli 2026 (CGK - JED)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.planeLanding, label: 'Tanggal Kepulangan', value: '22 Juli 2026 (MED - CGK)'),
                ],
              ),
            ),
            const SizedBox(height: 26),


            // 5. Settings Section
            SectionHeader(title: 'Pengaturan Aplikasi'),
            AppleCard(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.globe, color: AppColors.primary, size: 20),
                    title: Text('Pilihan Bahasa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(_selectedLanguage, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              ListTile(
                                title: const Text('Bahasa Indonesia'),
                                onTap: () {
                                  setState(() => _selectedLanguage = 'Bahasa Indonesia');
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Bahasa Inggris (English)'),
                                onTap: () {
                                  setState(() => _selectedLanguage = 'Bahasa Inggris (English)');
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Bahasa Arab (العربية)'),
                                onTap: () {
                                  setState(() => _selectedLanguage = 'Bahasa Arab (العربية)');
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.moon, color: AppColors.secondaryDark, size: 20),
                    title: Text('Mode Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Sesuaikan tema warna tampilan aplikasi', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    value: currentThemeMode == ThemeMode.dark,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.bellRing, color: AppColors.infoBlue, size: 20),
                    title: Text('Notifikasi & Pemberitahuan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Peringatan sholat, jadwal kegiatan, dan siaran darurat', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.navigation, color: AppColors.successGreen, size: 20),
                    title: Text('Berbagi Lokasi GPS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Izinkan pemantauan real-time untuk Pembimbing & Keluarga', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    value: _locationPermissionEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _locationPermissionEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 6. Support Section
            SectionHeader(title: 'Bantuan & Ketentuan'),
            AppleCard(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  _buildSupportItem(icon: LucideIcons.helpCircle, title: 'Pusat Bantuan & Panduan', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka Pusat Bantuan...')))),
                  const Divider(height: 1, thickness: 0.5),
                  _buildSupportItem(icon: LucideIcons.fileQuestion, title: 'Pertanyaan Umum (FAQ)', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka FAQ Ibadah Umrah...')))),
                  const Divider(height: 1, thickness: 0.5),
                  _buildSupportItem(icon: LucideIcons.headphones, title: 'Hubungi Layanan Mutawif 24/7', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menghubungkan ke Tim Layanan Bantuan...')))),
                  const Divider(height: 1, thickness: 0.5),
                  _buildSupportItem(icon: LucideIcons.alertTriangle, title: 'Laporkan Kendala / Masalah', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka formulir pelaporan kendala...')))),
                  const Divider(height: 1, thickness: 0.5),
                  _buildSupportItem(icon: LucideIcons.fileText, title: 'Syarat & Ketentuan Layanan', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menampilkan Syarat & Ketentuan...')))),
                  const Divider(height: 1, thickness: 0.5),
                  _buildSupportItem(icon: LucideIcons.shieldCheck, title: 'Kebijakan Privasi', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menampilkan Kebijakan Privasi...')))),
                  const Divider(height: 1, thickness: 0.5),
                  ListTile(
                    leading: const Icon(LucideIcons.logOut, color: AppColors.emergencyRed, size: 20),
                    title: Text('Keluar dari Akun (Logout)', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w700, fontSize: 14)),
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 0.5),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 6,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimaryLight, size: 20),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.textSecondaryLight),
      onTap: onTap,
    );
  }
}
