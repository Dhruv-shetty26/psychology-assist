import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../core/widgets/wavy_surface.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            WavySurface(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.95),
                  theme.colorScheme.tertiary.withValues(alpha: 0.86),
                ],
              ),
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.28),
              waveColorA: Colors.white.withValues(alpha: 0.16),
              waveColorB: theme.colorScheme.secondary.withValues(alpha: 0.18),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calmora alerts',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gentle check-ins that feel intentional, not noisy.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.82,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SmoothCard(
              borderRadius: 22,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.72),
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.24),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Test alert'),
                subtitle: const Text('Send a Calmora notification now.'),
                trailing: FilledButton(
                  onPressed: () async {
                    await NotificationService().showNotification(
                      id: 77,
                      title: 'Calmora check-in',
                      body: 'Take one slow breath and notice how you feel.',
                    );
                    if (context.mounted) {
                      AppSnackBar.showSuccess(
                        context,
                        title: 'Alert sent',
                        message: 'Your test notification was delivered.',
                      );
                    }
                  },
                  child: const Text('Send'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SmoothCard(
              borderRadius: 22,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.72),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.self_improvement_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text('Mood check-ins'),
                subtitle: const Text(
                  'Schedule gentle reminders from 9 AM to 9 PM.',
                ),
                trailing: FilledButton(
                  onPressed: () async {
                    await NotificationService().scheduleMoodCheckInsEvery(4);
                    if (context.mounted) {
                      AppSnackBar.showSuccess(
                        context,
                        title: 'Alerts scheduled',
                        message: 'Mood check-ins are ready from 9 AM to 9 PM.',
                      );
                    }
                  },
                  child: const Text('Schedule'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
