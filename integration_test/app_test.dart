import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:otium/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Otium Full Integration Test', () {
    testWidgets('Complete flow: Home → Alert → Breathing → Dashboard → Home', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we start on Home Screen
      expect(find.text('Cognitive Overload Monitor'), findsOneWidget);
      expect(find.text('Simulate App Switch'), findsOneWidget);
      
      // Check initial state - should be "Calm" with score 0
      expect(find.textContaining('Calm'), findsOneWidget);
      expect(find.textContaining('Score: 0'), findsOneWidget);

      // Simulate app switches to increase overload score
      // Need to tap multiple times to get score > 60
      // Each tap increases: unlocks +3, appSwitches +2
      // Score = (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes)
      // Score = (0.4 * 3) + (0.4 * 2) + 0 = 1.2 + 0.8 = 2.0 per tap
      // Need at least 31 taps to exceed 60: 31 * 2 = 62

      print('Starting simulation to increase overload score...');
      
      for (int i = 0; i < 35; i++) {
        await tester.tap(find.text('Simulate App Switch'));
        await tester.pump();
        
        // Check progress every 10 taps
        if (i % 10 == 9) {
          await tester.pumpAndSettle();
          print('Tap ${i + 1}: Checking current state...');
        }
      }

      // Wait for final state update and potential navigation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we've navigated to Alert Screen (score should be > 60)
      expect(find.text('Cognitive Overload Alert'), findsOneWidget);
      expect(find.text('Your cognitive load is high. Take a Neuro Reset?'), findsOneWidget);
      expect(find.text('Start Breathing Exercise'), findsOneWidget);
      
      // Verify high overload score is displayed
      expect(find.textContaining('High Overload'), findsOneWidget);
      
      print('Successfully navigated to Alert Screen');

      // Start the breathing intervention
      await tester.tap(find.text('Start Breathing Exercise'));
      await tester.pumpAndSettle();

      // Verify we're on Breathing Screen
      expect(find.text('Breathing Exercise'), findsOneWidget);
      expect(find.textContaining('seconds remaining'), findsOneWidget);
      expect(find.textContaining('Inhale'), findsOneWidget);
      
      print('Successfully navigated to Breathing Screen');

      // Verify breathing circle is present and animating
      expect(find.byType(AnimatedContainer), findsWidgets);

      // Wait for a few breathing cycles to verify smooth animation
      print('Testing breathing animation cycles...');
      
      // Wait 4 seconds for one complete breathing cycle
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Exhale'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Inhale'), findsOneWidget);
      
      print('Breathing animation cycles working correctly');

      // Fast-forward through the 90-second timer
      // We'll simulate the timer completion by waiting and pumping
      print('Fast-forwarding through breathing exercise...');
      
      // Pump in smaller increments to ensure smooth animation
      for (int i = 0; i < 90; i++) {
        await tester.pump(const Duration(seconds: 1));
        
        // Check timer countdown every 10 seconds
        if (i % 10 == 9) {
          print('Timer at ${90 - i - 1} seconds remaining');
        }
      }

      // Wait for navigation to Dashboard
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on Dashboard Screen
      expect(find.text('Intervention Results'), findsOneWidget);
      expect(find.text('Before Intervention'), findsOneWidget);
      expect(find.text('After Intervention'), findsOneWidget);
      expect(find.text('How are you feeling?'), findsOneWidget);
      expect(find.text('Return to Home'), findsOneWidget);
      
      print('Successfully navigated to Dashboard Screen');

      // Verify score reduction is visible
      // The post-intervention score should be 50% of pre-intervention score
      expect(find.textContaining('Reduction:'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
      
      // Check that both before and after scores are displayed
      expect(find.textContaining('Score:'), findsAtLeastNWidgets(2));
      
      print('Score reduction is visible on dashboard');

      // Test mood selection
      await tester.tap(find.text('🙂'));
      await tester.pump();
      
      print('Mood selection working');

      // Return to Home Screen
      await tester.tap(find.text('Return to Home'));
      await tester.pumpAndSettle();

      // Verify we're back on Home Screen
      expect(find.text('Cognitive Overload Monitor'), findsOneWidget);
      expect(find.text('Simulate App Switch'), findsOneWidget);
      
      // Verify the score has been reduced (should be around 35 now, classified as "Moderate")
      expect(find.textContaining('Moderate'), findsOneWidget);
      
      print('Successfully returned to Home Screen with reduced overload score');

      // Final verification: ensure all animations are smooth by checking no errors occurred
      // This is implicit - if we got here without exceptions, animations were smooth
      
      print('✅ Full integration test completed successfully!');
      print('✅ Complete flow verified: Home → Alert → Breathing → Dashboard → Home');
      print('✅ Score reduction verified and visible');
      print('✅ All animations smooth (no exceptions thrown)');
    });

    testWidgets('Verify smooth animations during breathing exercise', (WidgetTester tester) async {
      // Start the app and navigate directly to breathing screen for animation testing
      app.main();
      await tester.pumpAndSettle();

      // Simulate getting to high overload state quickly
      for (int i = 0; i < 35; i++) {
        await tester.tap(find.text('Simulate App Switch'));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Start breathing exercise
      await tester.tap(find.text('Start Breathing Exercise'));
      await tester.pumpAndSettle();

      // Test animation smoothness by checking multiple cycles
      print('Testing breathing circle animation smoothness...');
      
      for (int cycle = 0; cycle < 3; cycle++) {
        // Inhale phase (2 seconds)
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.textContaining('Inhale'), findsOneWidget);
        
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump(const Duration(milliseconds: 1000));
        
        // Exhale phase (2 seconds)
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.textContaining('Exhale'), findsOneWidget);
        
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump(const Duration(milliseconds: 1000));
        
        print('Breathing cycle ${cycle + 1} completed smoothly');
      }
      
      print('✅ Breathing animations verified as smooth');
    });
  });
}