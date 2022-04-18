import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/logging_bloc.dart';
import 'package:flutter_app_base/bloc/login_bloc.dart';
import 'package:flutter_app_base/model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LoggingBloc().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Base',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription _userSubscription;

  @override
  void initState() {
    super.initState();

    _userSubscription = LoginBloc().currentUser.listen((User currentUser) {});

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Screen'),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User>(
          stream: LoginBloc().currentUser,
          initialData: null,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text('Main Screen'),
                ),
                Center(
                  child: Text(snapshot.data?.email ?? 'No user'),
                ),
                LoginForm(),
              ],
            );
          }),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text('Login Form'),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
        ),
        TextButton(
          onPressed: () {
            LoginBloc().login(_emailController.text, _passwordController.text);
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}
