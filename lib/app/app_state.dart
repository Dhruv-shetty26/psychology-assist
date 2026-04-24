import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/app_session_store.dart';

const demoPsychologistEmail = 'panipuri@macxcode';

enum UserRole { psychologist, patient }

class AppProfile {
  final UserRole role;
  final String name;
  final DateTime? dateOfBirth;
  final String? email;
  final String? psychologistEmail;
  final int avatarIconCodePoint;
  final int avatarColorValue;
  final String? profileImagePath;

  const AppProfile({
    required this.role,
    required this.name,
    this.dateOfBirth,
    this.email,
    this.psychologistEmail,
    this.avatarIconCodePoint = 0xe7fd,
    this.avatarColorValue = 0xFF8B5CF6,
    this.profileImagePath,
  });

  bool get hasPsychologist =>
      psychologistEmail != null && psychologistEmail!.trim().isNotEmpty;

  AppProfile copyWith({
    UserRole? role,
    String? name,
    DateTime? dateOfBirth,
    String? email,
    String? psychologistEmail,
    int? avatarIconCodePoint,
    int? avatarColorValue,
    String? profileImagePath,
  }) {
    return AppProfile(
      role: role ?? this.role,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      psychologistEmail: psychologistEmail ?? this.psychologistEmail,
      avatarIconCodePoint: avatarIconCodePoint ?? this.avatarIconCodePoint,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

class Appointment {
  final String psychologistEmail;
  final String psychologistName;
  final String patientName;
  final String? patientEmail;
  final DateTime startsAt;
  final String type;
  final String note;
  final bool confirmed;

  const Appointment({
    required this.psychologistEmail,
    required this.psychologistName,
    required this.patientName,
    this.patientEmail,
    required this.startsAt,
    required this.type,
    required this.note,
    this.confirmed = false,
  });

  Appointment copyWith({
    String? psychologistEmail,
    String? psychologistName,
    String? patientName,
    String? patientEmail,
    DateTime? startsAt,
    String? type,
    String? note,
    bool? confirmed,
  }) {
    return Appointment(
      psychologistEmail: psychologistEmail ?? this.psychologistEmail,
      psychologistName: psychologistName ?? this.psychologistName,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      startsAt: startsAt ?? this.startsAt,
      type: type ?? this.type,
      note: note ?? this.note,
      confirmed: confirmed ?? this.confirmed,
    );
  }
}

/// Represents a medication time for prescription reminders
class MedicationTime {
  final int hour;
  final int minute;

  const MedicationTime({
    required this.hour,
    required this.minute,
  });

  String toDisplayString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  MedicationTime copyWith({
    int? hour,
    int? minute,
  }) {
    return MedicationTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

class Prescription {
  final String patientName;
  final String? patientEmail;
  final String prescribedByName;
  final String prescribedByEmail;
  final List<String> medicines;
  final List<MedicationTime>
      reminderTimes; // Times to receive medication reminders
  final String note;
  final DateTime createdAt;

  const Prescription({
    required this.patientName,
    this.patientEmail,
    required this.prescribedByName,
    required this.prescribedByEmail,
    required this.medicines,
    this.reminderTimes = const [],
    required this.note,
    required this.createdAt,
  });

  Prescription copyWith({
    String? patientName,
    String? patientEmail,
    String? prescribedByName,
    String? prescribedByEmail,
    List<String>? medicines,
    List<MedicationTime>? reminderTimes,
    String? note,
    DateTime? createdAt,
  }) {
    return Prescription(
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      prescribedByName: prescribedByName ?? this.prescribedByName,
      prescribedByEmail: prescribedByEmail ?? this.prescribedByEmail,
      medicines: medicines ?? this.medicines,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MoodEntry {
  final DateTime createdAt;
  final int value;
  final String label;
  final String note;

  const MoodEntry({
    required this.createdAt,
    required this.value,
    required this.label,
    required this.note,
  });
}

class Prescription {
  final String id;
  final String medicationName;
  final String doctorEmail;
  final String patientEmail;
  final String instructions;
  final int hour;
  final int minute;

  const Prescription({
    required this.id,
    required this.medicationName,
    required this.doctorEmail,
    required this.patientEmail,
    this.instructions = '',
    required this.hour,
    required this.minute,
  });

  Prescription copyWith({
    String? id,
    String? medicationName,
    String? doctorEmail,
    String? patientEmail,
    String? instructions,
    int? hour,
    int? minute,
  }) {
    return Prescription(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      doctorEmail: doctorEmail ?? this.doctorEmail,
      patientEmail: patientEmail ?? this.patientEmail,
      instructions: instructions ?? this.instructions,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

class AppPsychologist {
  final String name;
  final String email;
  final String specialty;
  final String availability;
  final bool acceptingPatients;

  const AppPsychologist({
    required this.name,
    required this.email,
    required this.specialty,
    required this.availability,
    this.acceptingPatients = true,
  });
}

const demoPsychologists = [
  AppPsychologist(
    name: 'Dr. Aisha Mehta',
    email: demoPsychologistEmail,
    specialty: 'Anxiety and young adult care',
    availability: 'Mon, Wed, Fri',
  ),
  AppPsychologist(
    name: 'Dr. Rohan Sen',
    email: 'rohan.sen@psychol.demo',
    specialty: 'CBT and stress management',
    availability: 'Tue, Thu',
  ),
  AppPsychologist(
    name: 'Dr. Kavya Iyer',
    email: 'kavya.iyer@psychol.demo',
    specialty: 'Mood support and sleep',
    availability: 'Weekends',
  ),
];

const demoMedicines = [
  'Prozac',
  'Valium',
  'Sertraline',
  'Lexapro',
  'Wellbutrin',
  'Zoloft',
  'Buspirone',
  'Melatonin',
  'Hydroxyzine',
];

class AppSession {
  final bool onboardingComplete;
  final bool appLockSet;
  final String? lockPin;
  final AppProfile? profile;
  final List<Appointment> appointments;
  final List<Prescription> prescriptions;
  final List<MoodEntry> moodEntries;
  final List<Prescription> prescriptions;
  final bool isLocked;
  final DateTime? lastUnlockedAt;
  final int lockTimeoutMinutes;
  final int currentStreak;
  final int longestStreak;
  final String journalSummary;
  final DateTime? journalUpdatedAt;

  const AppSession({
    this.onboardingComplete = false,
    this.appLockSet = false,
    this.lockPin,
    this.profile,
    this.appointments = const [],
    this.prescriptions = const [],
    this.moodEntries = const [],
    this.prescriptions = const [],
    this.isLocked = false,
    this.lastUnlockedAt,
    this.lockTimeoutMinutes = 10,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.journalSummary = '',
    this.journalUpdatedAt,
  });

  AppSession copyWith({
    bool? onboardingComplete,
    bool? appLockSet,
    String? lockPin,
    AppProfile? profile,
    List<Appointment>? appointments,
    List<Prescription>? prescriptions,
    List<MoodEntry>? moodEntries,
    List<Prescription>? prescriptions,
    bool? isLocked,
    DateTime? lastUnlockedAt,
    int? lockTimeoutMinutes,
    int? currentStreak,
    int? longestStreak,
    String? journalSummary,
    DateTime? journalUpdatedAt,
  }) {
    return AppSession(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      appLockSet: appLockSet ?? this.appLockSet,
      lockPin: lockPin ?? this.lockPin,
      profile: profile ?? this.profile,
      appointments: appointments ?? this.appointments,
      prescriptions: prescriptions ?? this.prescriptions,
      moodEntries: moodEntries ?? this.moodEntries,
      prescriptions: prescriptions ?? this.prescriptions,
      isLocked: isLocked ?? this.isLocked,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      lockTimeoutMinutes: lockTimeoutMinutes ?? this.lockTimeoutMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      journalSummary: journalSummary ?? this.journalSummary,
      journalUpdatedAt: journalUpdatedAt ?? this.journalUpdatedAt,
    );
  }
}

final initialAppSessionProvider = Provider<AppSession>(
  (ref) => const AppSession(),
);

final appSessionStoreProvider = Provider<AppSessionStore>(
  (ref) => AppSessionStore(),
);

final appSessionProvider =
    StateNotifierProvider<AppSessionNotifier, AppSession>(
  (ref) => AppSessionNotifier(
    initialSession: ref.watch(initialAppSessionProvider),
    store: ref.watch(appSessionStoreProvider),
  ),
);

class AppSessionNotifier extends StateNotifier<AppSession> {
  final AppSessionStore _store;

  AppSessionNotifier({
    required AppSession initialSession,
    required AppSessionStore store,
  })  : _store = store,
        super(initialSession);

  void completeOnboarding({
    required AppProfile profile,
    required String lockPin,
  }) {
    state = state.copyWith(
      onboardingComplete: true,
      appLockSet: true,
      lockPin: lockPin,
      profile: profile,
      isLocked: false,
    );
    _persist();
  }

  void addAppointment(Appointment appointment) {
    final updated = [
      ...state.appointments,
      appointment,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    state = state.copyWith(appointments: updated);
    _persist();
  }

  void approveAppointment(Appointment appointment) {
    final updated = state.appointments
        .map((item) =>
            identical(item, appointment) || _sameAppointment(item, appointment)
                ? item.copyWith(confirmed: true)
                : item)
        .toList();
    state = state.copyWith(appointments: updated);
    _persist();
  }

  void removeAppointment(Appointment appointment) {
    final updated = state.appointments
        .where((item) => !_sameAppointment(item, appointment))
        .toList();
    state = state.copyWith(appointments: updated);
    _persist();
  }

  void addPrescription(Prescription prescription) {
  final updated = [...state.prescriptions, prescription];
  state = state.copyWith(prescriptions: updated);
  _persist();
}

void removePrescription(String prescriptionId) {
  final updated =
      state.prescriptions.where((item) => item.id != prescriptionId).toList();
  state = state.copyWith(prescriptions: updated);
  _persist();
}

void updatePrescription(Prescription prescription) {
  final updated = state.prescriptions
      .map((item) => item.id == prescription.id ? prescription : item)
      .toList();
  state = state.copyWith(prescriptions: updated);
  _persist();
}

Map<String, int> _calculateStreaks(List<MoodEntry> entries) {
  if (entries.isEmpty) return {'current': 0, 'longest': 0};

  final days = entries
      .map((e) =>
          DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
      .toSet()
      .toList()
    ..sort();

  int currentStreak = 0;
  int longestStreak = 0;
  int tempStreak = 1;

  for (int i = 1; i < days.length; i++) {
    final diff = days[i].difference(days[i - 1]).inDays;
    if (diff == 1) {
      tempStreak++;
    } else {
      longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      tempStreak = 1;
    }
  }
  longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

  final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final lastDay = days.last;

  if (lastDay == today ||
      lastDay == today.subtract(const Duration(days: 1))) {
    currentStreak = 1;
    for (int i = days.length - 2; i >= 0; i--) {
      if (days[i + 1].difference(days[i]).inDays == 1) {
        currentStreak++;
      } else {
        break;
      }
    }
  }

  return {'current': currentStreak, 'longest': longestStreak};
}

  void updateProfile(AppProfile profile) {
    state = state.copyWith(profile: profile);
    _persist();
  }

  void updateJournalSummary(String summary) {
    state = state.copyWith(
      journalSummary: summary,
      journalUpdatedAt: DateTime.now(),
    );
    _persist();
  }

  void updateLockTimeout(int minutes) {
    state = state.copyWith(lockTimeoutMinutes: minutes);
    _persist();
  }

  void lock() {
    if (state.onboardingComplete && state.appLockSet && !state.isLocked) {
      final lastUnlockedAt = state.lastUnlockedAt;
      final timeout = Duration(minutes: state.lockTimeoutMinutes);
      if (lastUnlockedAt != null &&
          DateTime.now().difference(lastUnlockedAt) < timeout) {
        return;
      }
      state = state.copyWith(isLocked: true);
    }
  }

  bool unlock(String pin) {
    if (pin.trim() == state.lockPin) {
      state = state.copyWith(isLocked: false, lastUnlockedAt: DateTime.now());
      _persist();
      return true;
    }
    return false;
  }

  Future<void> _persist() async {
    await _store.save(state);
  }

  bool _sameAppointment(Appointment a, Appointment b) {
    return a.psychologistEmail == b.psychologistEmail &&
        a.patientName == b.patientName &&
        a.startsAt == b.startsAt &&
        a.type == b.type;
  }
}
