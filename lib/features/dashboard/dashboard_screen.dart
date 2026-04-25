import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../app/home_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../core/widgets/animations.dart';
import '../calmora/calmora_ai_sheet.dart';
import 'stats_screen.dart';

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
    final scheme = theme.colorScheme;
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final upcomingAppointment = session.appointments.where((appointment) {
      if (profile?.role == UserRole.psychologist) {
        return appointment.psychologistEmail == profile?.email &&
            appointment.startsAt.isAfter(DateTime.now());
      }
      return profile?.email != null &&
          appointment.patientEmail?.toLowerCase() ==
              profile!.email!.toLowerCase() &&
          appointment.startsAt.isAfter(DateTime.now());
    }).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final nextAppointment = upcomingAppointment.isEmpty
        ? 'No upcoming sessions'
        : '${upcomingAppointment.first.type} at ${upcomingAppointment.first.startsAt.hour.toString().padLeft(2, '0')}:${upcomingAppointment.first.startsAt.minute.toString().padLeft(2, '0')}';

    final relatedPrescriptions = session.prescriptions.where((item) {
      if (profile?.role == UserRole.psychologist) {
        return item.prescribedByEmail == profile?.email;
      }
      return profile?.email != null &&
          item.patientEmail?.toLowerCase() == profile!.email!.toLowerCase();
    }).toList()
      ..sort((a, b) {
        return a.reminderTimes.isNotEmpty && b.reminderTimes.isNotEmpty
            ? a.reminderTimes.first.hour
                        .compareTo(b.reminderTimes.first.hour) !=
                    0
                ? a.reminderTimes.first.hour
                    .compareTo(b.reminderTimes.first.hour)
                : a.reminderTimes.first.minute
                    .compareTo(b.reminderTimes.first.minute)
            : 0;
      });
    final nextPrescription = relatedPrescriptions.isEmpty
        ? 'No reminders set'
        : '${relatedPrescriptions.first.medicines.join(', ')} at ${relatedPrescriptions.first.reminderTimes.isNotEmpty ? relatedPrescriptions.first.reminderTimes.first.toDisplayString() : 'No time'}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: GestureDetector(
            onTap: () {
              ref.read(selectedTabProvider.notifier).state = 4; // Go to settings
            },
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
                      size: 20,
                    )
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              profile?.name ?? 'Welcome',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StatsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.insights_outlined,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            tooltip: 'View stats',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, bottom: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StaggeredAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 80),
              children: [
                // ── Streak Banner ──
                if (session.currentStreak > 0 || session.moodEntries.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.12),
                          scheme.tertiary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: scheme.secondary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            session.currentStreak > 0
                                ? '${session.currentStreak} day streak — keep it going!'
                                : 'Log a mood today to start your streak',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (profile?.role == UserRole.patient) ...[
                  const SizedBox(height: 20),
                  _buildAiBanner(context, scheme),
                ],
                const SizedBox(height: 20),

                // ── Quick Stats Row ──
                _SectionLabel(title: 'Quick Overview', scheme: scheme),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardStat(
                        label: 'Next session',
                        value: nextAppointment,
                        icon: Icons.event_available_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardStat(
                        label: 'Next reminder',
                        value: nextPrescription,
                        icon: Icons.medication_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Weekly Mood Trend Card ──
                _SectionLabel(title: 'Mood Trend', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.primary.withValues(alpha: 0.12),
                  elevation: 0,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'This Week',
                            style: AppTypography.labelLarge.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${session.moodEntries.length} saved',
                              style: AppTypography.labelSmall.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          7,
                          (i) => _MoodBar(
                            height: _heightForDay(session.moodEntries, i),
                            label: [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ][i],
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quick Insights Card ──
                _SectionLabel(title: 'Insights', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.secondary.withValues(alpha: 0.12),
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InsightRow(
                        icon: Icons.trending_up,
                        title: 'Latest Mood',
                        value: _latestMoodLabel(session.moodEntries),
                        theme: theme,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.08)),
                      ),
                      _InsightRow(
                        icon: Icons.calendar_today,
                        title: 'Total Entries',
                        value: '${session.moodEntries.length}',
                        theme: theme,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.08)),
                      ),
                      _InsightRow(
                        icon: Icons.local_fire_department,
                        title: 'Longest Streak',
                        value: '${session.longestStreak} days',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Main CTA Button ──
                SizedBox(
                  width: double.infinity,
                  child: SmoothButton(
                    onPressed: () {
                      ref.read(selectedTabProvider.notifier).state = 1;
                    },
                    label: '+ Log Mood',
                    backgroundColor: scheme.primary,
                    textColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: 16,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const StatsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.insights_outlined, size: 18),
                    label: const Text('View full stats'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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

  Widget _buildAiBanner(BuildContext context, ColorScheme scheme) {
    return GestureDetector(
      onTap: () => _showAiChat(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              scheme.primary,
              scheme.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, Try CalmoraAI',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your private, intelligent wellness companion.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showAiChat(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: CalmoraAiSheet(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Section label widget
class _SectionLabel extends StatelessWidget {
  final String title;
  final ColorScheme scheme;

  const _SectionLabel({required this.title, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 0.8,
        fontSize: 12,
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
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          height: height,
          width: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          curve: Curves.easeOutCubic,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
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
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.85),
      borderColor: scheme.primary.withValues(alpha: 0.1),
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: scheme.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
