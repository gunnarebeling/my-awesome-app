import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:my_awesome_app/bloc/logging_bloc.dart';
import 'package:my_awesome_app/bloc/login_bloc.dart';
import 'package:my_awesome_app/model/user.dart';
import 'package:inventiv_critic_flutter/critic.dart';
import 'package:inventiv_critic_flutter/modal/bug_report.dart';
import 'package:logging/logging.dart';

class CriticBloc {
  static var _instance = CriticBloc.internal();

  @visibleForTesting
  static set instance(CriticBloc bloc) {
    _instance = bloc;
  }

  static void reset() {
    _instance.dispose();
    _instance = CriticBloc.internal();
  }

  factory CriticBloc() => _instance;

  Critic critic;

  @visibleForTesting
  CriticBloc.internal({Critic? critic}) : critic = critic ?? Critic();

  Logger get _log => Logger('CriticBloc');

  Future<void> initialize() async {
    if (await Critic().initialize('JXLT4W6WaCtkKvrZRujRdB1Y')) {
      _log.info('Critic initialized');
    } else {
      _log.warning('Critic failed to initialize');
    }
  }

  Future<BugReport> createReport({required String description}) async {
    User? user;
    try {
      user = await LoginBloc().currentUser.first;
    } catch (e) {
      // ignore
    }
    final report = BugReport.create(description: description, stepsToReproduce: '', userIdentifier: user?.id.toString() ?? 'anonymous');
    report.attachments = [];

    // Create a temporary file
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File('${tempDir.path}/logs.txt');

    // Write each log to the temporary file
    await tempFile.writeAsString(LoggingBloc().logs.join('\n'));

    report.attachments!.add(Attachment(name: 'logs.txt', path: tempFile.path));

    return critic.submitReport(report);
  }

  void dispose() {}
}
