import 'dart:convert';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:http/http.dart' as http;

class LoginApi {
  http.Client get _client => http.Client();

  Future<ApiResponse<User>> login(String email, String password) async {
    return await _client
        .post(
          Uri.parse('$apiUrl/api/v1/sign_in'),
          body: json.encode({
            'user': {
              'email': email,
              'password': password,
            }
          }),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parseToObject<User>(User.fromJson));
  }

  Future<ApiResponse<User>> fetchCurrentUser() async {
    return await _client.get(Uri.parse('$apiUrl/api/v1/me'), headers: await getDefaultHeaders()).then(ApiResponse.parseToObject<User>(User.fromJson));
  }
}
