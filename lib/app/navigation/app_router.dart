import 'package:flutter/material.dart';
import '../../core/widgets/animations.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/mood_log/mood_log_screen.dart';
import '../../features/psychologists/psychologists_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return FadeTransitionPage(page: const DashboardScreen());
      case '/mood-log':
        return SmoothPageTransition(
          page: const MoodLogScreen(),
          axisDirection: AxisDirection.up,
        );
      case '/settings':
        return SmoothPageTransition(
          page: const SettingsScreen(),
          axisDirection: AxisDirection.right,
        );
      case '/psychologists':
        return SmoothPageTransition(
          page: const PsychologistsScreen(),
          axisDirection: AxisDirection.right,
        );
      default:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
    }
  }
}
