import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_base/api/api.dart';
import 'package:flutter_app_base/api/client.dart';
import 'package:flutter_app_base/model/api_response.dart';

class DeviceApi {
  AppHttpClient get _client => AppHttpClient();

  Future<ApiResponse> register(String deviceToken) async {
    return _client
        .post(
          Uri.parse('$apiUrl/api/v1/devices'),
          body: json.encode({
            'device': {
              'token': deviceToken,
              'platform': Platform.isIOS ? 'ios' : 'android',
            },
          }),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parse)
        .then((json) => ApiResponse(data: json));
  }

  Future<ApiResponse> unregister(String deviceToken) async {
    return _client
        .delete(
          Uri.parse('$apiUrl/api/v1/devices/$deviceToken'),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parse)
        .then((json) => ApiResponse(data: json));
  }
}
