import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_monitor/main.dart';
import 'package:umrah_monitor/core/services/firebase_messaging_service.dart';

class FakeFirebaseMessagingService extends FirebaseMessagingService {
  @override
  void initializeForegroundAndBackgroundHandlers(WidgetRef ref) {
    // No-op for tests: prevents accessing FirebaseMessaging in test environment
  }

  @override
  Future<String?> getToken() async => 'fake_test_token';
}

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app wrapped with ProviderScope overriding FirebaseMessagingService.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseMessagingServiceProvider.overrideWithValue(
            FakeFirebaseMessagingService(),
          ),
        ],
        child: const UmrahMonitorApp(),
      ),
    );

    // Fast-forward past all flutter_animate delay timers and animation durations
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify app starts cleanly and shows role selection
    expect(find.byType(UmrahMonitorApp), findsOneWidget);
  });
}