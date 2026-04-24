import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  bool _isSubmitted = false;
  late SpeechToText _speechToText;
  bool _isListening = false;

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
    _speechToText = SpeechToText();
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

    setState(() => _isSubmitted = true);
    AppSnackBar.showSuccess(
      context,
      title: 'Mood saved',
      message: 'Your check-in is safely stored.',
      duration: const Duration(milliseconds: 1400),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(selectedTabProvider.notifier).state = 0;
      }
    });
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      final available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _journalController.text = result.recognizedWords;
            });
          },
        );
      } else {
        AppSnackBar.showError(
          context,
          title: 'Speech not available',
          message: 'Speech recognition is not available on this device.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

              // Date header
              Text(
                'How are you feeling today?',
                style: AppTypography.displayMedium.copyWith(
                  color: theme.textTheme.displayMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your response helps us understand your wellness journey.',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Mood Selection Grid
              SmoothCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
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
                    const SizedBox(height: 16),
                    if (_selectedMoodIndex != null)
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          'Feeling ${_moods[_selectedMoodIndex!].label.toLowerCase()}',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Journal Section
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a Note (Optional)',
                      style: AppTypography.headingSmall.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'What\'s on your mind? Keep it brief and honest.',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _journalController,
                      maxLines: 4,
                      enabled: !_isSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: _isListening
                                ? AppColors.error
                                : AppColors.neonCyan,
                          ),
                          onPressed: _toggleListening,
                        ),
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your entries are private and never shared.',
                      style: AppTypography.captionSmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (!_isSubmitted)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SmoothButton(
                        onPressed: _submitMood,
                        label: 'Save Mood Entry',
                        backgroundColor: theme.colorScheme.primary,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        isLoading: _isSubmitted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SmoothButton(
                        onPressed: () {
                          ref.read(selectedTabProvider.notifier).state = 0;
                        },
                        label: 'Cancel',
                        isOutlined: true,
                        backgroundColor: theme.colorScheme.primary,
                        textColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                )
              else
                SmoothCard(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                  borderColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mood saved successfully!',
                          style: AppTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
