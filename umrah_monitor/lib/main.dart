import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'core/config/app_router.dart';
import 'core/design_system/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  GoogleFonts.config.allowRuntimeFetching = true;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: UmrahMonitorApp(),
    ),
  );
}

class UmrahMonitorApp extends ConsumerStatefulWidget {
  const UmrahMonitorApp({super.key});

  @override
  ConsumerState<UmrahMonitorApp> createState() => _UmrahMonitorAppState();
}

class _UmrahMonitorAppState extends ConsumerState<UmrahMonitorApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firebaseMessagingServiceProvider).initializeForegroundAndBackgroundHandlers(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Umrah & Pilgrim Monitoring System (DNA Tour)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: Duration.zero,
      routerConfig: router,
    );
  }
}
