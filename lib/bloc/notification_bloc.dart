import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:my_awesome_app/api/device_api.dart';
import 'package:my_awesome_app/bloc/login_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

Future<void> _handleBackgroundMessage(RemoteMessage remoteMessage) async {
  // await Firebase.initializeApp(); // Uncomment if you're going to use other Firebase services in the background, such as Firestore.
  final Map message = remoteMessage.data;
  print('_handleBackgroundMessage: $message'); // ignore: avoid_print
}

class NotificationBloc {
  static NotificationBloc _instance = NotificationBloc._internal();

  factory NotificationBloc() => _instance;

  static void reset() {
    _instance.dispose();
    _instance = NotificationBloc._internal();
    _instance.initialize();
  }

  final DeviceApi _api = DeviceApi();
  Logger get _log => Logger('NotificationBloc');

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  StreamSubscription? _loginResultStreamSubscription;
  StreamSubscription? _onMessageSubscription;
  StreamSubscription? _onMessageOpenedSubscription;

  NotificationBloc._internal();

  void dispose() {
    _loginResultStreamSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _onMessageOpenedSubscription?.cancel();
  }

  Future<void> initialize() async {
    _log.finest('initialize()');
    dispose();
    
    // Request permission with specific settings for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    
    // iOS-specific APNs setup
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Register for remote notifications
      await _firebaseMessaging.getAPNSToken();
    }
    
    const initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    final initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onSelectNotification);
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);
    
    // Register background message handler for both platforms
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    initTappedMessages();

    // Get FCM token with error handling
    String? token;
    try {
      token = await _firebaseMessaging.getToken();
      _log.info('FCM Token: $token');
    } catch (e) {
      _log.severe('Error getting FCM token: $e');
    }
    _loginResultStreamSubscription = LoginBloc().currentUser.listen((result) {
      Future.delayed(const Duration(seconds: 5)).then((_) => _registerDevice(token ?? ''));
    });
    try {
      await LoginBloc().fetchCurrentUser();
      await Future.delayed(const Duration(seconds: 5));
      await _registerDevice(token ?? '');
    } catch (err, stackTrace) {
      _log.warning('Error during user fetch or device registration', err, stackTrace);
    }
  }

  Future<void> unregisterDevice() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null || token.isEmpty) {
        _log.warning('Unregister device: No token available');
        return;
      }
      
      await _api.unregister(token);
      _log.info('Unregister device: success!');
    } catch (error, stackTrace) {
      _log.severe('Unregister device: failure!', error, stackTrace);
      return Future.error(error, stackTrace);
    }
  }

  Future<void> initTappedMessages() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();

      if (initialMessage != null) {
        // The app was opened from a terminated state by tapping a notification
        _handleNotificationTap(initialMessage, isLaunching: true);
      }

      _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // For iOS, fix notification handling when app is in the background
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getNotificationSettings();
      }
    } catch (e, stackTrace) {
      _log.severe('Error initializing notification tap handling', e, stackTrace);
    }
  }

  void _handleNotificationTap(RemoteMessage remoteMessage, {bool isLaunching = false}) {
    // Now handles launching and resuming..
    final Map data = remoteMessage.data;
    _log.info('_handleNotificationTap: $data');
  }

  void _handleMessage(RemoteMessage remoteMessage) {
    final Map data = remoteMessage.data;
    _log.info('_handleMessage: $data');
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'artful_agenda_event_alerts',
      'Artful Agenda Alerts',
      channelDescription: 'Alerts received while Artful Agenda is running',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosPlatformChannelSpecifics);

    final notification = remoteMessage.notification;

    if (notification == null) {
      _log.info('data only message');
      return;
    }

    _flutterLocalNotificationsPlugin.show(0, notification.title, notification.body, platformChannelSpecifics, payload: json.encode(data));
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    _log.info('_onSelectNotification: ${response.payload}');
  }

  Future<void> _handleLocalNotification(int id, String? title, String? body, String? payload) async {
    _log.info('_handleLocalNotification: $id, $title, $body, $payload');
  }

  Future<void> _registerDevice(String token) async {
    if (token.isEmpty) {
      _log.warning('Register device: Empty token');
      return;
    }
    
    try {
      await _api.register(token);
      _log.info('Register device: success!');
    } catch (error, stackTrace) {
      _log.severe('Register device: failure!', error, stackTrace);
      // Not rethrowing the error here to prevent app crashes due to registration failures
    }
  }
}
