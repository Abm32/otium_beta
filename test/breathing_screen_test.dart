import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/screens/breathing_screen.dart';
import 'package:otium/widgets/breathing_circle.dart';

void main() {
  group('BreathingScreen Widget Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    /// Test timer initialization
    /// Validates: Requirements 5.1
    testWidgets('should initialize with 90-second timer', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Assert - verify initial timer display shows 01:30 (90 seconds)
      expect(find.text('01:30'), findsOneWidget);
      
      // Verify breathing circle is present
      expect(find.byType(BreathingCircle), findsOneWidget);
      
      // Verify initial breathing instruction
      expect(find.text('Inhale'), findsOneWidget);
      
      // Verify progress indicator is present
      final progressContainer = find.byType(FractionallySizedBox);
      expect(progressContainer, findsOneWidget);
    });

    /// Test timer countdown functionality
    /// Validates: Requirements 5.1
    testWidgets('should countdown timer correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Initial state - 90 seconds (01:30)
      expect(find.text('01:30'), findsOneWidget);

      // Act - advance timer by 1 second using periodic timer
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - should show 89 seconds (01:29)
      expect(find.text('01:29'), findsOneWidget);

      // Act - advance timer by 30 more seconds
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Assert - should show 59 seconds (00:59)
      expect(find.text('00:59'), findsOneWidget);
    });

    /// Test breathing phase toggles
    /// Validates: Requirements 5.3, 5.4
    testWidgets('should toggle breathing phases every 2 seconds', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Initial state - should start with inhale
      expect(find.text('Inhale'), findsOneWidget);
      expect(find.text('Exhale'), findsNothing);

      // Verify BreathingCircle receives correct initial state
      final breathingCircle = tester.widget<BreathingCircle>(find.byType(BreathingCircle));
      expect(breathingCircle.isInhaling, isTrue);

      // Act - advance by 2 seconds (first phase toggle)
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - should switch to exhale
      expect(find.text('Exhale'), findsOneWidget);
      expect(find.text('Inhale'), findsNothing);

      // Verify BreathingCircle receives updated state
      final breathingCircleAfterToggle = tester.widget<BreathingCircle>(find.byType(BreathingCircle));
      expect(breathingCircleAfterToggle.isInhaling, isFalse);

      // Act - advance by another 2 seconds (second phase toggle)
      await tester.pump(const Duration(seconds: 2));

      // Assert - should switch back to inhale
      expect(find.text('Inhale'), findsOneWidget);
      expect(find.text('Exhale'), findsNothing);

      // Verify BreathingCircle receives updated state again
      final breathingCircleAfterSecondToggle = tester.widget<BreathingCircle>(find.byType(BreathingCircle));
      expect(breathingCircleAfterSecondToggle.isInhaling, isTrue);
    });

    /// Test multiple breathing cycles
    /// Validates: Requirements 5.2, 5.3, 5.4
    testWidgets('should complete multiple breathing cycles during intervention', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Track breathing phases over time
      final List<String> breathingPhases = [];

      // Initial phase
      breathingPhases.add('Inhale'); // t=0s
      expect(find.text('Inhale'), findsOneWidget);

      // Complete several 4-second cycles (inhale 2s + exhale 2s = 4s cycle)
      for (int cycle = 0; cycle < 3; cycle++) {
        // Advance 2 seconds - should switch to exhale
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        breathingPhases.add('Exhale');
        expect(find.text('Exhale'), findsOneWidget);

        // Advance another 2 seconds - should switch to inhale
        await tester.pump(const Duration(seconds: 2));
        breathingPhases.add('Inhale');
        expect(find.text('Inhale'), findsOneWidget);
      }

      // Assert - should have alternated correctly
      expect(breathingPhases, [
        'Inhale',   // t=0s
        'Exhale',   // t=2s
        'Inhale',   // t=4s
        'Exhale',   // t=6s
        'Inhale',   // t=8s
        'Exhale',   // t=10s
        'Inhale',   // t=12s
      ]);
    });

    /// Test navigation after timer completion
    /// Validates: Requirements 5.5
    testWidgets('should navigate to dashboard screen when timer completes', (WidgetTester tester) async {
      // Arrange
      bool dashboardNavigationCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            initialRoute: '/breathing',
            routes: {
              '/breathing': (context) => const BreathingScreen(),
              '/dashboard': (context) {
                dashboardNavigationCalled = true;
                return const Scaffold(body: Text('Dashboard Screen'));
              },
            },
          ),
        ),
      );

      // Verify initial state - session should be started automatically
      expect(appState.currentSession, isNotNull);
      expect(find.text('01:30'), findsOneWidget);

      // Act - advance timer to completion (90 seconds) by pumping 90 times
      await tester.pump();
      for (int i = 0; i < 90; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      // Assert - should have called completeIntervention
      expect(appState.currentSession!.postScore, isNotNull);

      // Assert - should have navigated to dashboard screen
      expect(dashboardNavigationCalled, isTrue);
      expect(find.text('Dashboard Screen'), findsOneWidget);
    });

    /// Test intervention completion with state changes
    /// Validates: Requirements 5.5, 6.1, 6.3
    testWidgets('should complete intervention and update app state when timer finishes', (WidgetTester tester) async {
      // Arrange - set up initial metrics for intervention
      appState.metrics.unlocks = 80;
      appState.metrics.appSwitches = 80;
      appState.metrics.nightMinutes = 50;
      // Initial score: (0.4 * 80) + (0.4 * 80) + (0.2 * 50) = 74.0

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            initialRoute: '/breathing',
            routes: {
              '/breathing': (context) => const BreathingScreen(),
              '/dashboard': (context) => const Scaffold(body: Text('Dashboard Screen')),
            },
          ),
        ),
      );

      // Verify initial state - session should be started automatically
      expect(appState.currentSession, isNotNull);
      final initialScore = appState.currentScore;
      expect(initialScore, equals(74.0));

      // Act - advance timer to completion by pumping 90 times
      await tester.pump();
      for (int i = 0; i < 90; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      // Assert - intervention should be completed
      expect(appState.currentSession, isNotNull);
      expect(appState.currentSession!.preScore, equals(74.0));
      expect(appState.currentSession!.postScore, isNotNull);

      // Assert - metrics should be reduced by 50%
      expect(appState.metrics.unlocks, equals(40)); // 80 * 0.5
      expect(appState.metrics.appSwitches, equals(40)); // 80 * 0.5
      expect(appState.metrics.nightMinutes, equals(25)); // 50 * 0.5

      // Assert - score should be reduced accordingly
      final finalScore = appState.currentScore;
      expect(finalScore, equals(37.0)); // (0.4 * 40) + (0.4 * 40) + (0.2 * 25) = 37.0
      expect(appState.currentSession!.postScore, equals(finalScore));
    });

    /// Test progress indicator updates
    /// Validates: Requirements 5.1
    testWidgets('should update progress indicator as timer counts down', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Get initial progress indicator
      final initialProgressFinder = find.byType(FractionallySizedBox);
      expect(initialProgressFinder, findsOneWidget);
      
      final initialProgress = tester.widget<FractionallySizedBox>(initialProgressFinder);
      expect(initialProgress.widthFactor, equals(0.0)); // 0/90 = 0% progress

      // Act - advance timer by 30 seconds
      await tester.pump();
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Assert - progress should be 1/3 complete
      final midProgress = tester.widget<FractionallySizedBox>(initialProgressFinder);
      expect(midProgress.widthFactor, closeTo(0.333, 0.01)); // 30/90 = 33.3%

      // Act - advance timer by another 30 seconds (60 total)
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Assert - progress should be 2/3 complete
      final lateProgress = tester.widget<FractionallySizedBox>(initialProgressFinder);
      expect(lateProgress.widthFactor, closeTo(0.667, 0.01)); // 60/90 = 66.7%
    });

    /// Test timer formatting edge cases
    /// Validates: Requirements 5.1
    testWidgets('should format timer correctly for edge cases', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Test initial time format (90 seconds = 1:30)
      expect(find.text('01:30'), findsOneWidget);

      // Test various time formats by advancing timer
      await tester.pump();
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('01:00'), findsOneWidget); // 60 seconds = 1:00

      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('00:10'), findsOneWidget); // 10 seconds = 0:10

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('00:05'), findsOneWidget); // 5 seconds = 0:05

      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('00:01'), findsOneWidget); // 1 second = 0:01
    });

    /// Test widget disposal and cleanup
    testWidgets('should properly dispose timers when widget is disposed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Verify widget is built
      expect(find.byType(BreathingScreen), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);

      // Act - navigate away (dispose the widget)
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: Scaffold(body: Text('Different Screen')),
          ),
        ),
      );

      // Assert - widget should be disposed without errors
      expect(find.byType(BreathingScreen), findsNothing);
      expect(find.text('Different Screen'), findsOneWidget);
      
      // No way to directly test timer disposal, but if timers weren't disposed,
      // we might see errors or memory leaks. The test passing indicates proper cleanup.
    });

    /// Test visual elements and styling
    testWidgets('should display all visual elements correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Assert - verify all key visual elements are present
      expect(find.text('01:30'), findsOneWidget); // Timer display
      expect(find.text('Inhale'), findsOneWidget); // Breathing instruction
      expect(find.byType(BreathingCircle), findsOneWidget); // Breathing circle
      expect(find.byType(FractionallySizedBox), findsOneWidget); // Progress indicator
      
      // Verify container structure (gradient background)
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
      
      // Verify SafeArea is present
      expect(find.byType(SafeArea), findsOneWidget);
      
      // Verify main column layout (there may be multiple columns in the widget tree)
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    /// Test breathing instruction text updates
    /// Validates: Requirements 5.3, 5.4
    testWidgets('should display correct breathing instructions for each phase', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Test instruction text over multiple cycles
      final expectedInstructions = [
        'Inhale',   // t=0s (initial)
        'Exhale',   // t=2s
        'Inhale',   // t=4s
        'Exhale',   // t=6s
        'Inhale',   // t=8s
      ];

      for (int i = 0; i < expectedInstructions.length; i++) {
        if (i > 0) {
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
        }
        
        expect(find.text(expectedInstructions[i]), findsOneWidget,
               reason: 'At ${i * 2} seconds, should show "${expectedInstructions[i]}"');
        
        // Verify only one instruction is shown at a time
        final otherInstruction = expectedInstructions[i] == 'Inhale' ? 'Exhale' : 'Inhale';
        expect(find.text(otherInstruction), findsNothing,
               reason: 'Should not show "$otherInstruction" when showing "${expectedInstructions[i]}"');
      }
    });

    /// Test early navigation prevention
    testWidgets('should not navigate before timer completion', (WidgetTester tester) async {
      // Arrange
      bool dashboardNavigationCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            initialRoute: '/breathing',
            routes: {
              '/breathing': (context) => const BreathingScreen(),
              '/dashboard': (context) {
                dashboardNavigationCalled = true;
                return const Scaffold(body: Text('Dashboard Screen'));
              },
            },
          ),
        ),
      );

      // Act - advance timer but not to completion (89 seconds, 1 short of 90)
      await tester.pump();
      for (int i = 0; i < 89; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Assert - should not have navigated yet
      expect(dashboardNavigationCalled, isFalse);
      expect(find.text('00:01'), findsOneWidget); // Should show 1 second remaining
      expect(find.byType(BreathingScreen), findsOneWidget);
      expect(find.text('Dashboard Screen'), findsNothing);

      // Act - advance the final second
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert - now should have navigated
      expect(dashboardNavigationCalled, isTrue);
      expect(find.text('Dashboard Screen'), findsOneWidget);
    });

    /// Test that BreathingScreen starts intervention session
    /// Validates: Requirements 5.5
    testWidgets('should start intervention session when screen loads', (WidgetTester tester) async {
      // Arrange
      expect(appState.currentSession, isNull);

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Assert - session should be started automatically
      expect(appState.currentSession, isNotNull);
      expect(appState.currentSession!.preScore, equals(appState.currentScore));
    });

    /// Test breathing circle animation state
    /// Validates: Requirements 5.3, 5.4
    testWidgets('should pass correct animation state to BreathingCircle', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: BreathingScreen(),
          ),
        ),
      );

      // Initial state - inhaling
      BreathingCircle breathingCircle = tester.widget<BreathingCircle>(find.byType(BreathingCircle));
      expect(breathingCircle.isInhaling, isTrue);

      // After 2 seconds - exhaling
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      breathingCircle = tester.widget<BreathingCircle>(find.byType(BreathingCircle));
      expect(breathingCircle.isInhaling, isFalse);

      // After another 2 seconds - inhaling again
      await tester.pump(const Duration(seconds: 2));
      breathingCircle = tester.widget<BreathingCircle>(find.byType(BreathingCircle));
      expect(breathingCircle.isInhaling, isTrue);
    });
  });
}