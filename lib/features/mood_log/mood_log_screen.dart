import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../app/home_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/smooth_widgets.dart';

class MoodLogScreen extends ConsumerStatefulWidget {
  const MoodLogScreen({super.key});

  @override
  ConsumerState<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends ConsumerState<MoodLogScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  final _journalController = TextEditingController();
  late AnimationController _animationController;

  final List<_MoodOption> _moods = [
    _MoodOption(
      icon: Icons.sentiment_very_dissatisfied,
      label: 'Terrible',
      color: AppColors.error,
      value: 1,
    ),
    _MoodOption(
      icon: Icons.sentiment_dissatisfied,
      label: 'Poor',
      color: AppColors.warning,
      value: 2,
    ),
    _MoodOption(
      icon: Icons.sentiment_neutral,
      label: 'Neutral',
      color: AppColors.info,
      value: 3,
    ),
    _MoodOption(
      icon: Icons.sentiment_satisfied_alt,
      label: 'Good',
      color: AppColors.success,
      value: 4,
    ),
    _MoodOption(
      icon: Icons.sentiment_very_satisfied,
      label: 'Excellent',
      color: AppColors.neonViolet,
      value: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _journalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitMood() {
    if (_selectedMoodIndex == null) {
      AppSnackBar.showError(
        context,
        title: 'Pick a mood',
        message: 'Please select a mood to continue.',
        duration: const Duration(milliseconds: 2000),
      );
      return;
    }

    final mood = _moods[_selectedMoodIndex!];
    ref.read(appSessionProvider.notifier).addMoodEntry(
          MoodEntry(
            createdAt: DateTime.now(),
            value: mood.value,
            label: mood.label,
            note: _journalController.text.trim(),
          ),
        );

    setState(() {
      _selectedMoodIndex = null;
      _journalController.clear();
    });

    AppSnackBar.showSuccess(
      context,
      title: 'Mood saved',
      message: 'Your entry is saved to your journal.',
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(appSessionProvider);
    final entries = session.moodEntries.reversed.toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Your Mood'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(selectedTabProvider.notifier).state = 0;
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Journal & Mood Notes',
                style: AppTypography.displayMedium.copyWith(
                  color: theme.textTheme.displayMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Capture your mood, thoughts, and calm reflections in one place.',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select your feeling',
                      style: AppTypography.labelLarge.copyWith(
                        color: theme.textTheme.labelLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        _moods.length,
                        (index) => _MoodSelector(
                          mood: _moods[index],
                          isSelected: _selectedMoodIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedMoodIndex = index;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_selectedMoodIndex != null)
                      Text(
                        'Feeling ${_moods[_selectedMoodIndex!].label.toLowerCase()}',
                        style: AppTypography.labelLarge.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a Note',
                      style: AppTypography.headingSmall.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Capture a quick thought, reflection, or detail from your day.',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _journalController,
                      minLines: 6,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Write freely — this is your private space.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your entries are private and stored locally on this device.',
                      style: AppTypography.captionSmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: SmoothButton(
                  onPressed: _submitMood,
                  label: 'Save Mood Entry',
                  backgroundColor: theme.colorScheme.primary,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (entries.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent journal entries',
                      style: AppTypography.headingSmall.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...entries.take(5).map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SmoothCard(
                              borderRadius: 18,
                              padding: const EdgeInsets.all(16),
                              backgroundColor:
                                  theme.colorScheme.surface.withOpacity(0.8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.label,
                                        style: AppTypography.labelLarge,
                                      ),
                                      Text(
                                        '${entry.createdAt.day}/${entry.createdAt.month} ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color:
                                              theme.textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    entry.note.isEmpty
                                        ? 'No additional note provided.'
                                        : entry.note,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                )
              else
                SmoothCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.72),
                  child: Text(
                    'No journal entries yet. Save a mood entry to start building your notes.',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mood option data class
class _MoodOption {
  final IconData icon;
  final String label;
  final Color color;
  final int value;

  _MoodOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
  });
}

/// Individual mood selector button
class _MoodSelector extends StatefulWidget {
  final _MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodSelector({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<_MoodSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant _MoodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.15).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        ),
        child: Container(
          width: 70,
          height: 90,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.mood.color.withOpacity(0.15)
                : Colors.transparent,
            border: Border.all(
              color: widget.isSelected
                  ? widget.mood.color
                  : Theme.of(context).dividerColor,
              width: widget.isSelected ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.mood.icon,
                color: widget.isSelected
                    ? widget.mood.color
                    : Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                widget.mood.label,
                style: AppTypography.labelSmall.copyWith(
                  color: widget.isSelected
                      ? widget.mood.color
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
