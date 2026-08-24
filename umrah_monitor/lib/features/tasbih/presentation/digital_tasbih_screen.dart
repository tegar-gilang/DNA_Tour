import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../domain/tasbih_model.dart';
import 'tasbih_provider.dart';

class DigitalTasbihScreen extends ConsumerStatefulWidget {
  const DigitalTasbihScreen({super.key});

  @override
  ConsumerState<DigitalTasbihScreen> createState() => _DigitalTasbihScreenState();
}

class _DigitalTasbihScreenState extends ConsumerState<DigitalTasbihScreen> {
  void _handleIncrement(TasbihModel tasbih) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    ref.read(tasbihProvider.notifier).increment();

    if (tasbih.counter + 1 == tasbih.target) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Target ${tasbih.target} tercapai untuk ${tasbih.selectedDzikir}! Alhamdulillah.'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur Ulang Penghitung Tasbih?'),
        content: const Text('Tindakan ini akan mengembalikan hitungan sesi saat ini ke 0 dan menyimpan riwayat pencapaian Anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(tasbihProvider.notifier).reset();
            },
            child: const Text('Atur Ulang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasbih = ref.watch(tasbihProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih & Dzikir Digital'),
      ),
      body: Stack(
        children: [
          // Background Ka'bah under blue sky with clouds daytime shot
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.network(
                'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          // Black overlay layer above photo with 30% opacity per user request
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.30),
            ),
          ),
          // Scrollable foreground content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Dzikir Selection Card
                  AppleCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dzikir Pilihan:', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: tasbih.selectedDzikir,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: tasbih.dzikirList.map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text(d, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(tasbihProvider.notifier).setSelectedDzikir(val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hitungan:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: tasbih.targetOptions.map((t) {
                                    final isSel = tasbih.target == t;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: ChoiceChip(
                                        label: Text('$t'),
                                        selected: isSel,
                                        onSelected: (val) => ref.read(tasbihProvider.notifier).setTarget(t),
                                        selectedColor: AppColors.primary,
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isSel ? AppColors.primary : AppColors.borderLight,
                                            width: isSel ? 1.5 : 1,
                                          ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: isSel ? AppColors.secondaryLight : AppColors.textPrimaryLight,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 390),

                  // Flanking layout: Larger Left Minus Icon, Center Circle Counter, Larger Right Reset Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Box: Kurangi (-) icon with solid opacity and high contrast
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: tasbih.counter > 0 ? () => ref.read(tasbihProvider.notifier).decrement() : null,
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.secondaryLight.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.minus,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 26),

                      // Center Giant Circle Counter
                      Flexible(
                        child: FittedBox(
                          child: GestureDetector(
                            onTap: () => _handleIncrement(tasbih),
                            child: Container(
                              width: 244,
                              height: 244,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.cardDark.withValues(alpha: 0.95)
                                    : Colors.white.withValues(alpha: 0.95),
                                border: Border.all(color: AppColors.secondaryLight.withValues(alpha: 0.6), width: 6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.22),
                                    blurRadius: 36,
                                    spreadRadius: 6,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 228,
                                    height: 228,
                                    child: CircularProgressIndicator(
                                      value: tasbih.progress,
                                      strokeWidth: 10,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${tasbih.counter}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 78,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                          letterSpacing: -2,
                                        ),
                                      ),
                                      Text(
                                        '/ ${tasbih.target}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 26),

                      // Right Box: Atur Ulang (rotateCcw) icon enlarged
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showResetDialog,
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.secondaryLight.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.rotateCcw,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
