import 'dart:convert';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';

final class LoginApi extends Api {
  Future<ApiResponse<User>> login(String email, String password) async {
    return client
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
        .then(ApiResponse.parseToObject(User.fromJson));
  }

  Future<ApiResponse<User>> fetchCurrentUser() async {
    return client
        .get(
          Uri.parse('$apiUrl/api/v1/me'),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parseToObject(User.fromJson));
  }
}
