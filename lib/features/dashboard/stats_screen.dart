import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/smooth_widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final entries = session.moodEntries.toList();
    final averageMood = entries.isEmpty
        ? 0.0
        : entries.map((entry) => entry.value).reduce((a, b) => a + b) /
            entries.length;
    final recentEntries = entries.reversed.take(5).toList();
    final weeklyTrend = _buildWeeklyTrend(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            SmoothCard(
              borderRadius: 24,
              borderColor: AppColors.neonViolet.withOpacity(0.18),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wellness stats',
                    style: AppTypography.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A quick view of your mood entries and notes.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _StatTile(
                        label: 'Total entries',
                        value: '${entries.length}',
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        label: 'Average mood',
                        value: averageMood.toStringAsFixed(1),
                        color: AppColors.neonViolet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmoothCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly trend', style: AppTypography.headingSmall),
                  const SizedBox(height: 14),
                  Column(
                    children: weeklyTrend
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.day, style: AppTypography.bodyMedium),
                                Text('${item.count} entries',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.lightSubtext,
                                    )),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmoothCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent journal notes',
                      style: AppTypography.headingSmall),
                  const SizedBox(height: 12),
                  if (recentEntries.isEmpty)
                    Text(
                      'No journal notes yet. Add a mood entry to start tracking.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.lightSubtext,
                      ),
                    )
                  else
                    ...recentEntries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _JournalPreview(entry: entry),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_WeeklyTrendItem> _buildWeeklyTrend(List<MoodEntry> entries) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final count = entries.where((entry) {
        return entry.createdAt.year == day.year &&
            entry.createdAt.month == day.month &&
            entry.createdAt.day == day.day;
      }).length;
      return _WeeklyTrendItem(
        day: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
        count: count,
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(color: color)),
            const SizedBox(height: 8),
            Text(value,
                style: AppTypography.headingSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTrendItem {
  final String day;
  final int count;

  _WeeklyTrendItem({required this.day, required this.count});
}

class _JournalPreview extends StatelessWidget {
  final MoodEntry entry;

  const _JournalPreview({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.label,
                style: AppTypography.labelLarge,
              ),
              Text(
                '${entry.createdAt.day}/${entry.createdAt.month}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.lightSubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.note.isEmpty ? 'No note added.' : entry.note,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
