import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_localizations.dart';

class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  static const int _reminderNotificationId = 4101;
  static const int _testNotificationId = 4102;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    await initialize();

    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;

    final alreadyEnabled = await android.areNotificationsEnabled();
    if (alreadyEnabled == true) return true;

    return await android.requestNotificationsPermission() ?? false;
  }

  Future<void> syncReminder({
    required bool enabled,
    required String localeCode,
    required bool soundEnabled,
    required bool vibrationEnabled,
    bool requestPermissionIfNeeded = false,
  }) async {
    if (kIsWeb) return;

    await initialize();
    await _plugin.cancel(id: _reminderNotificationId);

    if (!enabled) return;

    final hasPermission = requestPermissionIfNeeded
        ? await requestPermission()
        : await _hasPermission();
    if (!hasPermission) return;

    await _plugin.periodicallyShow(
      id: _reminderNotificationId,
      title: AppLocalizations.t(localeCode, 'notificationReminderTitle'),
      body: AppLocalizations.t(localeCode, 'notificationReminderBody'),
      repeatInterval: RepeatInterval.daily,
      notificationDetails: _details(
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<bool> showTestNotification({
    required String localeCode,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    if (kIsWeb) return false;

    await initialize();
    final hasPermission = await requestPermission();
    if (!hasPermission) return false;

    await _plugin.show(
      id: _testNotificationId,
      title: AppLocalizations.t(localeCode, 'notificationTestTitle'),
      body: AppLocalizations.t(localeCode, 'notificationTestBody'),
      notificationDetails: _details(
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
      ),
    );
    return true;
  }

  Future<bool> _hasPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? false;
  }

  NotificationDetails _details({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) {
    final channelKey =
        '${soundEnabled ? 'sound' : 'silent'}_${vibrationEnabled ? 'vibrate' : 'steady'}';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'smartscan_$channelKey',
        'SmartScan reminders',
        channelDescription: 'Reminder and status notifications for SmartScan.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
        ticker: 'SmartScan',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
      ),
    );
  }
}
