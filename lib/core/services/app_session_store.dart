import 'dart:convert';
import 'package:flutter/material.dart';
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
    try {
      final db = await _open();
      final results = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [_stateKey],
      );

      if (results.isEmpty) {
        // Return a fresh session if nothing was saved
        return const AppSession();
      }

      final payload = jsonDecode(results.first['payload'] as String);
      return _sessionFromJson(payload as Map<String, dynamic>);
    } catch (e) {
      // Return a fresh session on any error
      return const AppSession();
    }
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
      'journalEntries':
          session.journalEntries.map((e) => e.toJson()).toList(),
      'messages': session.messages.map((e) => e.toJson()).toList(),
      'lastUnlockedAt': session.lastUnlockedAt?.toIso8601String(),
      'lockTimeoutMinutes': session.lockTimeoutMinutes,
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
    final journalEntries = (json['journalEntries'] as List<dynamic>? ?? [])
        .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    final messages = (json['messages'] as List<dynamic>? ?? [])
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
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
      journalEntries: journalEntries,
      messages: messages,
      lastUnlockedAt: json['lastUnlockedAt'] == null
          ? null
          : DateTime.parse(json['lastUnlockedAt'] as String),
      lockTimeoutMinutes: json['lockTimeoutMinutes'] as int? ?? 10,
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
      'id': prescription.id,
      'patientName': prescription.patientName,
      'patientEmail': prescription.patientEmail,
      'prescribedByName': prescription.prescribedByName,
      'prescribedByEmail': prescription.prescribedByEmail,
      'medicines': prescription.medicines,
      'reminderTimes': prescription.reminderTimes
          .map((t) => {'hour': t.hour, 'minute': t.minute})
          .toList(),
      'note': prescription.note,
      'createdAt': prescription.createdAt.toIso8601String(),
    };
  }

  Prescription _prescriptionFromJson(Map<String, dynamic> json) {
    final reminderTimes = (json['reminderTimes'] as List<dynamic>? ?? [])
        .map((item) => MedicationTime(
            hour: item['hour'] as int, minute: item['minute'] as int))
        .toList();
    return Prescription(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: json['patientName'] as String? ?? 'Patient',
      patientEmail: json['patientEmail'] as String?,
      prescribedByName: json['prescribedByName'] as String? ?? 'Psychologist',
      prescribedByEmail:
          json['prescribedByEmail'] as String? ?? demoPsychologistEmail,
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      reminderTimes: reminderTimes,
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
