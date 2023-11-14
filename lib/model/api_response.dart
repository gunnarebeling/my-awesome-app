import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'api_error.dart';

/// A response from an API call.
///
/// The [data] field contains the parsed response body.
///
/// The [error] field contains an [ApiError] if the response was not successful.
class ApiResponse<T> {
  final T? data;
  final Map<String, String>? headers;
  final ApiError? error;

  ApiResponse({this.data, this.error, this.headers});

  /// Parses a [Response] to an [ApiResponse].
  ///
  /// If the response is successful, the [ApiResponse] will contain the parsed [Response.body] as [ApiResponse.data].
  /// If the response is not successful, the [ApiResponse] will contain an [ApiError] as [ApiResponse.error].
  static Future<ApiResponse> parse(Response response) {
    dynamic parsedBody;

    try {
      parsedBody = response.body.isNotEmpty ? json.decode(response.body) : {};
    } catch (error, stack) {
      Logger('ApiResponse').warning('Failed to deserialize json.', error, stack);
      parsedBody = {'error': 'Failed to properly deserialize response: $error'};
    }

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // success!
      return Future<ApiResponse>.value(ApiResponse(data: parsedBody, headers: response.headers));
    } else {
      // failure!
      return Future<ApiResponse>.error(ApiResponse(error: ApiError.fromJson(parsedBody, response.statusCode), headers: response.headers));
    }
  }

  static Future parseStatusOnly(response) {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // success!
      return Future.value(true);
    } else {
      // failure!
      return Future.error(ApiResponse(error: ApiError(response.statusCode, 'An Error Occurred.')));
    }
  }

  /// Returns a function that parses a response to an object.
  ///
  /// The [mapper] function is used to map the object to [E].
  ///
  /// Pass a [Response] into the returned function to parse the response.
  ///
  /// For example, to parse a [User] object:
  /// ```
  /// Future<ApiResponse<User>> fetchCurrentUser() async {
  ///  return await _client.get(Uri.parse('$apiUrl/api/v1/me'), headers: await getDefaultHeaders())
  ///      .then(ApiResponse.parseToObject<User>(User.fromJson));
  /// }
  /// ```
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

  /// Returns a function that parses a response to a list of objects.
  ///
  /// The [mapper] function is used to map the list of objects to a list of [E].
  ///
  /// Pass a [Response] into the returned function to parse the response.
  ///
  /// For example, to parse a list of [User] objects:
  /// ```
  /// Future<ApiResponse<List<User>>> fetchUsers() async {
  ///  return await _client.get(Uri.parse('$apiUrl/api/v1/users'), headers: await getDefaultHeaders())
  ///        .then(ApiResponse.parseToList<User>(User.fromJson));
  /// }
  /// ```
  static Future<ApiResponse<List<E>>> Function(Response) parseToList<E>(List<E> Function(List) mapper) {
    return (Response response) => parse(response).then((parsedResponse) {
          List data;
          if (parsedResponse.data is Map) {
            data = parsedResponse.data.values.toList();
          } else {
            data = parsedResponse.data;
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
  String toString() => error?.toString() ?? data.toString();
}
