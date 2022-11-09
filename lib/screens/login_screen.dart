import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/login_bloc.dart';
import 'package:flutter_app_base/screens/main_screen.dart';
import 'package:flutter_app_base/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late StreamSubscription _userSubscription;

  @override
  void initState() {
    super.initState();
    _userSubscription = LoginBloc().currentUser.listen((user) {
      if (user == null) return;

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //capturing screen dimensions using media query
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text('Login Screen'),
          ),
          //demonstrating using CachedNetworkImage with a default value
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: SizedBox(
                width: screenWidth * 0.9,
                height: screenHeight * 0.2,
                child: CachedNetworkImage(
                  imageUrl: 'https://twinsunsolutions.com/assets/images/home/nashville-skyline.jpg',
                  placeholder: (context, url) => Image.asset('assets/loading.png'),
                ),
              ),
            ),
          ),
          const LoginForm(),
        ],
      ),
    );
  }
}
