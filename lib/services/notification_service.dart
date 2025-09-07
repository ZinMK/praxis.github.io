import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isAppInForeground = true;

  // Method to check if app is in foreground
  bool get isAppInForeground => _isAppInForeground;

  // Method to update app state
  void updateAppState(bool isInForeground) {
    _isAppInForeground = isInForeground;
  }

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialize settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screens here
  }

  // Schedule a notification for when the timer completes
  Future<void> scheduleTimerCompletionNotification({
    required Duration duration,
    required String slot, // 'morning' or 'evening'
  }) async {
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Calculate when the timer will complete
    final DateTime completionTime = DateTime.now().add(duration);

    // Create notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'meditation_timer',
          'Meditation Timer',
          channelDescription: 'Notifications for meditation timer completion',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm'),
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF4CAF50), // Green color for meditation
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.wav',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notifications.zonedSchedule(
      notificationId,
      'Meditation Complete 🧘‍♀️',
      'Your ${slot} meditation session has finished. Great job!',
      tz.TZDateTime.from(completionTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'meditation_complete_$slot',
    );
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'meditation_timer',
          'Meditation Timer',
          channelDescription: 'Notifications for meditation timer completion',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/launcher_icon',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule daily reminder notifications for morning and evening sessions
  Future<void> scheduleDailyReminders() async {
    // Cancel any existing daily reminders
    await cancelDailyReminders();

    // Import settings
    final morningTimes = await _getMorningTimes();
    final eveningTimes = await _getEveningTimes();
    final notificationsEnabled = await _getNotificationsEnabled();

    if (!notificationsEnabled) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Schedule morning reminder
    final morningStartTime = _timeToDateTime(today, morningTimes[0]);
    final morningReminderTime = morningStartTime.subtract(
      const Duration(minutes: 15),
    );

    // Only schedule if reminder time is in the future
    if (morningReminderTime.isAfter(now)) {
      await _scheduleReminderNotification(
        id: 1001, // Fixed ID for morning reminder
        title: 'Morning Meditation Reminder',
        body: 'Your morning meditation session starts in 15 minutes',
        scheduledTime: morningReminderTime,
        payload: 'morning_reminder',
      );
    }

    // Schedule evening reminder
    final eveningStartTime = _timeToDateTime(today, eveningTimes[0]);
    final eveningReminderTime = eveningStartTime.subtract(
      const Duration(minutes: 15),
    );

    // Only schedule if reminder time is in the future
    if (eveningReminderTime.isAfter(now)) {
      await _scheduleReminderNotification(
        id: 1002, // Fixed ID for evening reminder
        title: 'Evening Meditation Reminder',
        body: 'Your evening meditation session starts in 15 minutes',
        scheduledTime: eveningReminderTime,
        payload: 'evening_reminder',
      );
    }
  }

  // Schedule reminder notification
  Future<void> _scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'meditation_reminders',
          'Meditation Reminders',
          channelDescription: 'Daily reminders for meditation sessions',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm'),
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF2196F3), // Blue color for reminders
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.wav',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Cancel daily reminder notifications
  Future<void> cancelDailyReminders() async {
    await _notifications.cancel(1001); // Morning reminder
    await _notifications.cancel(1002); // Evening reminder
  }

  // Helper method to convert time (e.g., 900) to DateTime
  DateTime _timeToDateTime(DateTime date, int time) {
    final hour = time ~/ 100;
    final minute = time % 100;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Get morning times from settings
  Future<List<int>> _getMorningTimes() async {
    // Import the settings dynamically to avoid circular imports
    final settingsBox = await Hive.openBox("settings");
    final settings = settingsBox.get(
      "settings",
      defaultValue: {"morningStartTime": 900, "morningEndTime": 1000},
    );
    return [settings['morningStartTime'], settings['morningEndTime']];
  }

  // Get evening times from settings
  Future<List<int>> _getEveningTimes() async {
    final settingsBox = await Hive.openBox("settings");
    final settings = settingsBox.get(
      "settings",
      defaultValue: {"eveningStartTime": 1700, "eveningEndTime": 1800},
    );
    return [settings['eveningStartTime'], settings['eveningEndTime']];
  }

  // Get notifications enabled setting
  Future<bool> _getNotificationsEnabled() async {
    final settingsBox = await Hive.openBox("settings");
    final settings = settingsBox.get(
      "settings",
      defaultValue: {"notifications": true},
    );
    return settings['notifications'] ?? true;
  }
}
