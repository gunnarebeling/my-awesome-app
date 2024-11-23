import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/login_bloc.dart';
import 'package:flutter_app_base/mixins/stateless_navigation.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/login_screen.dart';

class MainScreen extends BaseScreen {
  const MainScreen({
    super.key,
    super.title = 'Main Screen',
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends BaseScreenState<MainScreen> {
  late final StreamSubscription<User?> _currentUserSubscription;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUserSubscription = LoginBloc().currentUser.listen(_onCurrentUserChanged);
  }

  @override
  void dispose() {
    _currentUserSubscription.cancel();
    super.dispose();
  }

  void _onCurrentUserChanged(User? user) {
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_currentUser?.email ?? 'No user'),
            const _LogoutButton(),
            TextButton(
              onPressed: FirebaseCrashlytics.instance.crash,
              child: const Text('Crash'),
            ),
            TextButton(
              onPressed: () =>  FirebaseCrashlytics.instance.recordError('Test Report', null),
              child: const Text('Non-fatal Firebase Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget with StatelessNavigation {
  const _LogoutButton();

  Future<void> _onPressed(BuildContext context) async {
    await LoginBloc().logout();
    Future.delayed(
      const Duration(seconds: 2),
      () => popAllAndPush(context, const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _onPressed(context),
      child: const Text('Logout'),
    );
  }
}
