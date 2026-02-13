import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:otium/main.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/screens/home_screen.dart';
import 'package:otium/screens/alert_screen.dart';
import 'package:otium/screens/dashboard_screen.dart';

void main() {
  group('Navigation Routes Tests', () {
    testWidgets('App starts with HomeScreen as initial route', (WidgetTester tester) async {
      await tester.pumpWidget(const OtiumApp());
      
      // Verify HomeScreen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Monitor Your Cognitive Load'), findsOneWidget);
    });

    testWidgets('Route arguments are passed correctly to AlertScreen', (WidgetTester tester) async {
      const testScore = 85.5;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/alert', arguments: testScore);
              },
              child: const Text('Navigate'),
            ),
          ),
          routes: {
            '/alert': (context) {
              final score = ModalRoute.of(context)?.settings.arguments as double;
              return AlertScreen(currentScore: score);
            },
          },
        ),
      );
      
      // Tap the navigation button
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      
      // Verify the score is displayed correctly
      expect(find.text('85.5'), findsOneWidget);
    });

    testWidgets('Dashboard screen displays with session data', (WidgetTester tester) async {
      // Create app state with a completed session
      final appState = AppState();
      appState.startIntervention();
      appState.completeIntervention(null);
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: MaterialApp(
            home: const DashboardScreen(),
          ),
        ),
      );
      
      // Verify DashboardScreen is displayed
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Great Job! 🎉'), findsOneWidget);
    });

    testWidgets('All named routes are defined in main app', (WidgetTester tester) async {
      await tester.pumpWidget(const OtiumApp());
      
      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify all expected routes are defined
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/'), isTrue);
      expect(materialApp.routes!.containsKey('/alert'), isTrue);
      expect(materialApp.routes!.containsKey('/breathing'), isTrue);
      expect(materialApp.routes!.containsKey('/dashboard'), isTrue);
      
      // Verify initial route is set correctly
      expect(materialApp.initialRoute, equals('/'));
    });
  });
}