import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';

class FamilyUpdatesScreen extends StatelessWidget {
  const FamilyUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'Kabar & Riwayat Jamaah',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Aktivitas Hari Ini'),
              Tab(text: 'Riwayat Check-In'),
              Tab(text: 'Ringkasan Medis'),
              Tab(text: 'Galeri Momen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActivitiesTab(),
            _buildCheckInHistoryTab(),
            _buildHealthSummaryTab(),
            _buildGalleryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildUpdateCard(
          time: '14:20 Waktu Makkah',
          title: 'Ibadah Tawaf & Sa\'i Selesai Sempurna',
          description: 'H. Ahmad Zaki telah menuntaskan 7 putaran Tawaf di Ka\'bah serta Sa\'i dari Safa ke Marwah bersama rombongan Kloter 4 Al-Barakah.',
          icon: LucideIcons.checkCircle2,
          color: AppColors.successGreen,
        ),
        const SizedBox(height: 16),
        _buildUpdateCard(
          time: '10:00 Waktu Makkah',
          title: 'Pemeriksaan Kesehatan Rutin Tim Medis',
          description: 'Tekanan darah 120/80 mmHg, saturasi oksigen 99%. Jamaah melaporkan kondisi fisik bugar dan semangat.',
          icon: LucideIcons.heartPulse,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildUpdateCard(
          time: '07:30 Waktu Makkah',
          title: 'Keberangkatan Bus #08 untuk Ziarah Bersejarah',
          description: 'Rombongan jamaah bertolak dari lobi Swissôtel Al Maqam menuju Jabal Rahmah, Gua Hira, dan Padang Arafah.',
          icon: LucideIcons.bus,
          color: AppColors.secondaryDark,
        ),
      ],
    );
  }

  Widget _buildCheckInHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHistoryRow('Masjidil Haram Gerbang 1 King Abdulaziz', '15 Juli - 14:20 Waktu Makkah', 'Verifikasi GPS'),
        const Divider(height: 26),
        _buildHistoryRow('Lobi Swissôtel Al Maqam Makkah', '15 Juli - 06:15 Waktu Makkah', 'Sinkronisasi Mutawif'),
        const Divider(height: 26),
        _buildHistoryRow('Bandara Internasional King Abdulaziz Jeddah', '14 Juli - 18:30 Waktu Arab Saudi', 'Check-In Rombongan'),
        const Divider(height: 26),
        _buildHistoryRow('Bandara Soekarno-Hatta Terminal 3 Jakarta', '14 Juli - 06:00 WIB', 'Keberangkatan Kloter'),
      ],
    );
  }

  Widget _buildHealthSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppleCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.activity, color: AppColors.successGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kondisi Kesehatan: SANGAT PRIMA', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.successGreen)),
                      const SizedBox(height: 4),
                      Text('Tidak ada insiden medis atau keluhan kelelahan fisik yang tercatat.', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Parameter Biometrik & Fisik'),
          AppleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildParamRow('Tekanan Darah', '120 / 80 mmHg (Normal)'),
                const Divider(height: 22),
                _buildParamRow('Denyut Jantung / Nadi', '74 bpm (Stabil)'),
                const Divider(height: 22),
                _buildParamRow('Tingkat Hidrasi Cairan', 'Sangat Baik (Konsumsi Zamzam Terjaga)'),
                const Divider(height: 22),
                _buildParamRow('Jumlah Langkah Harian', '14.280 langkah (~10.2 km)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    final photos = [
      'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=500',
      'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=500',
      'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?w=500',
      'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?w=500',
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(photos[index], fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildUpdateCard({
    required String time,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return AppleCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text(time, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
              StatusBadge(label: 'TERVERIFIKASI', color: color),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(description, style: GoogleFonts.outfit(fontSize: 13, height: 1.45, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String place, String time, String method) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(time, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StatusBadge(label: method, color: AppColors.primary),
      ],
    );
  }

  Widget _buildParamRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight)),
        Text(val, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
