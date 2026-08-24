import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import 'journey_provider.dart';

class MapPinData {
  final String id;
  final String title;
  final String subtitle;
  final LatLng coordinate;
  final IconData icon;
  final Color color;
  final String category; // 'All', 'Group', 'Hotel', 'Bus', 'Worship', 'Medical'

  const MapPinData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coordinate,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class InteractiveMapScreen extends ConsumerStatefulWidget {
  final bool isTourLeaderView;

  const InteractiveMapScreen({super.key, this.isTourLeaderView = false});

  @override
  ConsumerState<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  final MapController _mapController = MapController();
  int _currentTileIndex = 0; // 0: OpenStreetMap Standard, 1: CartoDB Voyager, 2: CartoDB Dark Matter
  String _activeFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Initial Makkah Center coordinates (near Masjidil Haram)
  static const LatLng _centerMakkah = LatLng(21.4225, 39.8262);

  final List<String> _filters = [
    'Semua',
    'Kloter',
    'Hotel',
    'Bus',
    'Ibadah',
    'Medis',
  ];

  final List<MapPinData> _pins = const [
    MapPinData(
      id: 'p_me',
      title: 'Lokasi Anda Saat Ini (Live)',
      subtitle: 'Akurasi GPS: ±3m • Baterai 88%',
      coordinate: LatLng(21.4218, 39.8258),
      icon: LucideIcons.user,
      color: AppColors.primary,
      category: 'Kloter',
    ),
    MapPinData(
      id: 'p_tl',
      title: 'Lokasi Pembimbing (Mutawif)',
      subtitle: 'Ust. H. Muhammad Ridwan (TL)',
      coordinate: LatLng(21.4222, 39.8260),
      icon: LucideIcons.userCheck,
      color: AppColors.secondaryDark,
      category: 'Kloter',
    ),
    MapPinData(
      id: 'p_group',
      title: 'Titik Kumpul Rombongan',
      subtitle: 'Kloter 4 Al-Barakah (45 Jamaah Berkumpul)',
      coordinate: LatLng(21.4220, 39.8261),
      icon: LucideIcons.users,
      color: AppColors.primaryDark,
      category: 'Kloter',
    ),
    MapPinData(
      id: 'p_meet',
      title: 'Titik Kumpul Berikutnya',
      subtitle: 'Gerbang 1 Pintu Masuk King Abdulaziz / Lobi Safa',
      coordinate: LatLng(21.4228, 39.8265),
      icon: LucideIcons.flag,
      color: AppColors.successGreen,
      category: 'Kloter',
    ),
    MapPinData(
      id: 'p_hotel',
      title: 'Hotel Penginapan',
      subtitle: 'Swissôtel Al Maqam Makkah (Kompleks Abraj Al-Bait)',
      coordinate: LatLng(21.4195, 39.8255),
      icon: LucideIcons.building,
      color: AppColors.secondaryDark,
      category: 'Hotel',
    ),
    MapPinData(
      id: 'p_bus',
      title: 'Lokasi Bus Alokasi',
      subtitle: 'Bus #08 Al-Safwa VIP Express (Parkir di Pintu Keluar Terowongan)',
      coordinate: LatLng(21.4188, 39.8249),
      icon: LucideIcons.bus,
      color: AppColors.infoBlue,
      category: 'Bus',
    ),
    MapPinData(
      id: 'p_haram',
      title: 'Masjidil Haram (Area Mataf Ka\'bah)',
      subtitle: 'Pusat Masjid Suci • Titik Kumpul Thawaf',
      coordinate: LatLng(21.4225, 39.8262),
      icon: Icons.mosque_rounded,
      color: AppColors.primary,
      category: 'Ibadah',
    ),
    MapPinData(
      id: 'p_nabawi',
      title: 'Masjid Nabawi (Madinah)',
      subtitle: 'Masjid Suci Nabi • Tujuan Fase Ke-2',
      coordinate: LatLng(24.4672, 39.6111),
      icon: LucideIcons.moon,
      color: AppColors.primaryDark,
      category: 'Ibadah',
    ),
    MapPinData(
      id: 'p_hosp',
      title: 'Rumah Sakit Darurat Medis',
      subtitle: 'RS Darurat Ajyad • Layanan Medis Jamaah 24 Jam',
      coordinate: LatLng(21.4208, 39.8275),
      icon: LucideIcons.heartPulse,
      color: AppColors.emergencyRed,
      category: 'Medis',
    ),
    MapPinData(
      id: 'p_emerg',
      title: 'Pos Pertahanan Sipil & Bulan Sabit Merah',
      subtitle: 'Meja Bantuan Darurat & Pusat Jamaah Terpisah Gerbang 4',
      coordinate: LatLng(21.4235, 39.8250),
      icon: LucideIcons.shieldAlert,
      color: AppColors.emergencyRed,
      category: 'Medis',
    ),
  ];

  List<MapPinData> get _filteredPins {
    return _pins.where((p) {
      final matchesCategory = _activeFilter == 'Semua' || p.category.toLowerCase() == _activeFilter.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String get _tileUrl {
    if (_currentTileIndex == 1) {
      return 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
    } else if (_currentTileIndex == 2) {
      return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  String get _tileStyleName {
    if (_currentTileIndex == 1) return 'Voyager / Satelit';
    if (_currentTileIndex == 2) return 'Mode Malam (Dark Matter)';
    return 'Standar OpenStreetMap';
  }

  List<Marker> _buildFlutterMarkers() {
    return _filteredPins.map((pin) {
      return Marker(
        point: pin.coordinate,
        width: 150,
        height: 64,
        child: GestureDetector(
          onTap: () => _showPinDetailModal(context, pin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pin.color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  pin.title.split(' ').take(2).join(' '),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: pin.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(pin.icon, color: Colors.white, size: 17),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Polyline> _buildFlutterPolylines() {
    return [
      Polyline(
        points: const [
          LatLng(21.4195, 39.8255), // Hotel
          LatLng(21.4218, 39.8258), // My Location
          LatLng(21.4228, 39.8265), // Meeting Point
          LatLng(21.4225, 39.8262), // Kaaba
        ],
        strokeWidth: 4.5,
        color: AppColors.primary,
        borderColor: Colors.white.withValues(alpha: 0.85),
        borderStrokeWidth: 1.5,
      ),
    ];
  }

  void _showPinDetailModal(BuildContext context, MapPinData pin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: pin.color.withValues(alpha: 0.15),
                  child: Icon(pin.icon, color: pin.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pin.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      StatusBadge(label: pin.category.toUpperCase(), color: pin.color),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(pin.subtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.4)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.compass, size: 18),
                    label: const Text('Fokus Peta'),
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(pin.coordinate, 17.5);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.navigation, size: 18),
                    label: const Text('Pandu Rute'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(pin.coordinate, 17.5);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Memulai panduan navigasi ke: ${pin.title}')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentTileIndex = (_currentTileIndex + 1) % 3;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lapisan peta diubah ke mode: $_tileStyleName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _recenterLocation() {
    _mapController.move(_centerMakkah, 16.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memusatkan ke posisi GPS langsung Anda.'), duration: Duration(seconds: 1)),
    );
  }

  void _alignNorth() {
    _mapController.rotate(0.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kompas disejajarkan ke Utara.'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journeyState = ref.watch(journeyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTourLeaderView ? 'Peta Komando Kloter (45 Jamaah)' : 'Pusat Navigasi & Pemantauan Ibadah'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.listFilter),
            tooltip: 'Daftar Lokasi & Titik Kumpul',
            onPressed: () {
              // Open quick pin summary modal
              _showPinSummaryModal(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. High-Fidelity Interactive Map Canvas via flutter_map & OpenStreetMap/CartoDB
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerMakkah,
              initialZoom: 15.5,
              maxZoom: 19.0,
              minZoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'com.mandiri.umrahmonitor',
              ),
              PolylineLayer(
                polylines: _buildFlutterPolylines(),
              ),
              MarkerLayer(
                markers: _buildFlutterMarkers(),
              ),
            ],
          ),

          // 2. Top Search & Filter Bar Overlay
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                AppleCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  color: (isDark ? AppColors.cardDark : AppColors.cardLight).withValues(alpha: 0.95),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari Ka\'bah, Hotel, Bus, Rumah Sakit...',
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Horizontal Filter Chips
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _activeFilter = filter;
                            });
                          },
                          backgroundColor: (isDark ? AppColors.cardDark : AppColors.cardLight).withValues(alpha: 0.92),
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Action Buttons (FABs) Overlay on Right
          Positioned(
            right: 16,
            bottom: 260, // Above bottom sheet
            child: Column(
              children: [
                _buildFab(
                  icon: LucideIcons.compass,
                  tooltip: 'Sejajarkan ke Utara',
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  iconColor: AppColors.primaryDark,
                  onTap: _alignNorth,
                ),
                const SizedBox(height: 10),
                _buildFab(
                  icon: LucideIcons.layers,
                  tooltip: 'Gaya Peta ($_tileStyleName)',
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  iconColor: AppColors.primary,
                  onTap: _toggleMapType,
                ),

                const SizedBox(height: 10),
                _buildFab(
                  icon: LucideIcons.navigation,
                  tooltip: 'Pusatkan Lokasi Saya',
                  color: AppColors.primary,
                  iconColor: Colors.white,
                  onTap: _recenterLocation,
                ),
              ],
            ),
          ),

          // 4. Modern Bottom Sheet Navigation Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: AppleCard(
              padding: const EdgeInsets.all(20),
              color: (isDark ? AppColors.cardDark : AppColors.cardLight).withValues(alpha: 0.96),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.navigation, size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Panduan Navigasi Aktif',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      StatusBadge(label: journeyState.status.toUpperCase(), color: AppColors.primary),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavigationSummaryItem(
                        label: 'Tujuan Saat Ini',
                        value: 'Masjidil Haram Mataf',
                        icon: Icons.mosque_rounded,
                        color: AppColors.primaryDark,
                      ),
                      _buildNavigationSummaryItem(
                        label: 'Sisa Jarak',
                        value: '450 Meter',
                        icon: LucideIcons.footprints,
                        color: AppColors.secondaryDark,
                      ),
                      _buildNavigationSummaryItem(
                        label: 'Perkiraan Tiba',
                        value: '6 Menit Jalan',
                        icon: LucideIcons.timer,
                        color: AppColors.successGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(LucideIcons.flag, size: 16, color: AppColors.successGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Titik Kumpul Berikutnya: Gerbang 1 Pintu King Abdulaziz / Lobi Safa',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

  Widget _buildFab({
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(13),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
          ],
        ),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showPinSummaryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Daftar Titik Lokasi & Panduan (${_filteredPins.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredPins.length,
                  itemBuilder: (context, idx) {
                    final p = _filteredPins[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: p.color.withValues(alpha: 0.15),
                        child: Icon(p.icon, color: p.color, size: 20),
                      ),
                      title: Text(p.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(p.subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      trailing: IconButton(
                        icon: const Icon(LucideIcons.navigation, size: 18, color: AppColors.primary),
                        onPressed: () {
                          Navigator.pop(context);
                          _mapController.move(p.coordinate, 17.5);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup Daftar Lokasi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
