import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class LoggingBloc {
  static var _instance = LoggingBloc._internal();

  factory LoggingBloc() => _instance;
  final List<Map> _logs = [];
  List<Map> get logs => _logs;

  final BehaviorSubject<bool> _connectedSubject = BehaviorSubject<bool>();

  Stream<bool> get connected => _connectedSubject.stream;

  static void reset() {
    _instance.dispose();
    _instance = LoggingBloc._internal();
  }

  LoggingBloc._internal() {
    Logger.root.level = Level.ALL;
  }

  Future initialize() async {
    Logger.root.onRecord.listen((LogRecord rec) {
      var pieces = ['(${rec.time}) · ${rec.loggerName.isEmpty ? 'root' : rec.loggerName} · ${rec.level.name.toUpperCase()}: ${rec.message}'];
      if (rec.error != null) pieces.add(rec.error.toString());
      if (rec.stackTrace != null) pieces.add(rec.stackTrace.toString());
      var levelName = 'debug';
      if (rec.level >= Level.SHOUT) {
        levelName = 'critical';
      } else if (rec.level >= Level.SEVERE) {
        levelName = 'error';
      } else if (rec.level >= Level.CONFIG) {
        // includes Level.INFO
        levelName = 'info';
      } else {
        levelName = 'debug';
      }

      var telemetry = {
        'level': levelName,
        'type': rec.error == null ? 'log' : 'error',
        'source': 'client',
        'timestamp_ms': rec.time.millisecondsSinceEpoch,
        'body': {
          'message': rec.message,
          if (rec.error != null) 'error': rec.error.toString(),
          if (rec.stackTrace != null) 'stack': rec.stackTrace.toString(),
        },
      };
      _logs.add(telemetry);

      // TODO: FirebaseCrashlytics.instance.log(pieces.join("\n"));

      print(pieces.join("\n"));
    });

    Connectivity().onConnectivityChanged.listen(_logConnectivity);
    _logConnectivity(await Connectivity().checkConnectivity());

    return Future.value();
  }

  logNetworkRequest({required String url, required String method, required int statusCode, required DateTime startTime, required DateTime endTime}) {
    var telemetry = {
      'level': 'info',
      'type': 'network',
      'timestamp_ms': DateTime.now().millisecondsSinceEpoch,
      'source': 'client',
      'body': {
        'url': url,
        'method': method,
        'status_code': statusCode,
        'start_time_ms': startTime.millisecondsSinceEpoch,
        'end_time_ms': endTime.millisecondsSinceEpoch,
      }
    };
    _logs.add(telemetry);
    print('(${DateTime.now()}) · Network · INFO: $method $url completed with $statusCode in ${endTime.difference(startTime).inMilliseconds / 1000}s');
  }

  _logConnectivity(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        Logger.root.info('Network Connectivity: mobile');
        _connectedSubject.add(true);
        break;
      case ConnectivityResult.wifi:
        Logger.root.info('Network Connectivity: wifi');
        _connectedSubject.add(true);
        break;
      case ConnectivityResult.none:
      default:
        Logger.root.info('Network Connectivity: none');
        _connectedSubject.add(false);
    }
  }

  void dispose() {
    _connectedSubject.close();
  }
}
