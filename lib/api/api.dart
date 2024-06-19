import 'dart:io';

import 'package:flutter_app_base/api/http_client.dart';
import 'package:flutter_app_base/bloc/config_bloc.dart';

base class Api {
  final String apiUrl = 'http://localhost:3000';

  HttpClient get client => HttpClient();

  Future<String> getAuthHeader() async {
    final email = await ConfigBloc().streamFor(ConfigBloc.kAuthEmail).first;
    final token = await ConfigBloc().streamFor(ConfigBloc.kAuthToken).first;
    return 'Token token=$token,email=$email';
  }

  Future<Map<String, String>> getDefaultHeaders() async {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await getAuthHeader(),
    };
  }
}
