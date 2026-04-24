import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../app/app_state.dart';

class AppSessionStore {
  static const _databaseName = 'psychol_demo.db';
  static const _tableName = 'app_state';
  static const _stateKey = 'session';

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, _databaseName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_tableName (id TEXT PRIMARY KEY, payload TEXT NOT NULL)',
        );
      },
    );
  }

  Future<AppSession> load() async {
    final db = await _open();
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [_stateKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return const AppSession();
    }

    final payload = rows.first['payload'] as String;
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final session = _sessionFromJson(data);
    return session.copyWith(
      isLocked: session.onboardingComplete && session.appLockSet,
    );
  }

  Future<void> save(AppSession session) async {
    final db = await _open();
    await db.insert(
      _tableName,
      {
        'id': _stateKey,
        'payload': jsonEncode(_sessionToJson(session)),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, dynamic> _sessionToJson(AppSession session) {
    return {
      'onboardingComplete': session.onboardingComplete,
      'appLockSet': session.appLockSet,
      'lockPin': session.lockPin,
      'profile':
          session.profile == null ? null : _profileToJson(session.profile!),
      'appointments': session.appointments.map(_appointmentToJson).toList(),
      'prescriptions': session.prescriptions.map(_prescriptionToJson).toList(),
      'moodEntries': session.moodEntries.map(_moodEntryToJson).toList(),
      'lastUnlockedAt': session.lastUnlockedAt?.toIso8601String(),
      'lockTimeoutMinutes': session.lockTimeoutMinutes,
      'journalSummary': session.journalSummary,
      'journalUpdatedAt': session.journalUpdatedAt?.toIso8601String(),
    };
  }

  AppSession _sessionFromJson(Map<String, dynamic> json) {
    final appointments = (json['appointments'] as List<dynamic>? ?? [])
        .map((item) => _appointmentFromJson(item as Map<String, dynamic>))
        .toList();
    final prescriptions = (json['prescriptions'] as List<dynamic>? ?? [])
        .map((item) => _prescriptionFromJson(item as Map<String, dynamic>))
        .toList();
    final moodEntries = (json['moodEntries'] as List<dynamic>? ?? [])
        .map((item) => _moodEntryFromJson(item as Map<String, dynamic>))
        .toList();

    return AppSession(
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      appLockSet: json['appLockSet'] as bool? ?? false,
      lockPin: json['lockPin'] as String?,
      profile: json['profile'] == null
          ? null
          : _profileFromJson(json['profile'] as Map<String, dynamic>),
      appointments: appointments,
      prescriptions: prescriptions,
      moodEntries: moodEntries,
      lastUnlockedAt: json['lastUnlockedAt'] == null
          ? null
          : DateTime.tryParse(json['lastUnlockedAt'] as String),
      lockTimeoutMinutes: json['lockTimeoutMinutes'] as int? ?? 10,
      journalSummary: json['journalSummary'] as String? ?? '',
      journalUpdatedAt: json['journalUpdatedAt'] == null
          ? null
          : DateTime.tryParse(json['journalUpdatedAt'] as String),
    );
  }

  Map<String, dynamic> _profileToJson(AppProfile profile) {
    return {
      'role': profile.role.name,
      'name': profile.name,
      'dateOfBirth': profile.dateOfBirth?.toIso8601String(),
      'email': profile.email,
      'psychologistEmail': profile.psychologistEmail,
      'avatarIconCodePoint': profile.avatarIconCodePoint,
      'avatarColorValue': profile.avatarColorValue,
      'profileImagePath': profile.profileImagePath,
    };
  }

  AppProfile _profileFromJson(Map<String, dynamic> json) {
    return AppProfile(
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.patient,
      ),
      name: json['name'] as String? ?? 'Demo Patient',
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      email: json['email'] as String?,
      psychologistEmail: json['psychologistEmail'] as String?,
      avatarIconCodePoint: json['avatarIconCodePoint'] as int? ?? 0xe7fd,
      avatarColorValue: json['avatarColorValue'] as int? ?? 0xFF8B5CF6,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  Map<String, dynamic> _appointmentToJson(Appointment appointment) {
    return {
      'psychologistEmail': appointment.psychologistEmail,
      'psychologistName': appointment.psychologistName,
      'patientName': appointment.patientName,
      'patientEmail': appointment.patientEmail,
      'startsAt': appointment.startsAt.toIso8601String(),
      'type': appointment.type,
      'note': appointment.note,
      'confirmed': appointment.confirmed,
    };
  }

  Appointment _appointmentFromJson(Map<String, dynamic> json) {
    return Appointment(
      psychologistEmail:
          json['psychologistEmail'] as String? ?? demoPsychologistEmail,
      psychologistName: json['psychologistName'] as String? ??
          _psychologistNameForEmail(
            json['psychologistEmail'] as String? ?? demoPsychologistEmail,
          ),
      patientName: json['patientName'] as String? ?? 'Demo Patient',
      patientEmail: json['patientEmail'] as String?,
      startsAt: DateTime.parse(json['startsAt'] as String),
      type: json['type'] as String? ?? 'Video session',
      note: json['note'] as String? ?? '',
      confirmed: json['confirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _prescriptionToJson(Prescription prescription) {
    return {
      'patientName': prescription.patientName,
      'patientEmail': prescription.patientEmail,
      'prescribedByName': prescription.prescribedByName,
      'prescribedByEmail': prescription.prescribedByEmail,
      'medicines': prescription.medicines,
      'note': prescription.note,
      'createdAt': prescription.createdAt.toIso8601String(),
    };
  }

  Prescription _prescriptionFromJson(Map<String, dynamic> json) {
    return Prescription(
      patientName: json['patientName'] as String? ?? 'Patient',
      patientEmail: json['patientEmail'] as String?,
      prescribedByName: json['prescribedByName'] as String? ?? 'Psychologist',
      prescribedByEmail:
          json['prescribedByEmail'] as String? ?? demoPsychologistEmail,
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> _moodEntryToJson(MoodEntry entry) {
    return {
      'createdAt': entry.createdAt.toIso8601String(),
      'value': entry.value,
      'label': entry.label,
      'note': entry.note,
    };
  }

  MoodEntry _moodEntryFromJson(Map<String, dynamic> json) {
    return MoodEntry(
      createdAt: DateTime.parse(json['createdAt'] as String),
      value: json['value'] as int? ?? 3,
      label: json['label'] as String? ?? 'Neutral',
      note: json['note'] as String? ?? '',
    );
  }

  String _psychologistNameForEmail(String email) {
    return demoPsychologists
        .firstWhere(
          (psychologist) => psychologist.email == email,
          orElse: () => AppPsychologist(
            name: 'Linked psychologist',
            email: email,
            specialty: 'Care provider',
            availability: 'By request',
          ),
        )
        .name;
  }
}
