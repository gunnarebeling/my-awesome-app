import 'dart:io';

import 'package:flutter_app_base/bloc/config_bloc.dart';

const String apiUrl = 'https://holonet-api.herokuapp.com';

Future<String> getAuthHeader() async {
  String email = await ConfigBloc().streamFor(ConfigBloc.AUTH_EMAIL).first;
  String token = await ConfigBloc().streamFor(ConfigBloc.AUTH_TOKEN).first;
  return 'Token token=$token,email=$email';
}

Future<Map<String, String>> getDefaultHeaders() async {
  return {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: await getAuthHeader(),
  };
}
