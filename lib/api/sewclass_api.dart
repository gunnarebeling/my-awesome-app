import 'dart:convert';
import 'package:my_awesome_app/api/api.dart';
import 'package:my_awesome_app/model/api_response.dart';
import 'package:my_awesome_app/model/sewclass.dart';

final class SewClassApi extends Api {

  Future<ApiResponse<List<Sewclass>>> getSewClasses() async {
    return client
      .get(Uri.parse('$apiUrl/api/sewclass'),
        headers: await getDefaultHeaders(),
      ).then(ApiResponse.parseToList(Sewclass.fromJsonList));
  }

  Future<ApiResponse<Sewclass>> getSewClassById(String id) async {
    return client
      .get(
        Uri.parse('$apiUrl/api/sewclass/$id'),
        headers: await getDefaultHeaders(),
      )
      .then(ApiResponse.parseToObject(Sewclass.fromJson));
  }

  Future<ApiResponse> createSewClass(Map<String, dynamic> sewClass) async {
    return client
      .post(
        Uri.parse('$apiUrl/sewclass'),
        headers: await getDefaultHeaders(),
        body: json.encode(sewClass),
      )
      .then(ApiResponse.parse);
  }

  Future<ApiResponse> updateSewClass(String id, Map<String, dynamic> sewClass) async {
    return client
      .put(
        Uri.parse('$apiUrl/sewclass/$id'),
        headers: await getDefaultHeaders(),
        body: json.encode(sewClass),
      )
      .then(ApiResponse.parse);
  }

  Future<ApiResponse> deleteSewClass(String id) async {
    return client
      .delete(
        Uri.parse('$apiUrl/sewclass/$id'),
        headers: await getDefaultHeaders(),
      )
      .then(ApiResponse.parse);
  }
}
