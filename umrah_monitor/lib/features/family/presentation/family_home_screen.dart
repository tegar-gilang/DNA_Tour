import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';

class FamilyHomeScreen extends ConsumerStatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  ConsumerState<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends ConsumerState<FamilyHomeScreen> {
  void _showDigitalIdModal(BuildContext context) {
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
                'Kartu ID Digital Jamaah (Akses Keluarga)',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Diverifikasi Kementerian Haji & Umrah Saudi. Digunakan untuk identifikasi resmi jamaah terhubung.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      'H. Ahmad Zaki Al-Farizi',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID Gelang: PL-88210 • Kloter 4 VIP Al-Barakah',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatusBadge(label: 'TERVERIFIKASI & DIPANTAU KELUARGA', color: AppColors.successGreen),
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
              Text('Rekap Dokumen Diunduh', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(
            'Berkas lengkap Informasi Pribadi, Paspor, Visa, Riwayat Medis, dan Itinerary Jamaah H. Ahmad Zaki Al-Farizi telah disimpan dalam PDF aman (\'Dossier_Jamaah_PL88210.pdf\') di perangkat keluarga Anda.',
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
                  Text('Status: Berlaku hingga 25 Agu 2026\nBarcode: #8892-0012-KSA\nAkses: Pemantau Keluarga Terdaftar', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pilgrim Hero Summary Card without verified icon
                RoleProfileSummaryCard(
                  name: 'H. Ahmad Zaki Al-Farizi',
                  roleSubtitle: 'Jamaah Terhubung • Suami (${user?.name ?? "Siti Rahma"})',
                  avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                  isVerified: false,
                  statusChips: const [
                    RoleStatusChip(label: 'Aman & Sehat', iconColor: AppColors.successGreen, icon: Icons.check_circle),
                    RoleStatusChip(label: 'GPS Aktif', iconColor: AppColors.infoBlue, icon: LucideIcons.navigation),
                  ],
                  currentLocation: 'Masjidil Haram, Makkah',
                  lastUpdatedText: 'Diperbarui 2 mnt lalu',
                  unreadCount: 3,
                ).animate().fadeIn().scale(duration: 400.ms),
                const SizedBox(height: 24),

                // 1. Personal Information Section (Full & Detailed as in Pilgrim Page)
                SectionHeader(title: 'Informasi Pribadi Jamaah (Hanya Baca)'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildDetailRow(icon: LucideIcons.user, label: 'Nama Lengkap Jamaah', value: 'H. Ahmad Zaki Al-Farizi'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.creditCard, label: 'ID Gelang Jamaah', value: 'PL-88210 (Terverifikasi)'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.heartHandshake, label: 'Hubungan Keluarga', value: 'Suami / Kepala Keluarga'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.bookOpen, label: 'Nomor Paspor', value: 'X-99821014 (Berlaku 2030)'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.fileCheck, label: 'Nomor Visa Umrah', value: 'VSA-2026-99210-SA'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.flag, label: 'Kewarganegaraan', value: 'Indonesia'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.users, label: 'Jenis Kelamin & Usia', value: 'Pria • 48 Thn (14 Mei 1978)'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.phone, label: 'Telepon Jamaah', value: '+62 812-3456-7890'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.phoneCall, label: 'Kontak Darurat Terdaftar', value: 'Siti Rahma (+62 811-9988-7766)'),
                    ],
                  ),
                ).animate().fadeIn(delay: 125.ms),
                const SizedBox(height: 24),

                // 2. Journey Information Section
                SectionHeader(title: 'Rincian Perjalanan & Logistik Jamaah'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildDetailRow(icon: LucideIcons.users, label: 'Kloter & Rombongan', value: 'Kloter 4 Al-Barakah VIP'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.userCheck, label: 'Pembimbing Utama (Mutawif)', value: 'Ust. H. Muhammad Ridwan (TL)'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.user, label: 'Mutawif Lokal Makkah', value: 'Ust. Ibrahim Al-Madani'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.building, label: 'Hotel Penginapan Makkah', value: 'Swissôtel Al Maqam • Kamar 1408'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.building2, label: 'Hotel Penginapan Madinah', value: 'Oberoi Madinah • Kamar 512'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.bus, label: 'Bus Alokasi', value: 'Bus #08 Al-Safwa VIP Express'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.planeTakeoff, label: 'Tanggal Keberangkatan', value: '10 Juli 2026 (CGK - JED)'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.planeLanding, label: 'Tanggal Kepulangan', value: '22 Juli 2026 (MED - CGK)'),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // 3. Medical Information Section
                SectionHeader(title: 'Ringkasan Medis & Kesehatan Jamaah'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildDetailRow(icon: LucideIcons.heartPulse, label: 'Golongan Darah', value: 'O+ (Positif)'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.alertTriangle, label: 'Riwayat Alergi', value: 'Penisilin / Debu'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.clipboardList, label: 'Catatan Khusus Medis', value: 'Hipertensi terkontrol dengan rutin minum obat harian'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.pill, label: 'Jadwal Minum Obat', value: 'Amlodipine 5mg • Pukul 08:00 WAS'),
                      _buildDivider(),
                      _buildDetailRow(icon: LucideIcons.shieldCheck, label: 'Polis Asuransi Kesehatan', value: 'Takaful Global #TK-9921-UM (Aktif)'),
                    ],
                  ),
                ).animate().fadeIn(delay: 175.ms),
                const SizedBox(height: 24),

                // 4. Official Documents Section
                SectionHeader(title: 'Dokumen Resmi & ID Jamaah'),
                AppleCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDocumentCard(
                        title: 'Paspor Elektronik Jamaah',
                        subtitle: 'No: X-99821014 • Terverifikasi',
                        icon: LucideIcons.bookOpen,
                        color: AppColors.primaryDark,
                        onTap: () => _showDocumentPreview(context, 'Paspor Elektronik Jamaah', 'Paspor Elektronik Resmi atas nama H. Ahmad Zaki Al-Farizi', LucideIcons.bookOpen),
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
                        title: 'E-Tiket & Booking Pesawat',
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
                        title: 'Kartu ID Digital Resmi Jamaah',
                        subtitle: 'ID Gelang #PL-88210 • Siap Ditunjukkan',
                        icon: LucideIcons.badgeCheck,
                        color: AppColors.successGreen,
                        onTap: () => _showDigitalIdModal(context),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _simulateDownloadPdf(context),
                          icon: const Icon(LucideIcons.download, size: 16),
                          label: const Text('Unduh Rekap Dokumen & Identitas (PDF)'),
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
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
}
