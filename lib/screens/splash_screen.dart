import 'package:flutter/material.dart';
import 'package:my_awesome_app/bloc/login_bloc.dart';
import 'package:my_awesome_app/screens/base_screen.dart';
import 'package:my_awesome_app/screens/login_screen.dart';
import 'package:my_awesome_app/screens/main_screen.dart';

class SplashScreen extends BaseScreen {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseScreenState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    LoginBloc().fetchCurrentUser().then((user) {
      Future.delayed(
        const Duration(seconds: 2),
        () => popAllAndPush(const MainScreen()),
      );
    }).catchError((error) {
      Future.delayed(
        const Duration(seconds: 2),
        () => popAllAndPush(const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context, [_]) {
    super.build(context);
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 175, 230),
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
