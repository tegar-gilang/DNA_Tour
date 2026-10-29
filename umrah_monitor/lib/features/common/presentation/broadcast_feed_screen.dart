import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/app_colors.dart';
import 'broadcast_provider.dart';

class BroadcastFeedScreen extends ConsumerStatefulWidget {
  const BroadcastFeedScreen({super.key});

  @override
  ConsumerState<BroadcastFeedScreen> createState() =>
      _BroadcastFeedScreenState();
}

class _BroadcastFeedScreenState extends ConsumerState<BroadcastFeedScreen> {
  @override
  void initState() {
    super.initState();
    // Muat data saat screen pertama kali ditampilkan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(broadcastProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final broadcastState = ref.watch(broadcastProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pesan & Pengumuman'),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (broadcastState.status == BroadcastStatus.success ||
              broadcastState.status == BroadcastStatus.error)
            IconButton(
              key: const Key('btn_refresh_broadcast'),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Muat ulang',
              onPressed: () =>
                  ref.read(broadcastProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(broadcastState, isDark),
    );
  }

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
        return _buildList(state, isDark);
    }
  }

  // ── Loading state ──────────────────────────────────────────────────────────

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

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
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
              onPressed: () =>
                  ref.read(broadcastProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Muat ulang'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildError(String message, bool isDark) {
    final isAuth = message.toLowerCase().contains('token');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
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
                isAuth
                    ? Icons.lock_outline_rounded
                    : Icons.wifi_off_rounded,
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
              isAuth
                  ? 'Silakan login kembali untuk melanjutkan.'
                  : message,
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
              onPressed: () =>
                  ref.read(broadcastProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success: daftar broadcast ──────────────────────────────────────────────

  Widget _buildList(BroadcastState state, bool isDark) {
    final grouped = <String, List<dynamic>>{};
    for (final b in state.items) {
      (grouped[b.dateGroup] ??= []).add(b);
    }
    final groups = grouped.entries.toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(broadcastProvider.notifier).refresh(),
      child: ListView.builder(
        key: const Key('broadcast_list'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: groups.fold<int>(
          0,
          (sum, g) => sum + 1 + g.value.length,
        ),
        itemBuilder: (context, idx) {
          int cursor = 0;
          for (final group in groups) {
            if (idx == cursor) {
              return _buildDateHeader(group.key, isDark);
            }
            cursor++;
            for (final broadcast in group.value) {
              if (idx == cursor) {
                return _BroadcastTile(broadcast: broadcast, isDark: isDark);
              }
              cursor++;
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDateHeader(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
      ),
    );
  }
}

// ── Broadcast tile ─────────────────────────────────────────────────────────

class _BroadcastTile extends StatelessWidget {
  final dynamic broadcast;
  final bool isDark;

  const _BroadcastTile({required this.broadcast, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = broadcast.color as Color;
    final icon = broadcast.icon as IconData;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.055),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            broadcast.title as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          broadcast.formattedTime as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      broadcast.message as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((broadcast.senderName as String?) != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            broadcast.senderName as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                          if ((broadcast.category as String?) != null) ...[
                            const SizedBox(width: 8),
                            _CategoryChip(
                              label: broadcast.category as String,
                              color: color,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
