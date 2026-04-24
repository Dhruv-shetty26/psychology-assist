import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum for available themes
enum AppThemeMode { light, dark, medical }

/// Riverpod provider for theme mode state
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// State notifier for managing theme changes
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.light);

  void setThemeMode(AppThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = AppThemeMode.values[(state.index + 1) % AppThemeMode.values.length];
  }
}
