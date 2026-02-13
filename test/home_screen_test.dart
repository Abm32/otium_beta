import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/screens/home_screen.dart';
import 'package:otium/widgets/cognitive_meter.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('renders with zero metrics initially', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Assert
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
      expect(find.text('Otium'), findsOneWidget);
      expect(find.byType(CognitiveMeter), findsOneWidget);
      
      // Check metrics display
      expect(find.text('Device Unlocks'), findsOneWidget);
      expect(find.text('App Switches'), findsOneWidget);
      expect(find.text('Night Minutes'), findsOneWidget);
      
      // Check initial values are 0 for metrics
      expect(find.text('0'), findsNWidgets(3)); // Three metrics at 0
      
      // Check button exists
      expect(find.text('Simulate App Switch'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android_rounded), findsOneWidget);
    });

    testWidgets('button press updates metrics', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Verify initial state
      expect(appState.metrics.unlocks, 0);
      expect(appState.metrics.appSwitches, 0);

      // Act - tap the simulate button
      await tester.scrollUntilVisible(
        find.text('Simulate App Switch'),
        500.0,
      );
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pump();

      // Assert - metrics should be updated
      expect(appState.metrics.unlocks, 3);
      expect(appState.metrics.appSwitches, 2);
      
      // Verify UI updates
      expect(find.text('3'), findsOneWidget); // unlocks
      expect(find.text('2'), findsOneWidget); // appSwitches
    });

    testWidgets('multiple button presses accumulate metrics', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Act - tap the simulate button twice
      await tester.scrollUntilVisible(
        find.text('Simulate App Switch'),
        500.0,
      );
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pump();
      
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pump();

      // Assert - metrics should accumulate
      expect(appState.metrics.unlocks, 6);
      expect(appState.metrics.appSwitches, 4);
      
      // Verify UI updates
      expect(find.text('6'), findsOneWidget); // unlocks
      expect(find.text('4'), findsOneWidget); // appSwitches
    });

    testWidgets('navigation triggers when score exceeds 60', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set metrics to a value that will result in score > 60
      // Formula: (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes)
      // To get score > 60, we need: 0.4 * 80 + 0.4 * 80 = 64
      appState.metrics.unlocks = 80;
      appState.metrics.appSwitches = 80;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Act - wait for post-frame callback to execute
      await tester.pumpAndSettle();

      // Assert - should navigate to alert screen
      expect(find.text('Alert Screen'), findsOneWidget);
      expect(find.text('Monitor Your Cognitive Load'), findsNothing);
    });

    testWidgets('no navigation when score is below threshold', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set metrics to a value that results in score <= 60
      // Formula: 0.4 * 50 + 0.4 * 50 = 40
      appState.metrics.unlocks = 50;
      appState.metrics.appSwitches = 50;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Act - wait for post-frame callback to execute
      await tester.pumpAndSettle();

      // Assert - should stay on home screen
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
      expect(find.text('Alert Screen'), findsNothing);
    });

    testWidgets('navigation triggers exactly at threshold boundary (score = 60.1)', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set metrics to get score just above 60
      // Formula: 0.4 * 75 + 0.4 * 76 = 60.4
      appState.metrics.unlocks = 75;
      appState.metrics.appSwitches = 76;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Act - wait for post-frame callback to execute
      await tester.pumpAndSettle();

      // Assert - should navigate to alert screen
      expect(find.text('Alert Screen'), findsOneWidget);
    });

    testWidgets('displays correct score and classification', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      appState.metrics.unlocks = 30;
      appState.metrics.appSwitches = 30;
      // Score = 0.4 * 30 + 0.4 * 30 = 24 (Calm)

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Assert
      expect(find.text('24.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('CognitiveMeter updates when metrics change', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Initial state
      expect(find.text('0.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places

      // Act - simulate app switch
      await tester.scrollUntilVisible(
        find.text('Simulate App Switch'),
        500.0,
      );
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pump();

      // Assert - score should update
      // Score = 0.4 * 3 + 0.4 * 2 = 2.0
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('button press triggers navigation when score exceeds threshold', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set initial metrics close to threshold
      // We need to reach score > 60 after button presses
      // Button press adds: unlocks +3, appSwitches +2
      // Score increase per button press: 0.4 * 3 + 0.4 * 2 = 2.0
      // To exceed 60, we need initial score around 58
      // 0.4 * 72 + 0.4 * 73 = 58.0
      appState.metrics.unlocks = 72;
      appState.metrics.appSwitches = 73;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Verify we start on home screen (score should be 58.0)
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
      expect(find.text('Alert Screen'), findsNothing);

      // Act - tap button to push score over threshold
      // After button press: unlocks = 75, appSwitches = 75
      // New score: 0.4 * 75 + 0.4 * 75 = 60.0 (exactly at threshold, need > 60)
      await tester.scrollUntilVisible(
        find.text('Simulate App Switch'),
        500.0,
      );
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pump();
      
      // Still on home screen after first tap (score = 60.0)
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
      
      // Second tap should trigger navigation
      // After second tap: unlocks = 78, appSwitches = 77
      // New score: 0.4 * 78 + 0.4 * 77 = 62.0 (exceeds threshold)
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pumpAndSettle();

      // Assert - should navigate to alert screen
      expect(find.text('Alert Screen'), findsOneWidget);
      expect(find.text('Monitor Your Cognitive Load'), findsNothing);
    });

    testWidgets('auto-navigation works on screen initialization with high score', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set metrics to result in score > 60 from the start
      // Score = 0.4 * 85 + 0.4 * 85 = 68.0
      appState.metrics.unlocks = 85;
      appState.metrics.appSwitches = 85;

      // Act - build the widget with high score
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Wait for post-frame callback to execute
      await tester.pumpAndSettle();

      // Assert - should immediately navigate to alert screen
      expect(find.text('Alert Screen'), findsOneWidget);
      expect(find.text('Monitor Your Cognitive Load'), findsNothing);
    });

    testWidgets('displays all UI elements correctly', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Assert - check all UI elements are present
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
      expect(find.text('Track your app usage and manage cognitive overload'), findsOneWidget);
      expect(find.text('Current Metrics'), findsOneWidget);
      expect(find.text('Simulate App Switch'), findsOneWidget);
      expect(find.text('Tap the button to simulate app switching behavior and increase your cognitive load metrics.'), findsOneWidget);
      
      // Check metric icons are present
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
      expect(find.byIcon(Icons.phone_android_rounded), findsOneWidget);
      
      // Check AppBar
      expect(find.text('Otium'), findsOneWidget);
    });

    testWidgets('metric rows display correct values and colors', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      appState.metrics.unlocks = 15;
      appState.metrics.appSwitches = 25;
      appState.metrics.nightMinutes = 10;

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Assert - check metric values are displayed
      expect(find.text('15'), findsOneWidget); // unlocks
      expect(find.text('25'), findsOneWidget); // appSwitches  
      expect(find.text('10'), findsOneWidget); // nightMinutes
      
      // Check metric labels
      expect(find.text('Device Unlocks'), findsOneWidget);
      expect(find.text('App Switches'), findsOneWidget);
      expect(find.text('Night Minutes'), findsOneWidget);
    });

    testWidgets('score updates correctly with different metric combinations', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set metrics for moderate classification
      // Score = 0.4 * 50 + 0.4 * 50 + 0.2 * 100 = 60.0 (Moderate)
      appState.metrics.unlocks = 50;
      appState.metrics.appSwitches = 50;
      appState.metrics.nightMinutes = 100;

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Assert - should show moderate classification
      expect(find.text('60.0'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      
      // Should not navigate (score = 60, need > 60)
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
    });

    testWidgets('night minutes contribute to score calculation', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      
      // Set only night minutes to test their contribution
      // Score = 0.2 * 150 = 30.0 (exactly at Calm/Moderate boundary)
      appState.metrics.nightMinutes = 150;

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Assert
      expect(find.text('30.0'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget); // 30.0 is Moderate (30-60 inclusive)
    });

    testWidgets('button remains functional after multiple rapid taps', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Act - rapid button taps
      final buttonFinder = find.text('Simulate App Switch');
      await tester.scrollUntilVisible(buttonFinder, 500.0);
      
      for (int i = 0; i < 5; i++) {
        await tester.tap(buttonFinder);
        await tester.pump();
      }

      // Assert - metrics should accumulate correctly
      expect(appState.metrics.unlocks, 15); // 5 * 3
      expect(appState.metrics.appSwitches, 10); // 5 * 2
      
      // UI should reflect the changes
      expect(find.text('15'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('navigation passes correct score as argument', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();
      double? passedScore;
      
      // Set metrics to trigger navigation
      appState.metrics.unlocks = 80;
      appState.metrics.appSwitches = 80;
      // Score = 0.4 * 80 + 0.4 * 80 = 64.0

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) {
                passedScore = ModalRoute.of(context)?.settings.arguments as double?;
                return const Scaffold(body: Text('Alert Screen'));
              },
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - correct score should be passed as argument
      expect(passedScore, 64.0);
      expect(find.text('Alert Screen'), findsOneWidget);
    });

    testWidgets('widget rebuilds correctly when AppState changes', (WidgetTester tester) async {
      // Arrange
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            },
          ),
        ),
      );

      // Initial state
      expect(find.text('0.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places

      // Act - change state externally (simulating state change from another part of app)
      appState.metrics.unlocks = 40;
      appState.metrics.appSwitches = 35;
      appState.notifyListeners();
      await tester.pump();

      // Assert - UI should update
      // Score = 0.4 * 40 + 0.4 * 35 = 30.0
      expect(find.text('30.0'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
    });
  });
}
