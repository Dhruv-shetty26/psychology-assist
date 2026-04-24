import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/smooth_widgets.dart';

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
            SmoothCard(
              borderRadius: 22,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.72),
              borderColor: AppColors.neonCyan.withOpacity(0.24),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.neonCyan,
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
                  },
                  child: const Text('Send'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SmoothCard(
              borderRadius: 22,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.72),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.self_improvement_outlined,
                  color: AppColors.neonViolet,
                ),
                title: const Text('Mood check-ins'),
                subtitle: const Text('Schedule gentle reminders from 9 AM to 9 PM.'),
                trailing: FilledButton(
                  onPressed: () async {
                    await NotificationService().scheduleMoodCheckInsEvery(4);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alerts scheduled.')),
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
