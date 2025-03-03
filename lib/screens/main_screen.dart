import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:my_awesome_app/bloc/login_bloc.dart';
import 'package:my_awesome_app/mixins/stateless_navigation.dart';
import 'package:my_awesome_app/model/user.dart';
import 'package:my_awesome_app/screens/base_screen.dart';
import 'package:my_awesome_app/screens/login_screen.dart';
import 'package:my_awesome_app/screens/view_classes_screen.dart';

class MainScreen extends BaseScreen {
  const MainScreen({
    super.key,
    super.title = 'SEW NASH',
    
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

  void _navigateToScreen(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewClassesScreen()),
    );
  }
  
  Widget _viewClasses(){
    return ElevatedButton(
      onPressed: _navigateToScreen,
      child: const Text('View Classes'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(230, 129, 230, 0.992)
      ),
    );
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
            Image.asset('assets/SewNash1.png', width: 200, height: 200),
            const SizedBox(height: 16),
            _viewClasses(),
            
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
    return ElevatedButton(
      onPressed: () => _onPressed(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white
      ),
      child: const Text('Logout'),
    );
  }
}
