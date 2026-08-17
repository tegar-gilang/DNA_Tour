import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../tracking/presentation/journey_provider.dart';

class FamilyLocationScreen extends ConsumerStatefulWidget {
  const FamilyLocationScreen({super.key});

  @override
  ConsumerState<FamilyLocationScreen> createState() => _FamilyLocationScreenState();
}

class _FamilyLocationScreenState extends ConsumerState<FamilyLocationScreen> {
  String _selectedLayer = 'Semua';

  @override
  Widget build(BuildContext context) {
    final journeyState = ref.watch(journeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peta Lokasi Live Jamaah',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memusatkan peta ke posisi H. Ahmad Zaki Al-Farizi...')),
              );
            },
            icon: const Icon(LucideIcons.compass),
            tooltip: 'Pusatkan ke Jamaah',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive Map Simulation Canvas
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE5E3DF),
            child: CustomPaint(
              painter: _MapCanvasPainter(),
              child: Stack(
                children: [
                  // Pilgrim Marker
                  if (_selectedLayer == 'Semua' || _selectedLayer == 'Titik Kumpul' || _selectedLayer == 'Rute Perjalanan')
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.46,
                      top: MediaQuery.of(context).size.height * 0.32,
                      child: _buildMapPin(
                        'H. Ahmad Zaki',
                        AppColors.primary,
                        LucideIcons.user,
                        isPilgrim: true,
                      ),
                    ),
                  // Hotel Marker
                  if (_selectedLayer == 'Semua' || _selectedLayer == 'Hotel' || _selectedLayer == 'Titik Kumpul')
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.65,
                      top: MediaQuery.of(context).size.height * 0.45,
                      child: _buildMapPin(
                        'Swissôtel Al Maqam',
                        AppColors.secondaryDark,
                        LucideIcons.building,
                      ),
                    ),
                  // Mosque Marker
                  if (_selectedLayer == 'Semua' || _selectedLayer == 'Masjid')
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.40,
                      top: MediaQuery.of(context).size.height * 0.28,
                      child: _buildMapPin(
                        'Masjidil Haram Gate 1',
                        AppColors.infoBlue,
                        LucideIcons.moon,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Top Layer Chips Filter
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['Semua', 'Hotel', 'Masjid', 'Titik Kumpul', 'Rute Perjalanan'].map((layer) {
                  final isSelected = _selectedLayer == layer;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedLayer = layer),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderLight,
                          ),
                          boxShadow: AppColors.softShadowLight,
                        ),
                        child: Text(
                          layer,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Bottom Telemetry Overlay Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AppleCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.navigation, color: AppColors.primaryDark, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    journeyState.currentLocation,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Aktivitas: ${journeyState.currentActivity}',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(LucideIcons.user, 'Diperbarui Oleh', journeyState.updatedBy),
                      _buildMetricItem(LucideIcons.footprints, 'Jarak ke Hotel', '420 m'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String label, Color color, IconData icon, {bool isPilgrim = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadowLight,
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          padding: EdgeInsets.all(isPilgrim ? 10 : 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: isPilgrim ? 16 : 8,
                spreadRadius: isPilgrim ? 4 : 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: isPilgrim ? 20 : 16),
        ),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 1),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6D1CA)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw simulated streets around Haram area
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), paint);
    canvas.drawLine(Offset(size.width * 0.48, 0), Offset(size.width * 0.48, size.height), paint);

    paint.color = const Color(0xFFE2DDD7);
    paint.strokeWidth = 8;
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.5), paint);

    // Draw Haram perimeter simulation
    final haramPaint = Paint()
      ..color = const Color(0xFFB0C4DE).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.30), 85, haramPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
