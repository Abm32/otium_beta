// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/screens/home_screen.dart';

void main() {
  testWidgets('App launches with HomeScreen', (WidgetTester tester) async {
    // Create AppState without auto-initialization for testing
    final appState = AppState(autoInitialize: false);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: MaterialApp(
          title: 'Otium',
          home: const HomeScreen(),
          routes: {
            '/alert': (context) => const Scaffold(body: Text('Alert Screen')),
            '/breathing': (context) => const Scaffold(body: Text('Breathing Screen')),
            '/dashboard': (context) => const Scaffold(body: Text('Dashboard Screen')),
          },
        ),
      ),
    );
    
    // Just pump a few times instead of pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the HomeScreen is displayed with correct content.
    expect(find.text('Otium'), findsOneWidget); // AppBar title
    expect(find.text('Cognitive Load Monitor'), findsOneWidget); // Main heading
    expect(find.text('Simulate App Switch'), findsOneWidget); // Button text
  });
}
