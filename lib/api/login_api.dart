import 'dart:convert';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/api/client.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';

class LoginApi {
  AppHttpClient get _client => AppHttpClient();

  Future<ApiResponse<User>> login(String email, String password) async {
    return _client
        .post(
          Uri.parse('$apiUrl/api/v1/sign_in'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'user': {
              'email': email,
              'password': password,
            }
          }),
        )
        .then(ApiResponse.parseToObject<User>(User.fromJson));
  }

  Future<ApiResponse<User>> fetchCurrentUser() async {
    return _client
        .get(
          Uri.parse('$apiUrl/api/v1/me'),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parseToObject<User>(User.fromJson));
  }
}
