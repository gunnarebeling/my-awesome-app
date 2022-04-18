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

  LoginBloc._internal();

  final LoginApi _api = LoginApi();

  final BehaviorSubject<User> _userSubject = BehaviorSubject<User>();
  Stream<User> get currentUser => _userSubject.stream;

  Logger get _log => Logger('LoginBloc');

  Future<User> login(String email, String password) {
    _log.finest('login($email)');
    return _api.login(email, password).then((response) {
      _userSubject.add(response.data!);
      ConfigBloc().addToStream(ConfigBloc.AUTH_EMAIL, response.data!.email);
      ConfigBloc().addToStream(ConfigBloc.AUTH_TOKEN, response.data!.authToken);
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
