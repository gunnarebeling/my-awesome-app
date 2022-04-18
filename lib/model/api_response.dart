import 'dart:convert';

import 'package:http/http.dart';

import 'api_error.dart';

class ApiResponse<T> {
  final T? data;
  final Map<String, String>? headers;
  final ApiError? error;

  ApiResponse({this.data, this.error, this.headers});

  static Future parse(Response response) {
    dynamic parsedBody;

    try {
      parsedBody = response.body != null && response.body.length > 0 ? json.decode(response.body) : {};
    } catch (error, stack) {
      print('Failed to deserialize json: $stack');
      parsedBody = {'error': 'Failed to properly deserialize response: $error'};
    }

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // success!
      return Future.value(ApiResponse(data: parsedBody, headers: response.headers));
    } else {
      // failure!
      return Future.error(ApiResponse(error: ApiError.fromJson(parsedBody, response.statusCode), headers: response.headers));
    }
  }

  static Future parseStatusOnly(response) {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // success!
      return Future.value(true);
    } else {
      // failure!
      return Future.error(ApiResponse(error: ApiError(response.statusCode, 'An Error Occured')));
    }
  }

  static Future<ApiResponse<E>> Function(Response) parseToObject<E>(E Function(Map<String, dynamic>) mapper) {
    return (Response response) => parse(response).then((parsedResponse) {
          return ApiResponse<E>(
            data: mapper(parsedResponse.data),
            headers: response.headers,
          );
        }).catchError((error) {
          return Future<ApiResponse<E>>.error(error);
        });
  }

  static Future<ApiResponse<List<E>>> Function(Response) parseToList<E>(List<E> Function(List) mapper) {
    return (Response response) => parse(response).then((parsedResponse) {
          List data;
          if (parsedResponse is Map) {
            data = parsedResponse.values.toList();
          } else {
            data = parsedResponse;
          }
          return ApiResponse<List<E>>(
            data: mapper(data),
            headers: response.headers,
          );
        }).catchError((error) {
          return Future<ApiResponse<List<E>>>.error(error);
        });
  }

  @override
  String toString() {
    if (error != null) {
      return error!.message;
    } else {
      return data.toString();
    }
  }
}
