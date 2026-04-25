import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'app/theme_provider.dart';
import 'app/app_state.dart';
import 'core/services/app_session_store.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'app/navigation/app_router.dart';
import 'features/app_lock/app_lock_gate.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'app/home_screen.dart'; // To access selectedTabProvider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppSessionStore();
  final initialSession = await store.load();
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        appSessionStoreProvider.overrideWithValue(store),
        initialAppSessionProvider.overrideWithValue(initialSession),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial link if app was closed
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Handle link when app is in background/foreground
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'calmora' && uri.host == 'feature') {
      final feature = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (feature == 'mood') {
        ref.read(selectedTabProvider.notifier).state = 1;
      } else if (feature == 'journal') {
        ref.read(selectedTabProvider.notifier).state = 2;
      } else if (feature == 'appointment') {
        ref.read(selectedTabProvider.notifier).state = 3;
      }
      // For SOS, you might want to show an alert or trigger a specific SOS provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final session = ref.watch(appSessionProvider);

    // Map AppThemeMode to ThemeData
    ThemeData getTheme(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return AppThemes.lightTheme;
        case AppThemeMode.dark:
          return AppThemes.darkTheme;
        case AppThemeMode.medical:
          return AppThemes.medicalTheme;
        case AppThemeMode.journal:
          return AppThemes.journalTheme;
      }
    }

    return MaterialApp(
      title: 'Calmora',
      theme: getTheme(themeMode),
      darkTheme: AppThemes.darkTheme,
      themeMode:
          themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      home: AnimatedSwitcher(
  duration: const Duration(milliseconds: 500),
  child: !session.onboardingComplete
      ? const OnboardingScreen()
      : const AppLockGate(),
),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
