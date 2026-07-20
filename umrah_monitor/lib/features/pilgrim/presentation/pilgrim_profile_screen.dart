import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';

class PilgrimProfileScreen extends ConsumerStatefulWidget {
  const PilgrimProfileScreen({super.key});

  @override
  ConsumerState<PilgrimProfileScreen> createState() => _PilgrimProfileScreenState();
}

class _PilgrimProfileScreenState extends ConsumerState<PilgrimProfileScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = true;
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
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Diverifikasi Kementerian Haji & Umrah Saudi. Terhubung melalui Tour Leader.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
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
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      user?.name ?? 'Jamaah Umrah',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${user?.id ?? 'PL-88210'} • ${user?.groupCode ?? 'Kloter 4 VIP'}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
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

  void _simulateDownloadPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(LucideIcons.fileDown, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Dokumen Berhasil Diunduh', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(
            'Dokumen lengkap Informasi Pribadi, Medis, dan Perjalanan Jamaah telah disusun dalam berkas PDF aman (\'Dossier_Jamaah_PL88210.pdf\') dan tersimpan di penyimpanan perangkat Anda.',
            style: GoogleFonts.outfit(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showDocumentPreview(BuildContext context, String title, String subtitle, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.shieldCheck, size: 48, color: AppColors.successGreen),
                  const SizedBox(height: 12),
                  Text('Dokumen Resmi Terverifikasi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Status: Berlaku hingga 25 Agu 2026\nBarcode: #8892-0012-KSA', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup Pratinjau'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
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
                          'Profil & Dokumen',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Identitas Jamaah, Itinerary & Riwayat Medis',
                          style: GoogleFonts.outfit(
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
              roleSubtitle: 'ID: ${user?.id ?? 'PL-88210'} • ${user?.groupCode ?? 'Kloter 4 Al-Barakah'}',
              avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
              isVerified: false,
              statusChips: const [
                RoleStatusChip(label: 'Jamaah Terverifikasi', iconColor: AppColors.successGreen, icon: LucideIcons.checkCircle2),
                RoleStatusChip(label: 'ID Digital Siap', iconColor: AppColors.secondaryLight, icon: LucideIcons.creditCard),
                RoleStatusChip(label: 'Kloter 4 VIP', iconColor: AppColors.infoBlue, icon: LucideIcons.shieldCheck),
              ],
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
                  _buildDetailRow(icon: LucideIcons.building, label: 'Hotel Penginapan', value: user?.hotelName ?? 'Swissôtel Al Maqam Makkah'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.bus, label: 'Bus Alokasi', value: user?.busNumber ?? 'Bus #08 Al-Safwa VIP Express'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.packageCheck, label: 'Paket Umrah', value: '12 Hari VIP Umrah Plus Ziyarah'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.planeTakeoff, label: 'Tanggal Keberangkatan', value: '10 Juli 2026 (CGK - JED)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.planeLanding, label: 'Tanggal Kepulangan', value: '22 Juli 2026 (MED - CGK)'),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 3. Medical Information Section
            SectionHeader(title: 'Ringkasan Medis'),
            AppleCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildDetailRow(icon: LucideIcons.heartPulse, label: 'Golongan Darah', value: 'O+ (Positif)'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.alertTriangle, label: 'Riwayat Alergi', value: 'Penisilin / Debu'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.clipboardList, label: 'Catatan Kesehatan', value: 'Hipertensi terkontrol dengan rutin minum obat harian'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.pill, label: 'Jadwal Obat Harian', value: 'Amlodipine 5mg • Setiap hari pukul 08:00 AST'),
                  _buildDivider(),
                  _buildDetailRow(icon: LucideIcons.shieldCheck, label: 'Polis Asuransi', value: 'Takaful Global #TK-9921-UM'),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 4. Documents Section
            SectionHeader(title: 'Dokumen Resmi'),
            AppleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDocumentCard(
                    title: 'Paspor Elektronik',
                    subtitle: 'No: X-99821014 • Terverifikasi',
                    icon: LucideIcons.bookOpen,
                    color: AppColors.primaryDark,
                    onTap: () => _showDocumentPreview(context, 'Paspor Elektronik', 'Paspor Elektronik Resmi Republik Indonesia', LucideIcons.bookOpen),
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentCard(
                    title: 'Visa Umrah Elektronik',
                    subtitle: 'No: VSA-2026-99210-SA • Single Entry',
                    icon: LucideIcons.fileCheck,
                    color: AppColors.secondaryDark,
                    onTap: () => _showDocumentPreview(context, 'Visa Umrah Elektronik', 'Diterbitkan oleh Kementerian Haji dan Umrah Arab Saudi', LucideIcons.fileCheck),
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentCard(
                    title: 'E-Tiket Penerbangan',
                    subtitle: 'Garuda GA-981 / GA-982 • Terkonfirmasi',
                    icon: LucideIcons.plane,
                    color: AppColors.infoBlue,
                    onTap: () => _showDocumentPreview(context, 'E-Tiket Penerbangan', 'Tiket Pulang Pergi Jakarta - Jeddah - Madinah', LucideIcons.plane),
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentCard(
                    title: 'Voucher Akomodasi Hotel',
                    subtitle: 'Swissôtel Al Maqam / Oberoi Madinah',
                    icon: LucideIcons.building,
                    color: AppColors.primaryLight,
                    onTap: () => _showDocumentPreview(context, 'Voucher Hotel', 'Reservasi Terjamin Kamar Sekamar Empat VIP', LucideIcons.building),
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentCard(
                    title: 'Kartu ID Digital',
                    subtitle: 'Kartu Verifikasi Resmi Nusuk & UmrahSys',
                    icon: LucideIcons.badgeCheck,
                    color: AppColors.successGreen,
                    onTap: () => _showDigitalIdModal(context, user),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _simulateDownloadPdf(context),
                      icon: const Icon(LucideIcons.download, size: 16),
                      label: const Text('Unduh Dokumen PDF Lengkap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
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
                    title: Text('Pilihan Bahasa', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(_selectedLanguage, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
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
                    title: Text('Mode Gelap (Dark Mode)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Sesuaikan tema warna tampilan aplikasi', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                    value: _darkMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferensi tema diperbarui.')));
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.bellRing, color: AppColors.infoBlue, size: 20),
                    title: Text('Notifikasi & Pemberitahuan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Peringatan sholat, jadwal kegiatan, dan siaran darurat', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.fingerprint, color: AppColors.primaryDark, size: 20),
                    title: Text('Masuk dengan Biometrik', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Akses cepat menggunakan Face ID / Sidik Jari', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                    value: _biometricsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _biometricsEnabled = val),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.navigation, color: AppColors.successGreen, size: 20),
                    title: Text('Berbagi Lokasi GPS', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Izinkan pemantauan real-time untuk Pembimbing & Keluarga', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
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
                    title: Text('Keluar dari Akun (Logout)', style: GoogleFonts.outfit(color: AppColors.emergencyRed, fontWeight: FontWeight.w700, fontSize: 14)),
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
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
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
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimaryLight, size: 20),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.textSecondaryLight),
      onTap: onTap,
    );
  }
}
