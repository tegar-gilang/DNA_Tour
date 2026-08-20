import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/domain/user_model.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../domain/prayer_model.dart';

class PrayerDetailScreen extends ConsumerStatefulWidget {
  final PrayerModel prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  ConsumerState<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends ConsumerState<PrayerDetailScreen> {
  bool _isReadingMode = false;
  bool _isPlaying = false;
  final double _audioProgress = 0.35;

  void _togglePlay() {
    final role = ref.read(authProvider).selectedRole;
    final isMuttawif = role == UserRole.tourLeader;
    
    setState(() => _isPlaying = !_isPlaying);
    
    if (isMuttawif) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPlaying ? 'Mulai menyiarkan audio doa "${widget.prayer.title}" ke seluruh perangkat jamaah...' : 'Siaran audio dihentikan.'),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPlaying ? 'Playing High-Quality Audio recitation...' : 'Audio paused.'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _copyPrayer() {
    final text = '${widget.prayer.title}\n\n${widget.prayer.arabic}\n\nTransliteration: ${widget.prayer.latin}\n\nTranslation: ${widget.prayer.translation}\n\nReference: ${widget.prayer.reference}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prayer text copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isReadingMode
          ? null
          : AppBar(
              title: const Text('Prayer Details'),
              actions: [
                IconButton(
                  icon: Icon(_isReadingMode ? LucideIcons.minimize2 : LucideIcons.maximize2),
                  tooltip: 'Toggle Reading Mode',
                  onPressed: () => setState(() => _isReadingMode = !_isReadingMode),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.copy),
                  tooltip: 'Copy Text',
                  onPressed: _copyPrayer,
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Reading Mode Quick Header if fullscreen
            if (_isReadingMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _isReadingMode = false),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      label: const Text('Exit Reading Mode'),
                    ),
                    StatusBadge(label: 'FULLSCREEN MODE', color: AppColors.primary),
                  ],
                ),
              ),

            // Main Prayer Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(label: widget.prayer.category, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      widget.prayer.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Arabic Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.cardDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: AppColors.softShadowLight,
                      ),
                      child: Text(
                        widget.prayer.arabic,
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          height: 2.0,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Latin Transliteration
                    SectionHeader(title: 'Transliteration (Latin)'),
                    AppleCard(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.prayer.latin,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Indonesian Translation & Meaning
                    SectionHeader(title: 'Indonesian Translation & Meaning'),
                    AppleCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.prayer.translation,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Icon(LucideIcons.lightbulb, size: 18, color: AppColors.secondaryDark),
                              const SizedBox(width: 8),
                              Text('Spiritual Meaning / Makna', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondaryDark)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.prayer.meaning,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Virtues & Reference Source
                    SectionHeader(title: 'Reference & Virtues (Fadhilah)'),
                    AppleCard(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Source / Hadith:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                              Text(widget.prayer.reference, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.prayer.virtues,
                            style: TextStyle(fontSize: 13, color: AppColors.onPrimaryContainer, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Audio Playback Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: AppColors.softShadowLight,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: _togglePlay,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? LucideIcons.pause : (ref.watch(authProvider).selectedRole == UserRole.tourLeader ? LucideIcons.radio : LucideIcons.play),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isPlaying 
                                  ? (ref.watch(authProvider).selectedRole == UserRole.tourLeader ? 'Menyiarkan ke Jamaah...' : 'Playing Recitation...')
                                  : (ref.watch(authProvider).selectedRole == UserRole.tourLeader ? 'Siarkan Audio ke Jamaah' : 'Audio Recitation Ready'),
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.w700,
                                color: ref.watch(authProvider).selectedRole == UserRole.tourLeader ? AppColors.emergencyRed : null,
                              ),
                            ),
                            Text('01:14 / 03:30', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: _isPlaying ? _audioProgress : 0.0,
                          backgroundColor: AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
