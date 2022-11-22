import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_base/api/device_api.dart';
import 'package:flutter_app_base/bloc/login_bloc.dart';
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
    await _firebaseMessaging.requestPermission();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(onDidReceiveLocalNotification: _handleLocalNotification);
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onSelectNotification);
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);
    if (!Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }
    initTappedMessages();

    String? token = await _firebaseMessaging.getToken();
    _log.info('FCM Token: $token');
    _loginResultStreamSubscription = LoginBloc().currentUser.listen((result) {
      Future.delayed(const Duration(seconds: 5)).then((_) => _registerDevice(token ?? ''));
    });
    try {
      await LoginBloc().fetchCurrentUser();
      await Future.delayed(const Duration(seconds: 5));
      _registerDevice(token ?? '');
    } catch (err) {} // ignore: empty_catches
  }

  Future<void> unregisterDevice() async {
    return _api.unregister(await _firebaseMessaging.getToken() ?? '').then((_) {
      _log.info('Unregister device: success!');
    }).catchError((error, stackTrace) {
      _log.severe('Unregister device: failure!', error, stackTrace);
      return Future.error(error, stackTrace);
    });
  }

  Future<void> initTappedMessages() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      // The app was opened from a terminated state by tapping a notification
      _handleNotificationTap(initialMessage, isLaunching: true);
    }

    _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(RemoteMessage remoteMessage, {bool isLaunching = false}) {
    // Now handles launching and resuming..
    final Map data = remoteMessage.data;
    _log.info('_handleNotificationTap: $data');
  }

  void _handleMessage(RemoteMessage remoteMessage) {
    final Map data = remoteMessage.data;
    _log.info('_handleMessage: $data');
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'artful_agenda_event_alerts',
      'Artful Agenda Alerts',
      channelDescription: 'Alerts received while Artful Agenda is running',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosPlatformChannelSpecifics);

    final RemoteNotification? notification = remoteMessage.notification;

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

  void _registerDevice(String token) {
    _api.register(token).then((_) {
      _log.info('Register device: success!');
    }).catchError((error, stackTrace) {
      _log.severe('Register device: failure!', error, stackTrace);
      return Future.error(error, stackTrace);
    });
  }
}
