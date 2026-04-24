import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'app/navigation/app_router.dart';
import 'app/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
      title: 'Psychol - Your Wellness Companion',
      theme: getTheme(themeMode),
      darkTheme: AppThemes.darkTheme,
      themeMode:
          themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
