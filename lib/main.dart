import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:my_awesome_app/bloc/config_bloc.dart';
import 'package:my_awesome_app/bloc/critic_bloc.dart';
import 'package:my_awesome_app/bloc/logging_bloc.dart';
import 'package:my_awesome_app/bloc/notification_bloc.dart';
import 'package:my_awesome_app/firebase_options.dart';
import 'package:my_awesome_app/screens/splash_screen.dart';
import 'package:my_awesome_app/themes/default_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LoggingBloc().initialize();
  await ConfigBloc().initialize();
  await NotificationBloc().initialize();
  await CriticBloc().initialize();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Base',
      theme: defaultTheme,
      home: const SplashScreen(),
    );
  }
}
