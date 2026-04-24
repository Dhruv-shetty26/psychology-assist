import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/home_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../core/widgets/animations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Wellness'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'This week',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StaggeredAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 80),
            children: [
              // Weekly Mood Trend Card
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mood Trend',
                          style: AppTypography.headingSmall.copyWith(
                              color: theme.textTheme.titleMedium?.color),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '↑ +8%',
                            style: AppTypography.labelMedium.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Simple bar chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        7,
                        (i) => _MoodBar(
                          height: 30 + (i % 3) * 20,
                          label: [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ][i],
                          color: [
                            AppColors.moodPoor,
                            AppColors.moodGood,
                            AppColors.moodGood,
                            AppColors.moodExcellent,
                            AppColors.moodNeutral,
                            AppColors.moodGood,
                            AppColors.moodExcellent,
                          ][i],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Insights Card
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week\'s Insights',
                      style: AppTypography.headingSmall
                          .copyWith(color: theme.textTheme.titleMedium?.color),
                    ),
                    const SizedBox(height: 16),
                    _InsightRow(
                      icon: Icons.trending_up,
                      title: 'Best Mood',
                      value: 'Thursday',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: theme.dividerColor,
                    ),
                    const SizedBox(height: 12),
                    _InsightRow(
                      icon: Icons.calendar_today,
                      title: 'Total Entries',
                      value: '5 of 7 days',
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Wellness Tip Card
              SmoothCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                borderColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wellness Tip',
                            style: AppTypography.labelLarge.copyWith(
                                color: theme.textTheme.labelLarge?.color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Regular mood tracking helps identify patterns and triggers.',
                            style: AppTypography.bodySmall.copyWith(
                                color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main CTA Button
              SizedBox(
                width: double.infinity,
                child: SmoothButton(
                  onPressed: () {
                    ref.read(selectedTabProvider.notifier).state = 1;
                  },
                  label: '+ Log Mood',
                  backgroundColor: theme.colorScheme.primary,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

/// Individual mood bar for the chart
class _MoodBar extends StatelessWidget {
  final double height;
  final String label;
  final Color color;

  const _MoodBar({
    required this.height,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          height: height,
          width: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          curve: Curves.easeOutCubic,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

/// Insight row widget
class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ThemeData theme;

  const _InsightRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall
                      .copyWith(color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: theme.textTheme.titleMedium?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
