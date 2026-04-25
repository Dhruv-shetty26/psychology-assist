import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../core/services/ollama_service.dart';
import '../../core/widgets/app_snackbar.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final journalEntries = session.journalEntries.reversed.toList();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal History'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Journal Entries',
              style: AppTypography.headingMedium.copyWith(
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View your journal entries and reflections.',
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            if (journalEntries.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        size: 64,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No journal entries yet',
                        style: AppTypography.bodyMedium.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: journalEntries.length,
                  itemBuilder: (context, index) {
                    final entry = journalEntries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _JournalEntryCard(entry: entry),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntryCard extends ConsumerStatefulWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  ConsumerState<_JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends ConsumerState<_JournalEntryCard> {
  bool _isSummarizing = false;

  Future<void> _summarize() async {
    setState(() => _isSummarizing = true);
    try {
      final ai = OllamaService(endpoint: Uri.parse('http://10.16.209.73:8000/chat'));
      final prompt = 'You are Calmora, a concise mental wellness assistant. '
          'Summarize the following journal entry into a short supportive reflection for the user, then add a therapist-ready summary below. '
          'Use warm, practical, non-clinical language.\n\nJournal entry:\n${widget.entry.content}';
      final response = await ai.summarize(prompt: prompt);
      
      final updatedEntry = widget.entry.copyWith(summary: response.trim());
      ref.read(appSessionProvider.notifier).updateJournalEntry(updatedEntry);
      
      if (mounted) {
        AppSnackBar.showSuccess(context, title: 'AI Summary Generated', message: 'Your entry has been summarized.');
      }
    } catch (_) {
      if (mounted) {
        // Fallback for demo if ollama fails
        final fallback = 'Summary: The user is expressing their thoughts. Action: Recommend a breathing exercise.';
        final updatedEntry = widget.entry.copyWith(summary: fallback);
        ref.read(appSessionProvider.notifier).updateJournalEntry(updatedEntry);
        AppSnackBar.showInfo(context, title: 'Fallback Summary Generated', message: 'Ollama unreachable. Used local fallback.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSummarizing = false);
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

    final updatedEntry = widget.entry.copyWith(sharedWithPsychologist: true);
    ref.read(appSessionProvider.notifier).updateJournalEntry(updatedEntry);

    AppSnackBar.showSuccess(
      context,
      title: 'Shared with therapist',
      message: 'The summary was shared with ${profile!.psychologistEmail}.',
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildTruncatedText(BuildContext context, String text) {
    final theme = Theme.of(context);
    const maxLength = 200;
    if (text.length <= maxLength) {
      return Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: theme.textTheme.bodyMedium?.color,
          height: 1.6,
        ),
      );
    }

    final truncatedText = text.substring(0, maxLength);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$truncatedText...',
          style: AppTypography.bodyMedium.copyWith(
            color: theme.textTheme.bodyMedium?.color,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Full Entry'),
                content: SingleChildScrollView(
                  child: Text(
                    text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.6,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'Read more',
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entry = widget.entry;

    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.8),
      borderColor: entry.sharedWithPsychologist 
          ? scheme.primary.withValues(alpha: 0.5)
          : scheme.primary.withValues(alpha: 0.12),
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(entry.createdAt),
                style: AppTypography.labelSmall.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
              if (entry.sharedWithPsychologist)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 12, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Shared with Therapist',
                        style: AppTypography.caption.copyWith(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTruncatedText(context, entry.content),
          const SizedBox(height: 16),
          if (entry.summary != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'AI Summary',
                        style: AppTypography.labelSmall.copyWith(color: scheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.summary!,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (entry.summary == null)
                TextButton.icon(
                  onPressed: _isSummarizing ? null : _summarize,
                  icon: _isSummarizing 
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: Text(_isSummarizing ? 'Summarizing...' : 'Summarize with AI'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.primary,
                  ),
                ),
              if (entry.summary != null && !entry.sharedWithPsychologist)
                FilledButton.icon(
                  onPressed: _shareWithTherapist,
                  icon: const Icon(Icons.share, size: 14),
                  label: const Text('Send to Therapist'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
