import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/screens/home_screen.dart';
import 'package:otium/widgets/cognitive_meter.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('renders with zero metrics initially', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);

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
      
      // Wait for initial animations but not infinite ones
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Check for new premium UI elements
      expect(find.text('Cognitive Load Monitor'), findsOneWidget);
      expect(find.text('Otium'), findsOneWidget);
      expect(find.byType(CognitiveMeter), findsOneWidget);
      
      // Check metrics display with new labels
      expect(find.text('Unlocks'), findsOneWidget);
      expect(find.text('App Switches'), findsOneWidget);
      expect(find.text('Night Usage (minutes)'), findsOneWidget);
      
      // Check initial values are 0 for metrics
      expect(find.text('0'), findsNWidgets(3)); // Three metrics at 0
      
      // Check button exists
      expect(find.text('Simulate App Switch'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android_rounded), findsOneWidget);
    });

    testWidgets('button press updates metrics in demo mode', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);

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
      
      // Wait for initial animations but not infinite ones
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify initial state
      expect(appState.metrics.unlocks, 0);
      expect(appState.metrics.appSwitches, 0);

      // Force demo mode for testing (should already be demo mode)
      if (appState.useRealSensing) {
        appState.toggleSensingMode(); // Toggle to demo mode
        await tester.pump();
      }
      
      // Act - tap the simulate button
      await tester.tap(find.text('Simulate App Switch'));
      await tester.pump();

      // Assert - metrics should be updated
      expect(appState.metrics.unlocks, 3);
      expect(appState.metrics.appSwitches, 2);
      
      // Verify UI updates
      expect(find.text('3'), findsOneWidget); // unlocks
      expect(find.text('2'), findsOneWidget); // appSwitches
    });

    testWidgets('displays correct score and classification', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);
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
      
      // Wait for initial animations but not infinite ones
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('24.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('navigation triggers when score exceeds 60', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);
      
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - should navigate to alert screen
      expect(find.text('Alert Screen'), findsOneWidget);
      expect(find.text('Cognitive Load Monitor'), findsNothing);
    });

    testWidgets('no navigation when score is below threshold', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);
      
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - should stay on home screen
      expect(find.text('Cognitive Load Monitor'), findsOneWidget);
      expect(find.text('Alert Screen'), findsNothing);
    });

    testWidgets('displays all UI elements correctly', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);

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
      
      // Wait for initial animations but not infinite ones
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - check all UI elements are present with new premium UI text
      expect(find.text('Cognitive Load Monitor'), findsOneWidget);
      expect(find.text('Usage Metrics'), findsOneWidget);
      expect(find.text('Simulate App Switch'), findsOneWidget);
      
      // Check metric icons are present
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    });

    testWidgets('real sensing status is displayed correctly', (WidgetTester tester) async {
      // Arrange - Create AppState without auto-initialization for testing
      final appState = AppState(autoInitialize: false);

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
      
      // Wait for initial animations but not infinite ones
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - check sensing status is displayed
      // Should show either "Real Sensing Active" or "Demo Mode"
      final realSensingActive = find.text('Real Sensing Active');
      final demoMode = find.text('Demo Mode');
      
      expect(realSensingActive.evaluate().isNotEmpty || demoMode.evaluate().isNotEmpty, isTrue);
    });
  });
}