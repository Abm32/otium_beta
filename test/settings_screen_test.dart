import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:otium/logic/app_state.dart';
import 'package:otium/screens/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    /// Test basic rendering
    testWidgets('should render settings screen with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify app bar
      expect(find.text('Settings'), findsOneWidget);
      
      // Verify section headers
      expect(find.text('Real Sensing'), findsOneWidget);
      expect(find.text('Monitoring'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    /// Test real sensing section in simulated mode
    testWidgets('should show simulated mode settings when real sensing is off', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify real sensing toggle is off
      expect(find.text('Real Device Sensing'), findsOneWidget);
      expect(find.text('Using simulated data for demo'), findsOneWidget);
      
      // Verify demo mode info
      expect(find.text('Demo Mode'), findsOneWidget);
      expect(find.text('Tap "Simulate App Switch" to increase overload'), findsOneWidget);
    });

    /// Test background monitoring section
    testWidgets('should show background monitoring controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify background monitoring section
      expect(find.text('Background Monitoring'), findsOneWidget);
      expect(find.text('Manual monitoring only'), findsOneWidget);
      
      // Verify requirement message
      expect(find.text('Real Sensing Required'), findsOneWidget);
      expect(find.text('Enable real sensing to use background monitoring'), findsOneWidget);
    });

    /// Test statistics section
    testWidgets('should display current statistics', (WidgetTester tester) async {
      // Set some test metrics
      appState.metrics.unlocks = 25;
      appState.metrics.appSwitches = 40;
      appState.metrics.nightMinutes = 15;

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify current overload score display
      expect(find.text('Current Overload Score'), findsOneWidget);
      
      // Calculate expected score: (0.4 * 25) + (0.4 * 40) + (0.2 * 15) = 29.0
      expect(find.text('29.0 • Calm'), findsOneWidget);
      
      // Verify data source
      expect(find.text('Data Source'), findsOneWidget);
      expect(find.text('Simulated'), findsOneWidget);
    });

    /// Test about section
    testWidgets('should display about information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify about section
      expect(find.text('Otium'), findsAtLeastNWidgets(1)); // Title and about section
      expect(find.text('Digital wellness through cognitive overload detection'), findsOneWidget);
      expect(find.text('Privacy First'), findsOneWidget);
      expect(find.text('All data stays on your device'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.0.0 (Phase 1)'), findsOneWidget);
    });

    /// Test refresh metrics action
    testWidgets('should show refresh button when real sensing is active', (WidgetTester tester) async {
      // Enable real sensing mode
      appState.toggleSensingMode();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify refresh metrics option appears
      expect(find.text('Refresh Metrics'), findsOneWidget);
      expect(find.text('Get latest device usage data'), findsOneWidget);
    });

    /// Test view history action
    testWidgets('should show view history option', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify view history option
      expect(find.text('View History'), findsOneWidget);
      expect(find.text('See your overload trends over time'), findsOneWidget);
    });

    /// Test switch interactions
    testWidgets('should handle real sensing toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Find and tap the real sensing switch
      final realSensingSwitch = find.byType(Switch).first;
      expect(realSensingSwitch, findsOneWidget);
      
      // Initial state should be off
      expect(appState.useRealSensing, isFalse);
      
      // Tap the switch
      await tester.tap(realSensingSwitch);
      await tester.pump();
      
      // Note: In a real test, we'd need to mock the real sensing service
      // For now, we just verify the switch exists and is tappable
    });

    /// Test background monitoring switch
    testWidgets('should handle background monitoring toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Find the background monitoring switch
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(2)); // Real sensing + background monitoring
      
      // Background monitoring switch should be disabled when real sensing is off
      final backgroundSwitch = switches.at(1);
      expect(tester.widget<Switch>(backgroundSwitch).onChanged, isNull);
    });

    /// Test visual styling
    testWidgets('should have proper visual styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF8FAFB));
      
      // Verify cards are present (white containers with shadows)
      expect(find.byType(Container), findsAtLeastNWidgets(10));
    });

    /// Test animation
    testWidgets('should animate content on load', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Verify FadeTransition is present
      expect(find.byType(FadeTransition), findsOneWidget);
      
      // Pump animation frames
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      
      // Content should be visible after animation
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}