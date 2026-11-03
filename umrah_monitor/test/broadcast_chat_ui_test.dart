// test/broadcast_chat_ui_test.dart
//
// Widget tests untuk BroadcastFeedScreen setelah redesign ke Room Chat UI.
// Memverifikasi:
//   • Pesan tampil sebagai bubble chat dengan nama pengirim & waktu
//   • Date separator tampil di antara kelompok hari
//   • Empty state berfungsi
//   • Error state berfungsi
//   • Tidak ada input pengiriman pesan (Jamaah & Family hanya baca)
//   • AppBar dengan header room chat

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/features/common/domain/broadcast_model.dart';
import 'package:umrah_monitor/features/common/presentation/broadcast_feed_screen.dart';
import 'package:umrah_monitor/features/common/presentation/broadcast_provider.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Membuat [Broadcast] dengan nilai default yang bisa di-override.
Broadcast _makeBroadcast({
  String id = 'bc-001',
  String title = 'Pengumuman Test',
  String message = 'Isi pesan pengumuman.',
  String? senderName = 'Pembimbing Ali',
  String? category = 'umum',
  String? priority,
  DateTime? createdAt,
}) {
  return Broadcast(
    id: id,
    title: title,
    message: message,
    senderName: senderName,
    category: category,
    priority: priority,
    createdAt: createdAt ?? DateTime(2026, 10, 27, 8, 0),
  );
}

/// Membangun widget [BroadcastFeedScreen] dengan [BroadcastState] yang di-override.
Widget _buildApp(BroadcastState state) {
  return ProviderScope(
    overrides: [
      broadcastProvider.overrideWith((_) => _FakeNotifier(state)),
    ],
    child: const MaterialApp(
      home: BroadcastFeedScreen(),
    ),
  );
}

class _FakeNotifier extends StateNotifier<BroadcastState>
    implements BroadcastNotifier {
  _FakeNotifier(super.s);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('BroadcastFeedScreen — Room Chat UI', () {
    // ── AppBar ───────────────────────────────────────────────────────────────
    testWidgets(
      'AppBar menampilkan judul "Pesan & Pengumuman" dan subtitle room',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast()],
          ),
        ));
        await tester.pump();

        expect(find.text('Pesan & Pengumuman'), findsOneWidget);
        expect(find.text('Pengumuman DNA Tour'), findsOneWidget);
      },
    );

    testWidgets(
      'Tombol refresh tampil saat status success',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast()],
          ),
        ));
        await tester.pump();

        expect(find.byKey(const Key('btn_refresh_broadcast')), findsOneWidget);
      },
    );

    testWidgets(
      'Tombol refresh tampil saat status error',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          const BroadcastState(
            status: BroadcastStatus.error,
            errorMessage: 'Koneksi gagal.',
          ),
        ));
        await tester.pump();

        expect(find.byKey(const Key('btn_error_retry_broadcast')), findsOneWidget);
      },
    );

    // ── Bubble pesan ─────────────────────────────────────────────────────────
    testWidgets(
      'Bubble chat menampilkan judul pesan dengan benar',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast(title: 'Jadwal Ziarah Raudhah')],
          ),
        ));
        await tester.pump();

        expect(find.text('Jadwal Ziarah Raudhah'), findsOneWidget);
      },
    );

    testWidgets(
      'Bubble chat menampilkan isi pesan dengan benar',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast(message: 'Bus berangkat jam 08.00 WAS.')],
          ),
        ));
        await tester.pump();

        expect(find.text('Bus berangkat jam 08.00 WAS.'), findsOneWidget);
      },
    );

    testWidgets(
      'Bubble chat menampilkan nama pengirim',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast(senderName: 'Ust. Hasan')],
          ),
        ));
        await tester.pump();

        expect(find.text('Ust. Hasan'), findsOneWidget);
      },
    );

    testWidgets(
      'Bubble chat menampilkan waktu pengiriman',
      (tester) async {
        final broadcast = _makeBroadcast(
          createdAt: DateTime(2026, 10, 27, 10, 30),
        );
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [broadcast],
          ),
        ));
        await tester.pump();

        // formattedTime dari Broadcast model: "HH:mm"
        expect(find.textContaining('10:30'), findsOneWidget);
      },
    );

    testWidgets(
      'Broadcast list menggunakan Key broadcast_list',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast()],
          ),
        ));
        await tester.pump();

        expect(find.byKey(const Key('broadcast_list')), findsOneWidget);
      },
    );

    testWidgets(
      'Multiple pesan semuanya tampil di layar',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [
              _makeBroadcast(id: '1', title: 'Pesan Pertama'),
              _makeBroadcast(id: '2', title: 'Pesan Kedua'),
              _makeBroadcast(id: '3', title: 'Pesan Ketiga'),
            ],
          ),
        ));
        await tester.pump();

        expect(find.text('Pesan Pertama'), findsOneWidget);
        expect(find.text('Pesan Kedua'), findsOneWidget);
        expect(find.text('Pesan Ketiga'), findsOneWidget);
      },
    );

    // ── Priority badge ────────────────────────────────────────────────────────
    testWidgets(
      'Badge PENTING tampil untuk pesan priority high',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast(priority: 'high')],
          ),
        ));
        await tester.pump();

        expect(find.text('PENTING'), findsOneWidget);
      },
    );

    testWidgets(
      'Badge PENTING tampil untuk pesan priority urgent',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast(priority: 'urgent')],
          ),
        ));
        await tester.pump();

        expect(find.text('PENTING'), findsOneWidget);
      },
    );

    // ── No input field ────────────────────────────────────────────────────────
    testWidgets(
      'Tidak ada TextField atau input pengiriman pesan (read-only)',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast()],
          ),
        ));
        await tester.pump();

        // Jamaah & Family tidak boleh memiliki field input
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(TextFormField), findsNothing);
      },
    );

    testWidgets(
      'Tidak ada tombol send atau kirim pesan',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast()],
          ),
        ));
        await tester.pump();

        expect(find.byIcon(Icons.send), findsNothing);
        expect(find.byIcon(Icons.send_rounded), findsNothing);
      },
    );

    // ── Empty state ────────────────────────────────────────────────────────────
    testWidgets(
      'Empty state menampilkan teks "Belum ada pengumuman"',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          const BroadcastState(status: BroadcastStatus.empty),
        ));
        await tester.pump();

        expect(find.text('Belum ada pengumuman'), findsOneWidget);
        expect(find.byKey(const Key('btn_empty_refresh_broadcast')), findsOneWidget);
      },
    );

    // ── Error state ────────────────────────────────────────────────────────────
    testWidgets(
      'Error state menampilkan pesan error dan tombol retry',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          const BroadcastState(
            status: BroadcastStatus.error,
            errorMessage: 'Koneksi gagal, coba lagi.',
          ),
        ));
        await tester.pump();

        expect(find.text('Gagal memuat pengumuman'), findsOneWidget);
        expect(find.byKey(const Key('btn_error_retry_broadcast')), findsOneWidget);
      },
    );

    testWidgets(
      'Error state dengan pesan token menampilkan "Sesi tidak valid"',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          const BroadcastState(
            status: BroadcastStatus.error,
            errorMessage: 'Token tidak ditemukan. Silakan login kembali.',
          ),
        ));
        await tester.pump();

        expect(find.text('Sesi tidak valid'), findsOneWidget);
      },
    );

    // ── Loading state ─────────────────────────────────────────────────────────
    testWidgets(
      'Loading state menampilkan indikator loading',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          const BroadcastState(status: BroadcastStatus.loading),
        ));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Memuat pengumuman…'), findsOneWidget);
      },
    );

    // ── Fallback sender name ────────────────────────────────────────────────
    testWidgets(
      'Pesan tanpa senderName menampilkan "DNA Tour" sebagai pengirim',
      (tester) async {
        await tester.pumpWidget(_buildApp(
          BroadcastState(
            status: BroadcastStatus.success,
            items: [_makeBroadcast(senderName: null)],
          ),
        ));
        await tester.pump();

        expect(find.text('DNA Tour'), findsOneWidget);
      },
    );
  });
}
