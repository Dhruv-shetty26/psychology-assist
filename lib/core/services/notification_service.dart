import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../../app/app_state.dart';

/// Service for managing local notifications (mood check-ins, medication reminders)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android initialization settings
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidPermissions ?? iosPermissions ?? false;
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'calmora_channel',
      'Calmora Notifications',
      channelDescription: 'Mood check-ins and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a mood check-in notification
  /// [hour] - Hour of the day (0-23)
  /// [minute] - Minute of the hour (0-59)
  Future<void> scheduleMoodCheckIn({
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'calmora_checkin',
      'Mood Check-ins',
      channelDescription: 'Daily mood check-in reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        1000 + hour,
        'Mood check-in',
        'Take a moment to log your mood and reflect on your wellness.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Fallback for older versions
      await _notificationsPlugin.show(
        1000 + hour,
        'Mood check-in',
        'Take a moment to log your mood and reflect on your wellness.',
        details,
      );
    }
  }

  Future<void> scheduleMoodCheckInsEvery(int hours) async {
    final interval = hours.clamp(2, 12);
    await cancelMoodCheckIns();
    for (var hour = 9; hour <= 21; hour += interval) {
      await scheduleMoodCheckIn(hour: hour, minute: 0);
    }
  }

  Future<void> cancelMoodCheckIns() async {
    for (var hour = 0; hour < 24; hour++) {
      await _notificationsPlugin.cancel(1000 + hour);
    }
  }

  /// Schedule a medication reminder
  Future<void> scheduleMedicationReminder({
    required int hour,
    required int minute,
    required String medicationName,
    int id = 2000,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'calmora_medication',
      'Medication Reminders',
      channelDescription: 'Daily medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'Medication reminder',
        'Remember to take $medicationName as prescribed.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Fallback for older versions
      await _notificationsPlugin.show(
        id,
        'Medication reminder',
        'Remember to take $medicationName as prescribed.',
        details,
      );
    }
  }

  /// Schedule all medication reminders from a list of medicines and times
  /// This will schedule daily repeating reminders at the specified times
  Future<void> scheduleMedicationReminders({
    required List<String> medicines,
    required List<({int hour, int minute})> times,
  }) async {
    // Cancel existing medication reminders first
    await cancelMedicationReminders();

    if (medicines.isEmpty || times.isEmpty) return;

    final medicineList = medicines.join(', ');

    for (var i = 0; i < times.length; i++) {
      final time = times[i];
      await _scheduleDailyMedicationReminder(
        hour: time.hour,
        minute: time.minute,
        medicationName: medicineList,
        id: 2000 + i,
      );
    }
  }

  /// Schedule a daily repeating medication reminder at a specific time
  Future<void> _scheduleDailyMedicationReminder({
    required int hour,
    required int minute,
    required String medicationName,
    required int id,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'calmora_medication',
      'Medication Reminders',
      channelDescription: 'Daily medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        '💊 Medication Reminder',
        'Time to take: $medicationName',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Fallback for older versions
      await _notificationsPlugin.show(
        id,
        '💊 Medication Reminder',
        'Time to take: $medicationName',
        details,
      );
    }
  }

  /// Cancel all medication reminders
  Future<void> cancelMedicationReminders() async {
    for (var i = 0; i < 10; i++) {
      await _notificationsPlugin.cancel(2000 + i);
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
