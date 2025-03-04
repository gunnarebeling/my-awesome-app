import 'dart:convert';
import 'dart:io';

import 'package:my_awesome_app/api/api.dart';
import 'package:my_awesome_app/model/api_response.dart';

final class DeviceApi extends Api {
  Future<ApiResponse> register(String token) async {
    return client
        .post(
          Uri.parse('$apiUrl/api/v1/devices'),
          headers: await getDefaultHeaders(),
          body: json.encode({
            'device': {
              'token': token,
              'platform': Platform.isIOS ? 'ios' : 'android',
            },
          }),
        )
        .then(ApiResponse.parse)
        .then((json) => ApiResponse(data: json));
  }

  Future<ApiResponse> unregister(String token) async {
    return client
        .delete(
          Uri.parse('$apiUrl/api/v1/devices/$token'),
          headers: await getDefaultHeaders(),
        )
        .then(ApiResponse.parse)
        .then((json) => ApiResponse(data: json));
  }
}
