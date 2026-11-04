import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_colors.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/broadcast_model.dart';
import 'broadcast_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BroadcastFeedScreen — Room Chat UI (read-only untuk Jamaah & Family)
//
// Konsep: tampilan channel / siaran seperti Telegram.
// • Semua pesan tampil sebagai bubble kiri (pesan dari pengirim/admin).
// • Auto-scroll ke bawah saat pertama kali dibuka.
// • Pull-to-refresh dipertahankan.
// • Tidak ada input pengiriman pesan (Jamaah & Family hanya baca).
// ─────────────────────────────────────────────────────────────────────────────

class BroadcastFeedScreen extends ConsumerStatefulWidget {
  const BroadcastFeedScreen({super.key});

  @override
  ConsumerState<BroadcastFeedScreen> createState() =>
      _BroadcastFeedScreenState();
}

class _BroadcastFeedScreenState extends ConsumerState<BroadcastFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(broadcastProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll ke pesan terbaru (paling bawah) saat data pertama kali berhasil dimuat.
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(max);
    }
  }

  @override
  Widget build(BuildContext context) {
    final broadcastState = ref.watch(broadcastProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-scroll ke bawah saat data pertama kali berhasil dimuat
    if (broadcastState.status == BroadcastStatus.success &&
        !_hasScrolledToBottom) {
      _hasScrolledToBottom = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    // Reset flag saat di-refresh agar kembali scroll ke bawah setelah refresh selesai
    if (broadcastState.status == BroadcastStatus.loading) {
      _hasScrolledToBottom = false;
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D1117)
          : const Color(0xFFEEF0F3),
      appBar: _buildAppBar(broadcastState, isDark),
      body: _buildBody(broadcastState, isDark),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BroadcastState state, bool isDark) {
    final canRefresh =
        state.status == BroadcastStatus.success ||
        state.status == BroadcastStatus.error ||
        state.status == BroadcastStatus.empty;

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E242C) : AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Tombol kembali (hanya tampil jika bisa pop)
                if (Navigator.canPop(context)) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Kembali',
                    onPressed: () => context.pop(),
                  ),
                ],

                // Avatar channel
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Judul & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pesan & Pengumuman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Pengumuman DNA Tour',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol refresh
                if (canRefresh)
                  IconButton(
                    key: const Key('btn_refresh_broadcast'),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Muat ulang',
                    onPressed: () =>
                        ref.read(broadcastProvider.notifier).refresh(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BroadcastState state, bool isDark) {
    switch (state.status) {
      case BroadcastStatus.idle:
      case BroadcastStatus.loading:
        return _buildLoading(isDark);
      case BroadcastStatus.empty:
        return _buildEmpty(isDark);
      case BroadcastStatus.error:
        return _buildError(state.errorMessage ?? 'Terjadi kesalahan.', isDark);
      case BroadcastStatus.success:
        return _buildChatArea(state, isDark);
    }
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'Memuat pengumuman…',
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada pengumuman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Pengumuman dari pembimbing akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              key: const Key('btn_empty_refresh_broadcast'),
              onPressed: () => ref.read(broadcastProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Muat ulang'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────

  Widget _buildError(String message, bool isDark) {
    final isAuth = message.toLowerCase().contains('token');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuth ? Icons.lock_outline_rounded : Icons.wifi_off_rounded,
                size: 38,
                color: AppColors.emergencyRed.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuth ? 'Sesi tidak valid' : 'Gagal memuat pengumuman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAuth ? 'Silakan login kembali untuk melanjutkan.' : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              key: const Key('btn_error_retry_broadcast'),
              onPressed: () => ref.read(broadcastProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chat Area ──────────────────────────────────────────────────────────────

  Widget _buildChatArea(BroadcastState state, bool isDark) {
    // Urutkan dari terlama ke terbaru (pesan terbaru di bawah)
    final sorted = [...state.items]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Kelompokkan berdasarkan tanggal untuk separator
    final List<_ChatItem> items = [];
    String? lastDateLabel;

    for (final broadcast in sorted) {
      final dateLabel = broadcast.dateGroup;
      if (dateLabel != lastDateLabel) {
        items.add(_ChatItem.dateSeparator(dateLabel));
        lastDateLabel = dateLabel;
      }
      items.add(_ChatItem.message(broadcast));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      onRefresh: () => ref.read(broadcastProvider.notifier).refresh(),
      child: ListView.builder(
        key: const Key('broadcast_list'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item.isDateSeparator) {
            return _DateSeparator(label: item.dateLabel!, isDark: isDark);
          }
          return _BubbleChatMessage(broadcast: item.broadcast!, isDark: isDark);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChatItem — sealed helper untuk dua tipe item di ListView
// ─────────────────────────────────────────────────────────────────────────────

class _ChatItem {
  final bool isDateSeparator;
  final String? dateLabel;
  final Broadcast? broadcast;

  const _ChatItem._({
    required this.isDateSeparator,
    this.dateLabel,
    this.broadcast,
  });

  factory _ChatItem.dateSeparator(String label) =>
      _ChatItem._(isDateSeparator: true, dateLabel: label);

  factory _ChatItem.message(Broadcast b) =>
      _ChatItem._(isDateSeparator: false, broadcast: b);
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateSeparator — pemisah tanggal di antara pesan
// ─────────────────────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateSeparator({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.5)
                  : AppColors.borderLight.withValues(alpha: 0.7),
              thickness: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.5)
                  : AppColors.borderLight.withValues(alpha: 0.7),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BubbleChatMessage — satu bubble pesan broadcast
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleChatMessage extends StatelessWidget {
  final Broadcast broadcast;
  final bool isDark;

  const _BubbleChatMessage({required this.broadcast, required this.isDark});

  /// Menentukan warna avatar & aksen berdasarkan priority/category broadcast.
  Color get _accentColor {
    if (broadcast.priority?.toLowerCase() == 'high' ||
        broadcast.priority?.toLowerCase() == 'urgent') {
      return AppColors.emergencyRed;
    }
    if (broadcast.broadcastId != null) {
      return const Color(0xFFC27803); // amber-ish untuk siaran dari notifikasi
    }
    return AppColors.primary;
  }

  /// Inisial untuk avatar — dari senderName atau fallback 'DN'.
  String get _initials {
    final name = broadcast.senderName ?? 'DNA Tour';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Label badge tipe pengirim.
  String get _senderLabel => broadcast.senderName ?? 'DNA Tour';

  /// Badge kategori / priority jika relevan.
  String? get _badgeLabel {
    if (broadcast.priority?.toLowerCase() == 'high' ||
        broadcast.priority?.toLowerCase() == 'urgent') {
      return 'PENTING';
    }
    if (broadcast.category != null && broadcast.category!.isNotEmpty) {
      return broadcast.category!.toUpperCase();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final bubbleBg = isDark ? AppColors.cardDark : Colors.white;
    final bubbleBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          _Avatar(initials: _initials, color: accent),
          const SizedBox(width: 8),

          // ── Bubble ────────────────────────────────────────────────────────
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama pengirim (di atas bubble)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 3),
                  child: Text(
                    _senderLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),

                // Bubble utama
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(color: bubbleBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.06,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge & title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                broadcast.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (_badgeLabel != null) ...[
                              const SizedBox(width: 8),
                              _PriorityBadge(
                                label: _badgeLabel!,
                                color: accent,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Isi pesan
                        Text(
                          broadcast.message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Waktu — rata kanan di dalam bubble
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            broadcast.formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer agar bubble tidak melebar ke kanan layar
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Avatar — lingkaran avatar dengan inisial
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;

  const _Avatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PriorityBadge — badge kecil untuk label priority/kategori
// ─────────────────────────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PriorityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
