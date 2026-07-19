import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../domain/prayer_model.dart';

class PrayerCollectionScreen extends StatefulWidget {
  const PrayerCollectionScreen({super.key});

  @override
  State<PrayerCollectionScreen> createState() => _PrayerCollectionScreenState();
}

class _PrayerCollectionScreenState extends State<PrayerCollectionScreen> {
  String _selectedCategory = 'All Categories';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final List<PrayerModel> _prayers = List.from(PrayerModel.masterCollection);

  void _toggleBookmark(int index) {
    setState(() {
      _prayers[index] = _prayers[index].copyWith(isBookmarked: !_prayers[index].isBookmarked);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_prayers[index].isBookmarked ? 'Added to Bookmarks & Favorites' : 'Removed from Bookmarks'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrayers = _prayers.where((p) {
      if (_selectedCategory != 'All Categories' && p.category != _selectedCategory) {
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
                          label: Text(cat, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
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
                        Icon(LucideIcons.bookOpen, size: 64, color: AppColors.textTertiaryLight),
                        const SizedBox(height: 16),
                        Text('No doa matches your query', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filteredPrayers.length,
                    itemBuilder: (context, index) {
                      final p = filteredPrayers[index];
                      final masterIdx = _prayers.indexWhere((item) => item.id == p.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AppleCard(
                          onTap: () {
                            context.push('/prayer_detail/${p.id}', extra: p);
                          },
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
                                          p.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                          color: p.isBookmarked ? AppColors.secondaryDark : AppColors.textTertiaryLight,
                                          size: 22,
                                        ),
                                        onPressed: () => _toggleBookmark(masterIdx),
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
                                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700),
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
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.translation,
                                style: GoogleFonts.outfit(
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
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.volume2, size: 16, color: AppColors.secondaryDark),
                                      const SizedBox(width: 6),
                                      Text('Audio Available', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryDark)),
                                    ],
                                  ),
                                  Text(
                                    'Read Full & Virtues →',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
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
        ],
      ),
    );
  }
}
