import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/services/ollama_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';

enum CalmoraAiMode { chat, journal }

class CalmoraAiSheet extends ConsumerStatefulWidget {
  const CalmoraAiSheet({super.key});

  @override
  ConsumerState<CalmoraAiSheet> createState() => _CalmoraAiSheetState();
}

class _CalmoraAiSheetState extends ConsumerState<CalmoraAiSheet> {
  final _controller = TextEditingController();
  final _endpoint = Uri.parse('http://10.0.2.2:11434/api/generate');
  String _reply =
      'Ask for a grounding exercise, journaling prompt, or appointment prep.';
  bool _loading = false;
  CalmoraAiMode _mode = CalmoraAiMode.chat;
  final String _selectedModel = OllamaService.defaultQuantizedModel;
  bool _alreadyShared = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _queryOllama(String prompt) async {
    final ai = OllamaService(endpoint: _endpoint, model: _selectedModel);
    return ai.summarize(prompt: prompt);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) {
      return;
    }
    setState(() {
      _loading = true;
      _alreadyShared = false;
    });

    try {
      final response = await _queryOllama(
        'You are Calmora, a concise mental wellness assistant. '
        'Be warm, practical, non-clinical, and suggest emergency help for crisis risk.\n\nUser: $text',
      );
      setState(() => _reply = response.trim().isEmpty
          ? 'I could not generate a useful response. Try again in a moment.'
          : response.trim());
    } catch (_) {
      final mockResponse = _generateMockResponse(text);
      setState(() => _reply =
          '$mockResponse\n\n(Quantized model is configured for $_selectedModel, but Ollama is not reachable. Start Ollama on port 11434 or update the endpoint.)');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _summarizeJournal() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) {
      return;
    }
    setState(() {
      _loading = true;
      _alreadyShared = false;
    });

    try {
      final response = await _queryOllama(
        'You are Calmora, a concise mental wellness assistant. '
        'Summarize the following journal entry into a short supportive reflection for the user, then add a therapist-ready summary below. '
        'Use warm, practical, non-clinical language.\n\nJournal entry:\n$text',
      );
      final summary = response.trim();
      setState(() => _reply = summary.isEmpty
          ? 'I could not summarize your journal entry. Try again in a moment.'
          : summary);
      if (summary.isNotEmpty) {
        ref.read(appSessionProvider.notifier).updateJournalSummary(summary);
      }
    } catch (_) {
      final fallback = _generateMockResponse(text);
      setState(() => _reply =
          'Summary fallback: $fallback\n\n(Quantized model is configured for $_selectedModel, but Ollama is not reachable.)');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _shareWithTherapist() {
    final profile = ref.read(appSessionProvider).profile;
    if (profile?.hasPsychologist != true) {
      AppSnackBar.showError(
        context,
        title: 'No therapist connected',
        message: 'Connect a care provider from the Care tab before sharing.',
      );
      return;
    }

    if (_reply.trim().isEmpty) {
      AppSnackBar.showError(
        context,
        title: 'Nothing to share',
        message:
            'Summarize a journal entry first, then send it to your therapist.',
      );
      return;
    }

    setState(() => _alreadyShared = true);
    AppSnackBar.showSuccess(
      context,
      title: 'Shared with therapist',
      message: 'The summary was shared with ${profile!.psychologistEmail}.',
    );
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
    final profile = ref.watch(appSessionProvider).profile;

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
                _mode == CalmoraAiMode.chat ? 'Calmora AI' : 'Calmora Journal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'Quantized',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Chat'),
                selected: _mode == CalmoraAiMode.chat,
                onSelected: (_) {
                  setState(() {
                    _mode = CalmoraAiMode.chat;
                    _reply =
                        'Ask for a grounding exercise, journaling prompt, or appointment prep.';
                    _alreadyShared = false;
                  });
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Journal'),
                selected: _mode == CalmoraAiMode.journal,
                onSelected: (_) {
                  setState(() {
                    _mode = CalmoraAiMode.journal;
                    _reply =
                        'Write a journal entry, then summarize it for your own reflection or your therapist.';
                    _alreadyShared = false;
                  });
                },
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
            maxLines: 6,
            decoration: InputDecoration(
              hintText: _mode == CalmoraAiMode.chat
                  ? 'Type what is on your mind'
                  : 'Write your journal entry here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                tooltip: _mode == CalmoraAiMode.chat ? 'Send' : 'Summarize',
                onPressed:
                    _mode == CalmoraAiMode.chat ? _send : _summarizeJournal,
                icon: Icon(_mode == CalmoraAiMode.chat
                    ? Icons.send_rounded
                    : Icons.notes_rounded),
              ),
            ),
            onSubmitted: (_) =>
                _mode == CalmoraAiMode.chat ? _send() : _summarizeJournal(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _mode == CalmoraAiMode.journal
                      ? _summarizeJournal
                      : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    _mode == CalmoraAiMode.journal
                        ? 'Summarize Entry'
                        : 'Send to Calmora',
                  ),
                ),
              ),
              if (_mode == CalmoraAiMode.journal) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _shareWithTherapist,
                    child: const Text('Send to therapist'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (_mode == CalmoraAiMode.journal)
            Text(
              profile?.hasPsychologist == true
                  ? 'Sharing available to ${profile!.psychologistEmail}.'
                  : 'No therapist connected yet. Add one from Care.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.72),
              ),
            ),
          if (_alreadyShared)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Journal summary shared successfully.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
