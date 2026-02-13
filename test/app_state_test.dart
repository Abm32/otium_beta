import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:otium/logic/app_state.dart';

void main() {
  group('AppState', () {
    group('initialization', () {
      test('initializes with default zero metrics', () {
        final appState = AppState();
        
        expect(appState.metrics.unlocks, equals(0));
        expect(appState.metrics.appSwitches, equals(0));
        expect(appState.metrics.nightMinutes, equals(0));
        expect(appState.currentSession, isNull);
      });

      test('currentScore is 0 with zero metrics', () {
        final appState = AppState();
        expect(appState.currentScore, equals(0.0));
      });

      test('classification is "Calm" with zero metrics', () {
        final appState = AppState();
        expect(appState.classification, equals("Calm"));
      });
    });

    group('currentScore getter', () {
      test('calculates score correctly with non-zero metrics', () {
        final appState = AppState();
        appState.metrics.unlocks = 10;
        appState.metrics.appSwitches = 20;
        appState.metrics.nightMinutes = 30;
        
        // Expected: (0.4 * 10) + (0.4 * 20) + (0.2 * 30) = 4 + 8 + 6 = 18
        expect(appState.currentScore, equals(18.0));
      });

      test('updates dynamically when metrics change', () {
        final appState = AppState();
        
        expect(appState.currentScore, equals(0.0));
        
        appState.metrics.unlocks = 50;
        expect(appState.currentScore, equals(20.0)); // 0.4 * 50 = 20
        
        appState.metrics.appSwitches = 50;
        expect(appState.currentScore, equals(40.0)); // 20 + 20 = 40
        
        appState.metrics.nightMinutes = 100;
        expect(appState.currentScore, equals(60.0)); // 40 + 20 = 60
      });

      test('calculates high overload score correctly', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 100;
        
        // Expected: (0.4 * 100) + (0.4 * 100) + (0.2 * 100) = 40 + 40 + 20 = 100
        expect(appState.currentScore, equals(100.0));
      });
    });

    group('classification getter', () {
      test('returns "Calm" for score < 30', () {
        final appState = AppState();
        appState.metrics.unlocks = 10;
        appState.metrics.appSwitches = 10;
        appState.metrics.nightMinutes = 10;
        
        // Score: (0.4 * 10) + (0.4 * 10) + (0.2 * 10) = 10
        expect(appState.currentScore, equals(10.0));
        expect(appState.classification, equals("Calm"));
      });

      test('returns "Moderate" for score = 30', () {
        final appState = AppState();
        appState.metrics.unlocks = 50;
        appState.metrics.appSwitches = 25;
        appState.metrics.nightMinutes = 0;
        
        // Score: (0.4 * 50) + (0.4 * 25) + (0.2 * 0) = 20 + 10 + 0 = 30
        expect(appState.currentScore, equals(30.0));
        expect(appState.classification, equals("Moderate"));
      });

      test('returns "Moderate" for score between 30 and 60', () {
        final appState = AppState();
        appState.metrics.unlocks = 50;
        appState.metrics.appSwitches = 50;
        appState.metrics.nightMinutes = 50;
        
        // Score: (0.4 * 50) + (0.4 * 50) + (0.2 * 50) = 20 + 20 + 10 = 50
        expect(appState.currentScore, equals(50.0));
        expect(appState.classification, equals("Moderate"));
      });

      test('returns "Moderate" for score = 60', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 50;
        appState.metrics.nightMinutes = 0;
        
        // Score: (0.4 * 100) + (0.4 * 50) + (0.2 * 0) = 40 + 20 + 0 = 60
        expect(appState.currentScore, equals(60.0));
        expect(appState.classification, equals("Moderate"));
      });

      test('returns "High Overload" for score > 60', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 0;
        
        // Score: (0.4 * 100) + (0.4 * 100) + (0.2 * 0) = 40 + 40 + 0 = 80
        expect(appState.currentScore, equals(80.0));
        expect(appState.classification, equals("High Overload"));
      });
    });

    group('simulateAppSwitch', () {
      test('increases metrics correctly', () {
        final appState = AppState();
        
        appState.simulateAppSwitch();
        
        expect(appState.metrics.unlocks, equals(3));
        expect(appState.metrics.appSwitches, equals(2));
        expect(appState.metrics.nightMinutes, equals(0));
      });

      test('updates currentScore after simulation', () {
        final appState = AppState();
        
        expect(appState.currentScore, equals(0.0));
        
        appState.simulateAppSwitch();
        
        // Expected: (0.4 * 3) + (0.4 * 2) + (0.2 * 0) = 1.2 + 0.8 + 0 = 2.0
        expect(appState.currentScore, equals(2.0));
      });

      test('notifies listeners', () {
        final appState = AppState();
        var notificationCount = 0;
        
        appState.addListener(() {
          notificationCount++;
        });
        
        appState.simulateAppSwitch();
        
        expect(notificationCount, equals(1));
      });

      test('accumulates over multiple calls', () {
        final appState = AppState();
        
        appState.simulateAppSwitch();
        appState.simulateAppSwitch();
        appState.simulateAppSwitch();
        
        expect(appState.metrics.unlocks, equals(9));
        expect(appState.metrics.appSwitches, equals(6));
        
        // Expected: (0.4 * 9) + (0.4 * 6) + (0.2 * 0) = 3.6 + 2.4 + 0 = 6.0
        expect(appState.currentScore, equals(6.0));
      });
    });

    group('startIntervention', () {
      test('creates new intervention session with current score', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 0;
        
        final scoreBefore = appState.currentScore;
        expect(scoreBefore, equals(80.0));
        
        appState.startIntervention();
        
        expect(appState.currentSession, isNotNull);
        expect(appState.currentSession!.preScore, equals(80.0));
        expect(appState.currentSession!.postScore, isNull);
        expect(appState.currentSession!.startTime, isNotNull);
      });

      test('notifies listeners', () {
        final appState = AppState();
        var notificationCount = 0;
        
        appState.addListener(() {
          notificationCount++;
        });
        
        appState.startIntervention();
        
        expect(notificationCount, equals(1));
      });

      test('replaces previous session when called again', () {
        final appState = AppState();
        appState.metrics.unlocks = 50;
        
        appState.startIntervention();
        final firstSession = appState.currentSession;
        
        appState.metrics.unlocks = 100;
        appState.startIntervention();
        final secondSession = appState.currentSession;
        
        expect(secondSession, isNot(equals(firstSession)));
        expect(firstSession!.preScore, equals(20.0)); // 0.4 * 50
        expect(secondSession!.preScore, equals(40.0)); // 0.4 * 100
      });
    });

    group('completeIntervention', () {
      test('applies intervention effect to metrics', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 80;
        appState.metrics.nightMinutes = 60;
        
        appState.startIntervention();
        appState.completeIntervention(null);
        
        expect(appState.metrics.unlocks, equals(50));
        expect(appState.metrics.appSwitches, equals(40));
        expect(appState.metrics.nightMinutes, equals(30));
      });

      test('completes session with post score', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 0;
        
        appState.startIntervention();
        expect(appState.currentSession!.preScore, equals(80.0));
        
        appState.completeIntervention(null);
        
        expect(appState.currentSession!.postScore, equals(40.0)); // 80 * 0.5
        expect(appState.currentSession!.endTime, isNotNull);
      });

      test('records mood when provided', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        
        appState.startIntervention();
        appState.completeIntervention("happy");
        
        expect(appState.currentSession!.mood, equals("happy"));
      });

      test('handles null mood', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        
        appState.startIntervention();
        appState.completeIntervention(null);
        
        expect(appState.currentSession!.mood, isNull);
      });

      test('notifies listeners', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        var notificationCount = 0;
        
        appState.addListener(() {
          notificationCount++;
        });
        
        appState.startIntervention();
        notificationCount = 0; // Reset after startIntervention notification
        
        appState.completeIntervention(null);
        
        expect(notificationCount, equals(1));
      });

      test('updates currentScore after completion', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 0;
        
        final scoreBefore = appState.currentScore;
        expect(scoreBefore, equals(80.0));
        
        appState.startIntervention();
        appState.completeIntervention(null);
        
        final scoreAfter = appState.currentScore;
        expect(scoreAfter, equals(40.0)); // 80 * 0.5
      });

      test('handles completion without starting session', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        
        // Complete without starting - should not crash
        appState.completeIntervention("happy");
        
        // Metrics should still be reduced
        expect(appState.metrics.unlocks, equals(50));
      });
    });

    group('integration scenarios', () {
      test('complete flow: simulate -> start -> complete', () {
        final appState = AppState();
        
        // Simulate to build up overload
        for (int i = 0; i < 10; i++) {
          appState.simulateAppSwitch();
        }
        
        expect(appState.metrics.unlocks, equals(30));
        expect(appState.metrics.appSwitches, equals(20));
        expect(appState.currentScore, equals(20.0)); // (0.4*30) + (0.4*20) = 20
        
        // Start intervention
        appState.startIntervention();
        expect(appState.currentSession!.preScore, equals(20.0));
        
        // Complete intervention
        appState.completeIntervention("happy");
        
        expect(appState.metrics.unlocks, equals(15));
        expect(appState.metrics.appSwitches, equals(10));
        expect(appState.currentScore, equals(10.0)); // 20 * 0.5
        expect(appState.currentSession!.postScore, equals(10.0));
        expect(appState.currentSession!.mood, equals("happy"));
      });

      test('multiple intervention cycles', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 100;
        
        // First intervention
        appState.startIntervention();
        expect(appState.currentSession!.preScore, equals(100.0));
        appState.completeIntervention(null);
        expect(appState.currentScore, equals(50.0));
        
        // Second intervention
        appState.startIntervention();
        expect(appState.currentSession!.preScore, equals(50.0));
        appState.completeIntervention(null);
        expect(appState.currentScore, equals(25.0));
      });

      test('classification changes through intervention', () {
        final appState = AppState();
        appState.metrics.unlocks = 100;
        appState.metrics.appSwitches = 100;
        appState.metrics.nightMinutes = 0;
        
        expect(appState.classification, equals("High Overload")); // Score = 80
        
        appState.startIntervention();
        appState.completeIntervention(null);
        
        expect(appState.classification, equals("Moderate")); // Score = 40
      });
    });

    // Property-Based Test
    // **Validates: Requirements 1.5, 3.3**
    test('Property 3: Score Updates with Metrics - for any metric changes, score is recalculated', () {
      final random = Random(42);
      const iterations = 100;
      
      for (int i = 0; i < iterations; i++) {
        final appState = AppState();
        
        // Set random initial metrics
        final unlocks = random.nextInt(100);
        final appSwitches = random.nextInt(100);
        final nightMinutes = random.nextInt(100);
        
        appState.metrics.unlocks = unlocks;
        appState.metrics.appSwitches = appSwitches;
        appState.metrics.nightMinutes = nightMinutes;
        
        // Calculate expected score
        final expectedScore = (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes);
        
        // Verify currentScore reflects the metrics
        expect(
          appState.currentScore,
          closeTo(expectedScore, 0.01),
          reason: 'Score should match calculated value for metrics (u=$unlocks, a=$appSwitches, n=$nightMinutes)'
        );
        
        // Change metrics and verify score updates
        appState.metrics.unlocks += 10;
        final newExpectedScore = (0.4 * (unlocks + 10)) + (0.4 * appSwitches) + (0.2 * nightMinutes);
        
        expect(
          appState.currentScore,
          closeTo(newExpectedScore, 0.01),
          reason: 'Score should update when metrics change'
        );
      }
    });

    // Property-Based Test
    // **Validates: Requirements 6.1**
    test('Property 5: Intervention Score Reduction - for any pre-intervention score, post-score equals pre-score * 0.5', () {
      final random = Random(42);
      const iterations = 100;
      
      for (int i = 0; i < iterations; i++) {
        final appState = AppState();
        
        // Set random metrics to create various scores
        final unlocks = random.nextInt(200);
        final appSwitches = random.nextInt(200);
        final nightMinutes = random.nextInt(200);
        
        appState.metrics.unlocks = unlocks;
        appState.metrics.appSwitches = appSwitches;
        appState.metrics.nightMinutes = nightMinutes;
        
        final preScore = appState.currentScore;
        
        // Start and complete intervention
        appState.startIntervention();
        appState.completeIntervention(null);
        
        final postScore = appState.currentScore;
        
        // Calculate expected post-score based on how metrics are reduced
        // Metrics are reduced by 50% and rounded, then score is recalculated
        final expectedUnlocks = (unlocks * 0.5).round();
        final expectedAppSwitches = (appSwitches * 0.5).round();
        final expectedNightMinutes = (nightMinutes * 0.5).round();
        final expectedPostScore = (0.4 * expectedUnlocks) + (0.4 * expectedAppSwitches) + (0.2 * expectedNightMinutes);
        
        // Verify post-score matches the recalculated score from reduced metrics
        expect(
          postScore,
          closeTo(expectedPostScore, 0.01),
          reason: 'Post-intervention score should be calculated from reduced metrics (pre=$preScore, post=$postScore, expected=$expectedPostScore)'
        );
        
        // Verify post-score is approximately half of pre-score (within rounding tolerance)
        // Due to rounding of metrics, the post-score may not be exactly 50% but should be close
        expect(
          postScore,
          closeTo(preScore * 0.5, 1.0),
          reason: 'Post-intervention score should be approximately 50% of pre-intervention score (pre=$preScore, post=$postScore)'
        );
        
        // Also verify the session records match
        expect(
          appState.currentSession!.preScore,
          closeTo(preScore, 0.01),
          reason: 'Session should record correct pre-score'
        );
        
        expect(
          appState.currentSession!.postScore,
          closeTo(postScore, 0.01),
          reason: 'Session should record correct post-score'
        );
      }
    });
  });
}
