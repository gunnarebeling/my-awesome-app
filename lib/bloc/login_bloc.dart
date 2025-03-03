import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:my_awesome_app/api/login_api.dart';
import 'package:my_awesome_app/bloc/config_bloc.dart';
import 'package:my_awesome_app/model/api_response.dart';
import 'package:my_awesome_app/model/api_error.dart';
import 'package:my_awesome_app/model/user.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  static LoginBloc _instance = LoginBloc.internal();

  @visibleForTesting
  static set instance(LoginBloc v) {
    _instance = v;
  }

  factory LoginBloc() {
    return _instance;
  }

  @visibleForTesting
  LoginBloc.internal({LoginApi? api}) : _api = api ?? LoginApi() {
    currentUser.listen((User? user) {
      _firebaseCrashlytics.setUserIdentifier(user?.id.toString() ?? '');
      _firebaseAnalytics.setUserId(id: user?.id.toString() ?? '');
    });
  }

  static FirebaseCrashlytics _firebaseCrashlytics = FirebaseCrashlytics.instance;

  @visibleForTesting
  static set firebaseCrashlytics(FirebaseCrashlytics value) {
    _firebaseCrashlytics = value;
  }

  static FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  @visibleForTesting
  static set firebaseAnalytics(FirebaseAnalytics value) {
    _firebaseAnalytics = value;
  }

  LoginApi _api = LoginApi();

  final BehaviorSubject<User?> _userSubject = BehaviorSubject<User?>.seeded(null);
  Stream<User?> get currentUser => _userSubject.stream;

  Logger get _log => Logger('LoginBloc');

  // The main login method is updated to use loginAndGetUserDetails instead of login
  Future<User> login(String email, String password) async {
    _log.finest('login($email)');
    try {
      // Use the loginAndGetUserDetails method which handles login and fetching user details
      final user = await _api.loginAndGetUserDetails(email, password);
      
      if (user == null) {
        throw Exception('Login failed: Unable to retrieve user data');
      }
      
      // Get token from secure storage after successful login
      final token = await _api.getToken() ?? '';
      
      // Store relevant user information
      await Future.wait([
        ConfigBloc().addToStream(ConfigBloc.kAuthEmail, user.email),
        ConfigBloc().addToStream(ConfigBloc.kAuthToken, token),
        ConfigBloc().addToStream(ConfigBloc.kAuthId, user.id.toString()),
      ]);

      _userSubject.add(user);
      return user;
    } catch (err) {
      if (err is ApiResponse) {
        final apiError = err.error;
        if (apiError != null) {
          _log.finest('ApiError: ${apiError.message}');
          return Future<User>.error(apiError.message);
        }
      }
      _log.finest('Unknown error: $err');
      return Future<User>.error(err);
    }
  }

  Future<void> logout() async {
    _log.finest('logout()');

    // Call the API's logout method
    await _api.logout();

    // Clear stored authentication data
    await Future.wait([
      ConfigBloc().addToStream(ConfigBloc.kAuthEmail, ''),
      ConfigBloc().addToStream(ConfigBloc.kAuthToken, ''),
      ConfigBloc().addToStream(ConfigBloc.kAuthId, ''),
    ]);

    _userSubject.add(null);
  }

  Future<User> fetchCurrentUser() async {
    _log.finest('fetchCurrentUser()');

    try {
      final response = await _api.fetchCurrentUser();
      
      if (response.error != null) {
        return Future<User>.error(response.error!.message);
      }
      
      if (response.data == null) {
        return Future<User>.error('Failed to retrieve user data');
      }
      
      _userSubject.add(response.data);
      return response.data!;
    } catch (err) {
      if (err is SocketException) {
        _log.warning('SocketException: ${err.message}');
      } else if (err is ApiResponse) {
        final apiError = err.error;
        if (apiError != null) {
          _log.finest('ApiError: ${apiError.message}');
        }
      } else {
        _log.finest('Unknown error: $err');
      }
      return Future<User>.error(err);
    }
  }
}