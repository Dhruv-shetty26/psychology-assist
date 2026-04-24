import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../app/home_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/wavy_surface.dart';

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
    final profile = ref.watch(appSessionProvider).profile;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Color(
              profile?.avatarColorValue ?? AppColors.neonViolet.value,
            ),
            backgroundImage: profile?.profileImagePath == null
                ? null
                : FileImage(File(profile!.profileImagePath!)),
            child: profile?.profileImagePath == null
                ? Icon(
                    _avatarIconFor(
                      profile?.avatarIconCodePoint ?? Icons.person.codePoint,
                    ),
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        title: const Text('Calmora'),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 92),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StaggeredAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 80),
              children: [
                WavySurface(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderColor: theme.colorScheme.primary.withValues(alpha: 0.28),
                  waveColorA: Colors.white.withValues(alpha: 0.16),
                  waveColorB: theme.colorScheme.secondary.withValues(alpha: 0.18),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi ${profile?.name ?? 'there'}',
                                    style: AppTypography.headingLarge.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your private, glowing little care space is ready.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: theme.colorScheme.onPrimary
                                          .withValues(alpha: 0.84),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Weekly Mood Trend Card
                SmoothCard(
                  backgroundColor:
                      theme.colorScheme.surface.withOpacity(0.72),
                  borderColor: AppColors.neonViolet.withOpacity(0.18),
                  elevation: 14,
                  borderRadius: 22,
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
                              '${ref.watch(appSessionProvider).moodEntries.length} saved',
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
                            height: _heightForDay(
                              ref.watch(appSessionProvider).moodEntries,
                              i,
                            ),
                            label: [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ][i],
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Insights Card
                SmoothCard(
                  backgroundColor:
                      theme.colorScheme.surface.withOpacity(0.72),
                  borderColor: AppColors.neonCyan.withOpacity(0.24),
                  borderRadius: 22,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week\'s Insights',
                        style: AppTypography.headingSmall.copyWith(
                            color: theme.textTheme.titleMedium?.color),
                      ),
                      const SizedBox(height: 16),
                      _InsightRow(
                        icon: Icons.trending_up,
                        title: 'Latest Mood',
                        value: _latestMoodLabel(
                          ref.watch(appSessionProvider).moodEntries,
                        ),
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
                        value:
                            '${ref.watch(appSessionProvider).moodEntries.length}',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
      ),
    );
  }

  double _heightForDay(List<MoodEntry> entries, int dayIndex) {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final day = weekStart.add(Duration(days: dayIndex));
    final dayEntries = entries.where(
      (entry) =>
          entry.createdAt.year == day.year &&
          entry.createdAt.month == day.month &&
          entry.createdAt.day == day.day,
    );
    if (dayEntries.isEmpty) {
      return 20;
    }
    final average =
        dayEntries.map((entry) => entry.value).reduce((a, b) => a + b) /
            dayEntries.length;
    return 18 + average * 18;
  }

  String _latestMoodLabel(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 'None yet';
    }
    return entries.last.label;
  }

  IconData _avatarIconFor(int codePoint) {
    const icons = [
      Icons.person,
      Icons.self_improvement,
      Icons.favorite,
      Icons.psychology_alt,
    ];
    return icons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.person,
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
