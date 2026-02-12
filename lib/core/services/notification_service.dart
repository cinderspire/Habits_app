import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific habit
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required String habitIcon,
    required TimeOfDay time,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B35),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.periodicallyShow(
      id,
      '$habitIcon $habitName',
      'Time to work on your habit! Keep your streak going.',
      RepeatInterval.daily,
      details,
      payload: id.toString(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_achievements',
      'Achievements',
      channelDescription: 'Habit achievements and milestones',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B35),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Persistence helpers for notification preferences
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';

  static Future<bool> getNotificationsEnabled(SharedPreferences prefs) async {
    return prefs.getBool(_keyNotificationsEnabled) ?? false;
  }

  static Future<void> setNotificationsEnabled(SharedPreferences prefs, bool value) async {
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  static TimeOfDay getReminderTime(SharedPreferences prefs) {
    final hour = prefs.getInt(_keyReminderHour) ?? 9;
    final minute = prefs.getInt(_keyReminderMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> setReminderTime(SharedPreferences prefs, TimeOfDay time) async {
    await prefs.setInt(_keyReminderHour, time.hour);
    await prefs.setInt(_keyReminderMinute, time.minute);
  }
}
