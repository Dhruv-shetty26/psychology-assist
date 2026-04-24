import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme_provider.dart';
import 'app/app_state.dart';
import 'core/services/app_session_store.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'app/navigation/app_router.dart';
import 'features/app_lock/app_lock_gate.dart';
import 'features/onboarding/onboarding_screen.dart';

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      }
    }

    return MaterialApp(
      title: 'Calmora',
      theme: getTheme(themeMode),
      darkTheme: AppThemes.darkTheme,
      themeMode:
          themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 550),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: session.onboardingComplete && session.appLockSet
            ? const AppLockGate(key: ValueKey('lockGate'))
            : const OnboardingScreen(key: ValueKey('onboarding')),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
