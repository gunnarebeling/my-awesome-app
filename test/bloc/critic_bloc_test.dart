import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:my_awesome_app/bloc/critic_bloc.dart';
import 'package:my_awesome_app/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventiv_critic_flutter/critic.dart';
import 'package:inventiv_critic_flutter/modal/bug_report.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'critic_bloc_test.mocks.dart';

@GenerateMocks([Critic, FirebaseCrashlytics, FirebaseAnalytics])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  late MockFirebaseCrashlytics firebaseCrashlytics;
  late MockFirebaseAnalytics firebaseAnalytics;

  setUpAll(() async {
    await Firebase.initializeApp();
    firebaseCrashlytics = MockFirebaseCrashlytics();
    LoginBloc.firebaseCrashlytics = firebaseCrashlytics;
    firebaseAnalytics = MockFirebaseAnalytics();
    LoginBloc.firebaseAnalytics = firebaseAnalytics;
  });

  test('Create report with correct description', () async {
    // Setup
    final criticBloc = CriticBloc();
    final mockCritic = MockCritic();
    criticBloc.critic = mockCritic;
    const description = 'Test description';

    // Mock the submitReport method
    when(mockCritic.submitReport(any)).thenAnswer(
      (_) async => BugReport(
        description: description,
        stepsToReproduce: '',
        userIdentifier: 'test',
      ),
    );

    // Call the createReport method
    await criticBloc.createReport(description: description);

    // Verify that the submitReport method was called with the correct description
    verify(
      mockCritic.submitReport(
        argThat(
          isA<BugReport>().having(
            (report) => report.description,
            'description',
            description,
          ),
        ),
      ),
    ).called(1);
  });
}
