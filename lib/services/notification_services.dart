import 'dart:async';
import 'package:event_manager/controllers/taskfb_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotifyHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final Set<String> _notifiedTasks = {}; // Using Set to prevent duplicates
  final TaskFbController _taskController = Get.find<TaskFbController>();

  NotifyHelper() {
    _startMonitoringTasks();
  }


  static Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('flutter_logo');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification Clicked!");
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel',
      'Task Notifications',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }


  Future<void> scheduledNotification(
      int hour, int minute, String title, String body, String repeat) async {
    int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    print("Scheduling Notification at: $hour:$minute with repeat: $repeat");

    await _notificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      _convertTime(hour, minute, repeat),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _getDateTimeComponents(repeat),
    );
  }

  Future<void> showImmediateNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _notificationsPlugin.show(uniqueId, title, body, details);
  }


  tz.TZDateTime _convertTime(int hour, int minute, String repeat) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      if (repeat == "Daily") {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      } else if (repeat == "Weekly") {
        scheduledDate = scheduledDate.add(Duration(days: 7));
      } else if (repeat == "Monthly") {
        scheduledDate = tz.TZDateTime(
            tz.local,
            now.month == 12 ? now.year + 1 : now.year,
            now.month == 12 ? 1 : now.month + 1,
            now.day,
            hour,
            minute);
      }
    }

    print("Scheduled Notification Time: $scheduledDate");
    return scheduledDate;
  }

  DateTimeComponents? _getDateTimeComponents(String repeat) {
    switch (repeat) {
      case "Daily":
        return DateTimeComponents.time;
      case "Weekly":
        return DateTimeComponents.dayOfWeekAndTime;
      default:
        return null;
    }
  }

  void _startMonitoringTasks() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      DateTime now = DateTime.now();
      String currentTime = DateFormat("hh:mm a").format(now);

      for (var task in _taskController.taskList) {
        if (task.startTime == null) continue;

        String taskTime =
        DateFormat("hh:mm a").format(DateFormat("h:mm a").parse(task.startTime!));

        if (taskTime == currentTime && !_notifiedTasks.contains(task.title)) {
          showImmediateNotification(
            "Event Reminder",
            "It's time for: ${task.title} \n ${task.description}",
          );

          _notifiedTasks.add(task.title!); // Prevent duplicate notifications

          // Reset notified tasks for repeated ones
          if (task.repeat == "Daily") {
            Future.delayed(Duration(hours: 24), () {
              _notifiedTasks.remove(task.title);
            });
          } else if (task.repeat == "Weekly") {
            Future.delayed(Duration(days: 7), () {
              _notifiedTasks.remove(task.title);
            });
          } else if (task.repeat == "Monthly") {
            Future.delayed(Duration(days: 30), () {
              _notifiedTasks.remove(task.title);
            });
          }
        }
      }
    });
  }

  void scheduleNotify(TimeOfDay pickedTime, String repeat) {
    DateTime now = DateTime.now();

    DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (scheduledDateTime.isBefore(now)) {
      if (repeat == "Daily") {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      } else if (repeat == "Weekly") {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 7));
      } else if (repeat == "Monthly") {
        scheduledDateTime = DateTime(
            now.year,
            now.month == 12 ? 1 : now.month + 1,
            now.day,
            pickedTime.hour,
            pickedTime.minute);
      }
    }

    print("Final Scheduled Time: ${DateFormat.jm().format(scheduledDateTime)}");

    scheduledNotification(
      scheduledDateTime.hour,
      scheduledDateTime.minute,
      "Task Reminder",
      "Your task is scheduled for ${DateFormat.jm().format(scheduledDateTime)}",
      repeat,
    );
  }
}
