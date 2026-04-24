import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../app/theme_provider.dart';
import '../../app/user_preferences_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../core/widgets/animations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StaggeredAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 80),
            children: [
              if (profile != null) ...[
                _SettingsSection(
                  title: 'Profile',
                  children: [
                    SmoothCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(profile.avatarColorValue),
                            child: Icon(
                              _avatarIconFor(profile.avatarIconCodePoint),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: theme.textTheme.labelLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.role == UserRole.psychologist
                                      ? profile.email ?? 'Psychologist'
                                      : profile.psychologistEmail ??
                                          'No psychologist linked',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit profile',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editProfile(profile),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Theme Section
              _SettingsSection(
                title: 'Appearance',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ThemeButton(
                                title: 'Light',
                                icon: Icons.light_mode,
                                isSelected: currentTheme == AppThemeMode.light,
                                onTap: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(AppThemeMode.light);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ThemeButton(
                                title: 'Dark',
                                icon: Icons.dark_mode,
                                isSelected: currentTheme == AppThemeMode.dark,
                                onTap: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(AppThemeMode.dark);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ThemeButton(
                                title: 'Medical',
                                icon: Icons.health_and_safety,
                                isSelected:
                                    currentTheme == AppThemeMode.medical,
                                onTap: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(AppThemeMode.medical);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _SettingsSection(
                title: 'Notifications',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SettingsToggle(
                          icon: Icons.notifications,
                          title: 'Enable Notifications',
                          subtitle: 'Receive mood check-ins and reminders',
                          value: preferences.notificationsEnabled,
                          onChanged: (value) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updateNotificationsEnabled(value);
                            if (!value) {
                              NotificationService().cancelAllNotifications();
                            } else if (preferences.moodCheckInsEnabled) {
                              _scheduleMoodCheckIns(
                                preferences.moodCheckInInterval,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        _SettingsToggle(
                          icon: Icons.poll,
                          title: 'Mood Check-ins',
                          subtitle:
                              'Random check-ins to log your mood throughout the day',
                          value: preferences.moodCheckInsEnabled,
                          onChanged: (value) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updateMoodCheckInsEnabled(value);
                            if (value) {
                              _scheduleMoodCheckIns(
                                preferences.moodCheckInInterval,
                              );
                            } else {
                              NotificationService().cancelMoodCheckIns();
                            }
                          },
                          enabled: preferences.notificationsEnabled,
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        _SettingsToggle(
                          icon: Icons.medication,
                          title: 'Medication Reminders',
                          subtitle:
                              'Reminders to take your prescribed medication',
                          value: preferences.medicationRemindersEnabled,
                          onChanged: (value) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updateMedicationRemindersEnabled(value);
                          },
                          enabled: preferences.notificationsEnabled,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (preferences.moodCheckInsEnabled)
                    SmoothCard(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.05,
                      ),
                      borderColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in Frequency',
                            style: AppTypography.labelLarge.copyWith(
                              color: theme.textTheme.labelLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: preferences.moodCheckInInterval.toDouble(),
                            min: 2,
                            max: 12,
                            divisions: 5,
                            label: '${preferences.moodCheckInInterval}h',
                            onChanged: (value) {
                              final hours = value.toInt();
                              ref
                                  .read(userPreferencesProvider.notifier)
                                  .updateMoodCheckInInterval(hours);
                              _scheduleMoodCheckIns(hours);
                            },
                          ),
                          Text(
                            'Every ${preferences.moodCheckInInterval} hours',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              _SettingsSection(
                title: 'App Lock',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PIN timeout',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: session.lockTimeoutMinutes.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          label: '${session.lockTimeoutMinutes} min',
                          onChanged: (value) {
                            ref
                                .read(appSessionProvider.notifier)
                                .updateLockTimeout(value.toInt());
                          },
                        ),
                        Text(
                          'Ask for PIN after ${session.lockTimeoutMinutes} minutes away from the app.',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Privacy Section
              _SettingsSection(
                title: 'Privacy & Data',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.success.withOpacity(0.05),
                    borderColor: AppColors.success.withOpacity(0.2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Data is Private',
                                style: AppTypography.labelLarge.copyWith(
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '✓ All data stored locally on your device\n✓ End-to-end encrypted\n✓ Never shared or sold\n✓ You have full control',
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SmoothCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showPrivacyPolicy,
                        ),
                        Divider(height: 1, color: theme.dividerColor),
                        ListTile(
                          leading: const Icon(Icons.bug_report_outlined),
                          title: const Text('Report a Bug'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showBugReport,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About Section
              _SettingsSection(
                title: 'About',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SettingsInfo(
                          label: 'App Version',
                          value: '1.0.0',
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 12),
                        const _SettingsInfo(
                          label: 'Built with',
                          value: 'Flutter + Riverpod',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Made with care for mental wellness',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleMoodCheckIns(int hours) async {
    await NotificationService().scheduleMoodCheckInsEvery(hours);
  }

  void _editProfile(AppProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(
      text: profile.role == UserRole.psychologist
          ? profile.email
          : profile.psychologistEmail,
    );
    var iconCodePoint = profile.avatarIconCodePoint;
    var colorValue = profile.avatarColorValue;
    final icons = [
      Icons.person,
      Icons.self_improvement,
      Icons.favorite,
      Icons.psychology_alt,
    ];
    final colors = [
      AppColors.neonViolet,
      AppColors.neonCyan,
      AppColors.success,
      AppColors.info,
    ];

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: profile.role == UserRole.psychologist
                        ? 'Professional email'
                        : 'Psychologist email',
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  children: icons
                      .map(
                        (icon) => ChoiceChip(
                          selected: iconCodePoint == icon.codePoint,
                          avatar: Icon(icon, size: 18),
                          label: const Text(''),
                          onSelected: (_) => setDialogState(
                            () => iconCodePoint = icon.codePoint,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: colors
                      .map(
                        (color) => ChoiceChip(
                          selected: colorValue == color.value,
                          label: CircleAvatar(
                            radius: 9,
                            backgroundColor: color,
                          ),
                          onSelected: (_) => setDialogState(
                            () => colorValue = color.value,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = profile.copyWith(
                  name: nameController.text.trim(),
                  email: profile.role == UserRole.psychologist
                      ? emailController.text.trim()
                      : profile.email,
                  psychologistEmail: profile.role == UserRole.patient
                      ? emailController.text.trim()
                      : profile.psychologistEmail,
                  avatarIconCodePoint: iconCodePoint,
                  avatarColorValue: colorValue,
                );
                ref.read(appSessionProvider.notifier).updateProfile(updated);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Psychol stores profile, moods, PIN settings, and appointments locally on this device for this prototype. Do not enter emergency or highly sensitive clinical information until production security and consent flows are finalized.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBugReport() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
          'Send issue details to support@psychol.demo with your device, steps to reproduce, and screenshots if available.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
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

/// Settings section header
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Theme button
class _ThemeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodySmall?.color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings toggle
class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: enabled
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        color: enabled
                            ? theme.textTheme.labelLarge?.color
                            : theme.textTheme.labelLarge?.color?.withOpacity(
                                0.5,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: enabled
                        ? theme.textTheme.bodySmall?.color
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled ? value : false,
          onChanged: enabled ? onChanged : null,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

/// Settings info row
class _SettingsInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SettingsInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: theme.textTheme.labelLarge?.color,
          ),
        ),
      ],
    );
  }
}
