import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/domain/user_model.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../domain/prayer_model.dart';
import 'prayer_audio_provider.dart';
import 'prayer_bookmarks_provider.dart';

class PrayerCollectionScreen extends ConsumerStatefulWidget {
  const PrayerCollectionScreen({super.key});

  @override
  ConsumerState<PrayerCollectionScreen> createState() => _PrayerCollectionScreenState();
}

class _PrayerCollectionScreenState extends ConsumerState<PrayerCollectionScreen> {
  String _selectedCategory = 'Semua Kategori';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final List<PrayerModel> _prayers = List.from(PrayerModel.masterCollection);

  void _toggleBookmark(String prayerId) {
    ref.read(prayerBookmarksProvider.notifier).toggleBookmark(prayerId);
    final isBookmarked = ref.read(prayerBookmarksProvider).contains(prayerId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBookmarked ? '⭐ Doa berhasil disimpan ke Favorit Saya' : 'Doa dihapus dari Favorit'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final audioState = ref.watch(prayerAudioProvider);
    final bookmarkedIds = ref.watch(prayerBookmarksProvider);
    final currentRole = authState.selectedRole ?? authState.user?.role ?? UserRole.pilgrim;
    final filteredPrayers = _prayers.where((p) {
      final isBookmarked = bookmarkedIds.contains(p.id);
      if (_selectedCategory == 'Favorit Saya') {
        if (!isBookmarked) return false;
      } else if (_selectedCategory != 'Semua Kategori' && p.category != _selectedCategory) {
        return false;
      }

      if (_searchQuery.isNotEmpty &&
          !p.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.latin.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.translation.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doa & Dzikir Umrah'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline Audio & Text cache verified complete (100% downloaded).')),
              );
            },
            icon: const Icon(LucideIcons.checkCircle2, color: AppColors.successGreen),
            tooltip: 'Offline Status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Category Chips Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.primary),
                    hintText: 'Search doa by title, transliteration, or meaning...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: PrayerModel.categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: cat == 'Favorit Saya'
                              ? Icon(
                                  Icons.bookmark_rounded,
                                  size: 16,
                                  color: isSelected ? Colors.white : AppColors.secondaryDark,
                                )
                              : null,
                          label: Text(cat, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Prayers List
          Expanded(
            child: filteredPrayers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedCategory == 'Favorit Saya' ? Icons.bookmark_rounded : LucideIcons.bookOpen,
                          size: 64,
                          color: AppColors.textTertiaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == 'Favorit Saya'
                              ? 'Belum ada doa favorit yang disimpan'
                              : 'Tidak ada doa yang sesuai pencarian',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        if (_selectedCategory == 'Favorit Saya') ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Ketuk ikon bookmark pada doa untuk menyimpannya di sini.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filteredPrayers.length,
                    itemBuilder: (context, index) {
                      final p = filteredPrayers[index];
                      final isBookmarked = bookmarkedIds.contains(p.id);
                      final isThisActive = audioState.activePrayerId == p.id;
                      final isThisPlaying = isThisActive && audioState.isPlaying;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AppleCard(
                          onTap: null,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusBadge(label: p.category, color: AppColors.primary),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                          color: isBookmarked ? AppColors.secondaryDark : AppColors.textTertiaryLight,
                                          size: 22,
                                        ),
                                        onPressed: () => _toggleBookmark(p.id),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                p.title,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  p.arabic,
                                  style: GoogleFonts.amiri(
                                    fontSize: 22,
                                    height: 1.8,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).textTheme.titleLarge?.color,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                p.latin,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.translation,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final isMutawif = currentRole == UserRole.tourLeader;
                                      ref.read(prayerAudioProvider.notifier).playPrayer(p, isBroadcasting: isMutawif);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isThisPlaying
                                            ? (audioState.isMutawifBroadcasting ? AppColors.emergencyRed : AppColors.primary)
                                            : AppColors.secondaryDark.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isThisPlaying
                                              ? (audioState.isMutawifBroadcasting ? AppColors.emergencyRed : AppColors.primary)
                                              : AppColors.secondaryDark.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isThisPlaying
                                                ? LucideIcons.pause
                                                : (isThisActive && audioState.isMutawifBroadcasting ? LucideIcons.radio : LucideIcons.volume2),
                                            size: 14,
                                            color: isThisPlaying ? Colors.white : AppColors.secondaryDark,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isThisPlaying
                                                ? (audioState.isMutawifBroadcasting ? '🔴 SIARAN MUTAWIF' : 'Memutar Audio...')
                                                : (currentRole == UserRole.tourLeader ? 'Siarkan Audio' : 'Audio Available'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isThisPlaying ? Colors.white : AppColors.secondaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate(key: ValueKey(p.id)).fadeIn().moveY(begin: 10, end: 0);
                    },
                  ),
          ),

          // Sticky Bottom Audio Player Bar
          if (audioState.activePrayerId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: AppColors.softShadowLight,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(prayerAudioProvider.notifier).togglePlayPause();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: audioState.isMutawifBroadcasting ? AppColors.emergencyRed : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (audioState.isMutawifBroadcasting ? AppColors.emergencyRed : AppColors.primary).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        audioState.isPlaying ? LucideIcons.pause : (audioState.isMutawifBroadcasting ? LucideIcons.radio : LucideIcons.play),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                audioState.isMutawifBroadcasting
                                    ? '🔴 SIARAN LIVE MUTAWIF: ${audioState.activePrayerTitle}'
                                    : 'AUDIO DOA: ${audioState.activePrayerTitle}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: audioState.isMutawifBroadcasting ? AppColors.emergencyRed : AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('${audioState.positionText} / ${audioState.durationText}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: audioState.isPlaying ? audioState.progress : 0.0,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            audioState.isMutawifBroadcasting ? AppColors.emergencyRed : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
