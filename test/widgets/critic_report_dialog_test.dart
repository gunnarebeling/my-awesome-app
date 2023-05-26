import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventiv_critic_flutter/modal/bug_report.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_app_base/widgets/critic_report_dialog.dart';
import 'package:flutter_app_base/bloc/critic_bloc.dart';

import 'critic_report_dialog_test.mocks.dart';

@GenerateMocks([CriticBloc])
void main() {
  late MockCriticBloc mockCriticBloc;
  setUp(() {
    mockCriticBloc = MockCriticBloc();
    CriticBloc.instance = mockCriticBloc;
  });

  tearDown(() {
    CriticBloc.reset();
  });

  testWidgets('CriticReportDialog displays description TextField', (WidgetTester tester) async {
    // Create the CriticReportDialog widget
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    // Pump the widget
    await tester.pumpWidget(widget);

    // Tap on the 'Show Dialog' button
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Check if the description TextField is displayed
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('CriticReportDialog displays Cancel button and closes dialog when tapped', (WidgetTester tester) async {
    // Create the CriticReportDialog widget
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    // Pump the widget
    await tester.pumpWidget(widget);

    // Tap on the 'Show Dialog' button
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Check if the Cancel button is displayed
    expect(find.text('Cancel'), findsOneWidget);

    // Tap on the Cancel button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Check if the dialog is closed
    expect(find.byType(CriticReportDialog), findsNothing);
  });

  testWidgets('CriticReportDialog displays Submit button and calls _submitReport when tapped', (WidgetTester tester) async {
    when(mockCriticBloc.createReport(description: anyNamed('description'))).thenAnswer((_) async {
      return BugReport();
    });

    // Create the CriticReportDialog widget
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    // Pump the widget
    await tester.pumpWidget(widget);

    // Tap on the 'Show Dialog' button
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Check if the Submit button is displayed
    expect(find.text('Submit'), findsOneWidget);

    // Tap on the Submit button
    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Verify that the _submitReport method was called
    verify(mockCriticBloc.createReport(description: anyNamed('description'))).called(1);

    // Clean up
    await tester.pumpAndSettle();
  });

  testWidgets('CriticReportDialog displays CircularProgressIndicator when _submitting is true', (WidgetTester tester) async {
    Completer<BugReport> completer = Completer<BugReport>();
    when(mockCriticBloc.createReport(description: anyNamed('description'))).thenAnswer((_) {
      return completer.future;
    });

    // Create the CriticReportDialog widget
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    // Pump the widget
    await tester.pumpWidget(widget);

    // Tap on the 'Show Dialog' button
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Tap on the Submit button
    await tester.tap(find.text('Submit'));
    await tester.pump(Duration(milliseconds: 100));

    // Check if CircularProgressIndicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Clean up
    completer.complete(BugReport());
    await tester.pumpAndSettle();
  });

  testWidgets('CriticReportDialog displays success SnackBar after successful report submission', (WidgetTester tester) async {
    when(mockCriticBloc.createReport(description: anyNamed('description'))).thenAnswer((_) async {
      return BugReport();
    });

    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pump(); // Start submitting
    await tester.pump(const Duration(seconds: 1)); // Finish submitting

    expect(find.text('Report submitted successfully'), findsOneWidget);
  });

  testWidgets('CriticReportDialog displays error SnackBar after failed report submission', (WidgetTester tester) async {
    when(mockCriticBloc.createReport(description: anyNamed('description'))).thenThrow(Exception('Test error'));

    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CriticReportDialog();
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pump(); // Start submitting
    await tester.pump(const Duration(seconds: 1)); // Finish submitting

    expect(find.text('Error submitting report: Exception: Test error'), findsOneWidget);
  });
}
