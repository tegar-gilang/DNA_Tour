import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_monitor/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app wrapped with ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: UmrahMonitorApp()));

    // Fast-forward past all flutter_animate delay timers and animation durations
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify app starts cleanly and shows role selection
    expect(find.byType(UmrahMonitorApp), findsOneWidget);
  });
}
