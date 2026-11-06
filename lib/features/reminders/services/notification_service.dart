import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/app_logger.dart';

final class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static const AppLogger _logger = AppLogger('Notifications');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  void Function(String noteId)? _onOpenNote;
  String? _pendingNoteId;

  set onOpenNote(void Function(String noteId)? callback) {
    _onOpenNote = callback;
    final String? pending = _pendingNoteId;
    if (callback != null && pending != null) {
      _pendingNoteId = null;
      callback(pending);
    }
  }

  String? takePendingNoteId() {
    final String? pending = _pendingNoteId;
    _pendingNoteId = null;
    return pending;
  }

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (error, stack) {
      _logger.error('Could not resolve local timezone', error, stack);
    }

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: _handleResponse,
    );
    _initialized = true;
    await _captureLaunchPayload();
  }

  void _handleResponse(NotificationResponse response) {
    final String? noteId = response.payload;
    if (noteId == null || noteId.isEmpty) {
      return;
    }
    final void Function(String noteId)? callback = _onOpenNote;
    if (callback == null) {
      _pendingNoteId = noteId;
    } else {
      callback(noteId);
    }
  }

  Future<void> _captureLaunchPayload() async {
    try {
      final NotificationAppLaunchDetails? details = await _plugin
          .getNotificationAppLaunchDetails();
      final String? noteId = details?.notificationResponse?.payload;
      if (details?.didNotificationLaunchApp == true &&
          noteId != null &&
          noteId.isNotEmpty) {
        _pendingNoteId = noteId;
      }
    } catch (error, stack) {
      _logger.error('Could not read notification launch details', error, stack);
    }
  }

  Future<bool> requestPermissions() async {
    await init();
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final bool? granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }
    final IOSFlutterLocalNotificationsPlugin? ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final bool? granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    await init();
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final IOSFlutterLocalNotificationsPlugin? ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final NotificationsEnabledOptions? options = await ios.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return true;
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime whenUtc,
    String? payload,
  }) async {
    await init();
    final tz.TZDateTime scheduled = tz.TZDateTime.from(whenUtc, tz.local);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'note_reminders',
          'Note reminders',
          channelDescription: 'Reminders for your notes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancel(int id) {
    return _plugin.cancel(id: id);
  }
}
