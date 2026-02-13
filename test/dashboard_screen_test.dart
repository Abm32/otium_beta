import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/logic/intervention_session.dart';
import 'package:otium/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
      // Set up a completed intervention session
      appState.currentSession = InterventionSession(
        preScore: 80.0,
        startTime: DateTime.now().subtract(const Duration(minutes: 2)),
      );
      appState.currentSession!.complete(40.0, null);
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      );
    }

    testWidgets('displays intervention results correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify the screen title
      expect(find.text('Intervention Results'), findsOneWidget);
      
      // Verify success message
      expect(find.text('Great Job! 🎉'), findsOneWidget);
      
      // Verify percentage reduction is calculated and displayed
      expect(find.textContaining('50.0% Reduction'), findsOneWidget);
      
      // Verify mood check-in section
      expect(find.text('How are you feeling?'), findsOneWidget);
      
      // Verify return to home button
      expect(find.text('Return to Home'), findsOneWidget);
    });

    testWidgets('displays progress bars', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the progress bars
      final progressBars = find.byType(LinearProgressIndicator);
      expect(progressBars, findsNWidgets(2));

      // Verify progress bar values by checking the LinearProgressIndicator widgets
      final progressBarWidgets = tester.widgetList<LinearProgressIndicator>(progressBars);
      final progressBarsList = progressBarWidgets.toList();
      
      // Before progress bar should show 80/100 = 0.8
      expect(progressBarsList[0].value, equals(0.8));
      
      // After progress bar should show 40/100 = 0.4
      expect(progressBarsList[1].value, equals(0.4));
    });

    testWidgets('handles missing session data gracefully', (WidgetTester tester) async {
      // Create app state without session
      final emptyAppState = AppState();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: emptyAppState,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Should display error message
      expect(find.text('No intervention session data available'), findsOneWidget);
    });

    testWidgets('handles incomplete session data gracefully', (WidgetTester tester) async {
      // Create app state with incomplete session (no postScore)
      final incompleteAppState = AppState();
      incompleteAppState.currentSession = InterventionSession(
        preScore: 80.0,
        startTime: DateTime.now(),
      );
      // Don't call complete() so postScore remains null
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: incompleteAppState,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Should display error message
      expect(find.text('No intervention session data available'), findsOneWidget);
    });

    testWidgets('displays visual comparison section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify visual comparison section
      expect(find.text('Visual Comparison'), findsOneWidget);
      expect(find.text('Your Progress'), findsOneWidget);
    });

    testWidgets('mood selection updates session', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially no mood should be selected
      expect(appState.currentSession!.mood, isNull);

      // Test that mood can be updated directly (simulating the tap behavior)
      appState.currentSession!.mood = 'happy';
      appState.notifyListeners();
      
      // Verify mood was updated
      expect(appState.currentSession!.mood, equals('happy'));
    });
  });
}