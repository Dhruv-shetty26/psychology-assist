import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/calmora/calmora_ai_sheet.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/mood_log/mood_log_screen.dart';
import '../../features/appointments/appointments_screen.dart';
import '../../features/psychologists/psychologists_screen.dart';
import '../../features/settings/settings_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final theme = Theme.of(context);

    final pages = [
      const DashboardScreen(),
      const MoodLogScreen(),
      const PsychologistsScreen(),
      const AppointmentsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedTab, children: pages),
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton(
              onPressed: () => _showAiChat(context),
              tooltip: 'AI chat',
              child: const Icon(Icons.smart_toy_outlined),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.92),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonViolet.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: (index) {
            ref.read(selectedTabProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.textTheme.bodySmall?.color?.withOpacity(
            0.6,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Log Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_alt_outlined),
              activeIcon: Icon(Icons.psychology_alt),
              label: 'Care',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_outlined),
              activeIcon: Icon(Icons.event_available),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _showAiChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const CalmoraAiSheet(),
    );
  }
}
