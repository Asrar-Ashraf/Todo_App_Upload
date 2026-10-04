import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart' hide Priority;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (!_supported || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final timezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezone.identifier));
      } catch (_) {
        _setFallbackLocation();
      }
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings);
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'task_reminders',
          'Task reminders',
          description: 'Reminders for your TaskFlow tasks',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<bool> requestPermission() async {
    if (!_supported) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final notificationsAllowed =
            await android?.requestNotificationsPermission() ?? true;
        if (!notificationsAllowed) return false;
        await android?.requestExactAlarmsPermission();
        return notificationsAllowed;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    } catch (e) {
      debugPrint('Notification error: $e');
      return false;
    }
  }

  Future<bool> areNotificationsAllowed() async {
    if (!_supported) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.areNotificationsEnabled() ?? true;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final settings = await ios?.checkPermissions();
      if (settings == null) return false;
      return settings.isEnabled;
    } catch (e) {
      debugPrint('Notification error: $e');
      return false;
    }
  }

  Future<void> scheduleForTask(Task task) async {
    if (!_supported) return;
    try {
      final id = _notificationId(task.id);
      await _plugin.cancel(id);
      final dueDate = task.dueDate;
      if (!task.reminderEnabled ||
          dueDate == null ||
          !task.hasTime ||
          task.isDone) {
        return;
      }
      final trigger = dueDate.subtract(
        Duration(minutes: task.reminderMinutesBefore),
      );
      if (!trigger.isAfter(DateTime.now())) return;

      final body = task.reminderMinutesBefore == 0
          ? "It's time for your task · ${task.category.label}"
          : '${_reminderLead(task.reminderMinutesBefore)} · ${_formatTime(dueDate)}';
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task reminders',
          channelDescription: 'Reminders for your TaskFlow tasks',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final exactAllowed =
          !Platform.isAndroid ||
          (await android?.canScheduleExactNotifications() ?? true);
      await _plugin.zonedSchedule(
        id,
        task.title,
        body,
        tz.TZDateTime.from(trigger, tz.local),
        details,
        androidScheduleMode: exactAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: task.id,
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<void> cancelForTask(String taskId) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(_notificationId(taskId));
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<void> rescheduleAll(List<Task> tasks) async {
    if (!_supported) return;
    try {
      await _plugin.cancelAll();
      for (final task in tasks) {
        await scheduleForTask(task);
      }
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_supported) return;
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task reminders',
          channelDescription: 'Reminders for your TaskFlow tasks',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      await _plugin.show(
        2147483000,
        'TaskFlow reminder',
        'Test notification',
        details,
      );
      await _plugin.zonedSchedule(
        2147483001,
        'TaskFlow reminder',
        'This is your second test notification',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  void _setFallbackLocation() {
    tz.setLocalLocation(tz.UTC);
  }

  int _notificationId(String taskId) {
    final id = taskId.hashCode & 0x7fffffff;
    return id == 0 ? 1 : id;
  }

  String _reminderLead(int minutes) {
    if (minutes == 60) return 'Due in 1 hour';
    return 'Due in $minutes minutes';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }
}
