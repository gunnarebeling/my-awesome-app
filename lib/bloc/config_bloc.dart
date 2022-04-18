import 'package:flutter_app_base/repository/config_repository.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class ConfigBloc {
  static ConfigBloc _instance = ConfigBloc._internal();

  factory ConfigBloc() => _instance;

  static void reset() {
    _instance.dispose();
    _instance = ConfigBloc._internal();
  }

  final _repository = ConfigRepository();
  final _logger = Logger('ConfigBloc');

  final Map<String, BehaviorSubject> _streams = {
    AUTH_EMAIL: BehaviorSubject<String>.seeded(''),
    AUTH_TOKEN: BehaviorSubject<String>.seeded(''),
  };

  ConfigBloc._internal();

  dispose() {
    _streams.values.forEach((stream) => stream.close());
  }

  init() async {
    _logger.finest('init()');
    final authEmail = await stringValueFor(AUTH_EMAIL);
    if (authEmail != null) addToStream(AUTH_EMAIL, authEmail);

    final authToken = await stringValueFor(AUTH_TOKEN);
    if (authToken != null) addToStream(AUTH_TOKEN, authToken);
  }

  Stream streamFor(String key) {
    if (!_streams.containsKey(key)) {
      throw 'Unknown configuration key: $key';
    }
    return _streams[key]!.stream;
  }

  Future<double?> doubleValueFor(String key) async {
    dynamic value = await _repository.getValueForKey(key);
    _logger.finest('doubleValueFor $key -> $value');
    if (value != null) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<String?> stringValueFor(String key) async {
    dynamic value = await _repository.getValueForKey(key);
    _logger.finest('stringValueFor $key -> $value');
    return value;
  }

  Future<void> addToStream(String key, dynamic value) async {
    _logger.finest('addToStream $key -> $value');
    if (!_streams.containsKey(key)) {
      throw 'Unknown configuration key: $key';
    }
    await _repository.setValueForKey(key, value.toString());
    _streams[key]!.add(value);
  }

  static const AUTH_TOKEN = "AUTH_TOKEN";
  static const AUTH_EMAIL = "AUTH_EMAIL";
}
