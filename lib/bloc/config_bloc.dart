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
    kAuthEmail: BehaviorSubject<String>.seeded(''),
    kAuthToken: BehaviorSubject<String>.seeded(''),
    kAuthId: BehaviorSubject<String>.seeded(''),
  };

  ConfigBloc._internal();

  dispose() {
    _streams.values.forEach((stream) => stream.close());
  }

  initialize() async {
    _logger.finest('initialize()');
    final authEmail = await stringValueFor(kAuthEmail);
    if (authEmail != null) addToStream(kAuthEmail, authEmail);

    final authToken = await stringValueFor(kAuthToken);
    if (authToken != null) addToStream(kAuthToken, authToken);

    final authId = await stringValueFor(kAuthId);
    if (authId != null) addToStream(kAuthId, authId);
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

  static const kAuthToken = "kAuthToken";
  static const kAuthEmail = "kAuthEmail";
  static const kAuthId = "kAuthId";
}
