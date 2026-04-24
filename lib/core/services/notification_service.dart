import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

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
    final permissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return permissions ?? false;
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
      'psychol_channel',
      'Psychol Notifications',
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
      'psychol_checkin',
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
        '🎯 How are you feeling?',
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
        '🎯 How are you feeling?',
        'Take a moment to log your mood and reflect on your wellness.',
        details,
      );
    }
  }

  /// Schedule a medication reminder
  Future<void> scheduleMedicationReminder({
    required int hour,
    required int minute,
    required String medicationName,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'psychol_medication',
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
        2000 + hour,
        '💊 Time for your medication',
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
        2000 + hour,
        '💊 Time for your medication',
        'Remember to take $medicationName as prescribed.',
        details,
      );
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
