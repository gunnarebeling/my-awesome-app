import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_app_base/bloc/logging_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class HttpClient implements http.Client {
  HttpClient() {
    _initialize();
  }

  final http.Client _client = http.Client();

  late final String appVersion;
  late final PackageInfo? packageInfo;
  late final String _clientHeader;

  String get buildNumber {
    final info = packageInfo;
    if (info == null) return '0';

    final asNumber = int.tryParse(info.buildNumber);
    if (asNumber == null) return info.buildNumber;

    return '${asNumber % 10000}';
  }

  Future<void> _initialize() async {
    packageInfo = await PackageInfo.fromPlatform();
    appVersion = 'Version ${packageInfo?.version}+$buildNumber';

    _loadClientHeader();
  }

  Future<void> _loadClientHeader() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _clientHeader = '$_clientHeader / Android ${androidInfo.version.release} / model: ${androidInfo.model}';
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _clientHeader = '$_clientHeader / iOS ${iosInfo.systemVersion} / model: ${iosInfo.utsname.machine}';
    }
  }

  Map<String, String> baseHeaders(Map<String, String>? headers) {
    return {
      if (_clientHeader.isNotEmpty) 'X-App-Client': _clientHeader,
      ...(headers ?? {}),
    };
  }

  Future<http.Response> _logRequest(Future<http.Response> requestFuture) {
    var startTime = DateTime.now();
    return requestFuture.then((response) {
      var endTime = DateTime.now();
      LoggingBloc().logNetworkRequest(
        url: response.request?.url.toString() ?? "",
        method: response.request?.method ?? "",
        statusCode: response.statusCode,
        startTime: startTime,
        endTime: endTime,
      );
      return response;
    });
  }

  @override
  void close() {
    _client.close();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return _logRequest(_client.head(url, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> delete(url, {Object? body, Encoding? encoding, Map<String, String>? headers}) {
    return _logRequest(_client.delete(url, body: body, encoding: encoding, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> get(url, {Map<String, String>? headers}) {
    return _logRequest(_client.get(url, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> patch(url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _logRequest(_client.patch(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> post(url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _logRequest(_client.post(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> put(url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _logRequest(_client.put(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<String> read(url, {Map<String, String>? headers}) {
    return _client.read(url, headers: baseHeaders(headers));
  }

  @override
  Future<Uint8List> readBytes(url, {Map<String, String>? headers}) {
    return _client.readBytes(url, headers: baseHeaders(headers));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request);
  }
}
