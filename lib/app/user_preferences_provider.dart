import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for user preferences (theme, notifications, etc.)
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  (ref) => UserPreferencesNotifier(),
);

class UserPreferences {
  final bool notificationsEnabled;
  final bool moodCheckInsEnabled;
  final int moodCheckInInterval; // in hours
  final bool medicationRemindersEnabled;

  UserPreferences({
    this.notificationsEnabled = true,
    this.moodCheckInsEnabled = true,
    this.moodCheckInInterval = 4,
    this.medicationRemindersEnabled = true,
  });

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? moodCheckInsEnabled,
    int? moodCheckInInterval,
    bool? medicationRemindersEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      moodCheckInsEnabled: moodCheckInsEnabled ?? this.moodCheckInsEnabled,
      moodCheckInInterval: moodCheckInInterval ?? this.moodCheckInInterval,
      medicationRemindersEnabled:
          medicationRemindersEnabled ?? this.medicationRemindersEnabled,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(UserPreferences());

  void updateNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void updateMoodCheckInsEnabled(bool enabled) {
    state = state.copyWith(moodCheckInsEnabled: enabled);
  }

  void updateMoodCheckInInterval(int hours) {
    state = state.copyWith(moodCheckInInterval: hours);
  }

  void updateMedicationRemindersEnabled(bool enabled) {
    state = state.copyWith(medicationRemindersEnabled: enabled);
  }
}
