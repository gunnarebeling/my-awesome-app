import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/login_bloc.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_app_base/screens/login_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: LoginBloc().currentUser,
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
              TextButton(
                onPressed: () async {
                  await LoginBloc().logout();
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  });
                },
                child: const Text('Logout'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseCrashlytics.instance.crash();
                },
                child: const Text('Crash'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseCrashlytics.instance.recordError('Test Report', null);
                },
                child: const Text('Non-fatal Firebase Report'),
              ),
            ],
          );
        },
      ),
    );
  }
}
