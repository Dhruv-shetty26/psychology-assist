import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final _speech = stt.SpeechToText();
  final _ai = OllamaService(
    endpoint: Uri.parse('http://10.0.2.2:11434/api/generate'),
  );
  String _reply =
      'Ask for a grounding exercise, journaling prompt, or appointment prep.';
  bool _loading = false;
  bool _listening = false;

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
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
      setState(() => _reply =
          'Local quantized AI is configured for ${OllamaService.defaultQuantizedModel}, but Ollama is not reachable yet. Start Ollama on port 11434 or update the endpoint for your device.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize();
    if (!available) {
      setState(() => _reply = 'Speech recognition permission is not available.');
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() => _controller.text = result.recognizedWords);
      },
    );
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
              hintText: 'Type or dictate what is on your mind',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Voice to text',
                    onPressed: _toggleVoice,
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
    );
  }
}
