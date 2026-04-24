import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/ollama_service.dart';
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
      builder: (context) => const _CalmoraAiSheet(),
    );
  }
}

class _CalmoraAiSheet extends StatefulWidget {
  const _CalmoraAiSheet();

  @override
  State<_CalmoraAiSheet> createState() => _CalmoraAiSheetState();
}

class _CalmoraAiSheetState extends State<_CalmoraAiSheet> {
  final _controller = TextEditingController();
  final _ai = OllamaService(
    endpoint: Uri.parse('http://10.0.2.2:11434/api/generate'),
  );
  String _reply =
      'Ask for a grounding exercise, journaling prompt, or appointment prep.';
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await _ai.summarize(
        prompt: 'You are Calmora, a concise mental wellness assistant. '
            'Be warm, practical, non-clinical, and suggest emergency help for crisis risk.\n\nUser: $text',
      );
      setState(() => _reply = response.trim().isEmpty
          ? 'I could not generate a useful response. Try again in a moment.'
          : response.trim());
    } catch (_) {
      // Fallback to mock AI for hackathon demo
      final mockResponse = _generateMockResponse(text);
      setState(() => _reply = mockResponse);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _generateMockResponse(String userInput) {
    final input = userInput.toLowerCase();
    if (input.contains('sad') || input.contains('depressed')) {
      return 'I\'m sorry you\'re feeling down. Try a 4-7-8 breathing exercise: Inhale for 4 seconds, hold for 7, exhale for 8. If this persists, consider talking to a professional.';
    } else if (input.contains('anxious') || input.contains('worried')) {
      return 'Anxiety can be tough. Ground yourself by naming 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.';
    } else if (input.contains('happy') || input.contains('good')) {
      return 'That\'s great to hear! Keep nurturing positive moments. What\'s one thing that made you smile today?';
    } else if (input.contains('exercise') || input.contains('workout')) {
      return 'Physical activity is excellent for mental health. Even a 10-minute walk can boost your mood. What\'s your favorite way to move?';
    } else if (input.contains('sleep')) {
      return 'Good sleep is crucial. Try maintaining a consistent bedtime routine and avoiding screens an hour before bed.';
    } else {
      return 'Thanks for sharing. Remember, it\'s okay to not be okay. If you need immediate help, contact a crisis hotline. What\'s on your mind right now?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.neonCyan),
              const SizedBox(width: 10),
              Text(
                'Calmora AI',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'Q4 local',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
            ),
            child: _loading
                ? const LinearProgressIndicator()
                : Text(_reply, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type what is on your mind',
              suffixIcon: IconButton(
                tooltip: 'Send',
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
              ),
            ),
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
    );
  }
}
