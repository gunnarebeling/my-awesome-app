import 'dart:io';

import 'package:my_awesome_app/api/app_http_client.dart';
import 'package:my_awesome_app/bloc/config_bloc.dart';

base class Api {
  final String apiUrl = 'http://SEWNASH-API-env.eba-t3mcrd2m.us-east-1.elasticbeanstalk.com';

  AppHttpClient get client => AppHttpClient();

  Future<String> getAuthHeader() async {
    final email = await ConfigBloc().streamFor(ConfigBloc.kAuthEmail).first;
    final token = await ConfigBloc().streamFor(ConfigBloc.kAuthToken).first;
    return 'Bearer $token';
  }

  Future<Map<String, String>> getDefaultHeaders() async {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await getAuthHeader(),
    };
  }
}
