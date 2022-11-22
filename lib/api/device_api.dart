import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:http/http.dart' as http;

class DeviceApi {
  http.Client get _client => http.Client();

  Future<ApiResponse> register(String deviceToken) async {
    return await _client
        .post(
          Uri.parse('$apiUrl/api/v1/devices'),
          body: json.encode({
            'device': {
              'token': deviceToken,
              'platform': Platform.isIOS ? 'ios' : 'android',
            }
          }),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parse)
        .then((json) => ApiResponse(data: json));
  }

  Future<ApiResponse> unregister(String deviceToken) async {
    return await _client
        .delete(
          Uri.parse('$apiUrl/api/v1/devices/$deviceToken'),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parse)
        .then((json) => ApiResponse(data: json));
  }
}
