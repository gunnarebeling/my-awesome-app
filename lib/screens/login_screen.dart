import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_awesome_app/bloc/login_bloc.dart';
import 'package:my_awesome_app/model/user.dart';
import 'package:my_awesome_app/screens/base_screen.dart';
import 'package:my_awesome_app/screens/main_screen.dart';
import 'package:my_awesome_app/widgets/login_form.dart';

class LoginScreen extends BaseScreen {
  const LoginScreen({
    super.key,
    super.title = 'Login',
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreenState<LoginScreen> {
  late final StreamSubscription<User?> _currentUserSubscription;

  @override
  void initState() {
    super.initState();
    _currentUserSubscription = LoginBloc().currentUser.listen((user) {
      if (user == null) return;

      Future.delayed(
        const Duration(seconds: 2),
        () => popAllAndPush(const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _currentUserSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: CachedNetworkImage(
              imageUrl: 'https://twinsunsolutions.com/assets/images/home/nashville-skyline.jpg',
              placeholder: (_, __) => Image.asset('assets/loading.png'),
            ),
          ),
          const SizedBox(height: 16),
          const LoginForm(),
        ],
      ),
    );
  }
}
