import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class LoggingBloc {
  static var _instance = LoggingBloc._internal();

  factory LoggingBloc() => _instance;
  final List<String> _logs = [];
  List<String> get logs => _logs;

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
      final pieces = ['(${rec.time}) · ${rec.loggerName.isEmpty ? 'root' : rec.loggerName} · ${rec.level.name.toUpperCase()}: ${rec.message}'];
      if (rec.error != null) pieces.add(rec.error.toString());
      if (rec.stackTrace != null) pieces.add(rec.stackTrace.toString());

      _logs.add(pieces.join('\n'));

      FirebaseCrashlytics.instance.log(pieces.join('\n'));

      print(pieces.join('\n')); // ignore: avoid_print
    });

    Connectivity().onConnectivityChanged.listen(_logConnectivity);
    _logConnectivity(await Connectivity().checkConnectivity());

    return Future.value();
  }

  void logNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final message =
        '(${DateTime.now()}) · Network · INFO: $method $url completed with $statusCode in ${endTime.difference(startTime).inMilliseconds / 1000}s';
    _logs.add(message);

    // ignore: avoid_print
    print(message);
  }

  void _logConnectivity(List<ConnectivityResult> results) {
    for (ConnectivityResult result in results) {
      switch (result) {
        case ConnectivityResult.mobile:
          Logger.root.info('Network Connectivity: mobile');
          _connectedSubject.add(true);
        case ConnectivityResult.wifi:
          Logger.root.info('Network Connectivity: wifi');
          _connectedSubject.add(true);
        case ConnectivityResult.none:
        default:
          Logger.root.info('Network Connectivity: none');
          _connectedSubject.add(false);
      }
    }
  }

  void dispose() {
    _connectedSubject.close();
  }
}
