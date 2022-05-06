import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_app_base/api/login_api.dart';
import 'package:flutter_app_base/bloc/config_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  static final LoginBloc _instance = LoginBloc._internal();

  factory LoginBloc() {
    return _instance;
  }

  LoginBloc._internal() {
    currentUser.listen((User? user) {
      FirebaseCrashlytics.instance.setUserIdentifier(user?.id ?? '');
      FirebaseAnalytics.instance.setUserId(id: user?.id ?? '');
    });
  }

  final LoginApi _api = LoginApi();

  final BehaviorSubject<User?> _userSubject = BehaviorSubject<User?>();
  Stream<User?> get currentUser => _userSubject.stream;

  Logger get _log => Logger('LoginBloc');

  Future<User> login(String email, String password) {
    _log.finest('login($email)');
    return _api.login(email, password).then((response) {
      _userSubject.add(response.data!);
      ConfigBloc().addToStream(ConfigBloc.kAuthEmail, response.data!.email);
      ConfigBloc().addToStream(ConfigBloc.kAuthToken, response.data!.authToken);
      ConfigBloc().addToStream(ConfigBloc.kAuthId, response.data!.id);
      return response.data!;
    }).catchError((err) {
      if (err is ApiResponse) {
        _log.finest('ApiError: ${err.error?.message}');
      } else {
        _log.finest('Unknown error: $err');
      }
      return Future<User>.error(err);
    });
  }

  Future<void> logout() async {
    _log.finest('logout()');
    await ConfigBloc().addToStream(ConfigBloc.kAuthEmail, '');
    await ConfigBloc().addToStream(ConfigBloc.kAuthToken, '');
    await ConfigBloc().addToStream(ConfigBloc.kAuthId, '');
    _userSubject.add(null);
  }

  Future<User> fetchCurrentUser() async {
    _log.finest('fetchCurrentUser()');
    return _api.fetchCurrentUser().then((response) {
      _userSubject.add(response.data!);
      return response.data!;
    }).catchError((err) {
      if (err is ApiResponse) {
        _log.finest('ApiError: ${err.error?.message}');
      } else {
        _log.finest('Unknown error: $err');
      }
      return Future<User>.error(err);
    });
  }
}
