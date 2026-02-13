import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:otium/logic/cognitive_metrics.dart';

void main() {
  group('CognitiveMetrics', () {
    group('constructor', () {
      test('initializes with default zero values', () {
        final metrics = CognitiveMetrics();
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
        expect(metrics.nightMinutes, equals(0));
      });

      test('initializes with provided values', () {
        final metrics = CognitiveMetrics(
          unlocks: 10,
          appSwitches: 5,
          nightMinutes: 20,
        );
        expect(metrics.unlocks, equals(10));
        expect(metrics.appSwitches, equals(5));
        expect(metrics.nightMinutes, equals(20));
      });
    });

    group('simulateAppSwitch', () {
      test('increases unlocks by 3 and appSwitches by 2 from zero state', () {
        final metrics = CognitiveMetrics();
        metrics.simulateAppSwitch();
        
        expect(metrics.unlocks, equals(3));
        expect(metrics.appSwitches, equals(2));
        expect(metrics.nightMinutes, equals(0)); // Should not change
      });

      test('increases unlocks by 3 and appSwitches by 2 from existing values', () {
        final metrics = CognitiveMetrics(
          unlocks: 10,
          appSwitches: 5,
          nightMinutes: 20,
        );
        metrics.simulateAppSwitch();
        
        expect(metrics.unlocks, equals(13)); // 10 + 3
        expect(metrics.appSwitches, equals(7)); // 5 + 2
        expect(metrics.nightMinutes, equals(20)); // Should not change
      });

      test('accumulates correctly over multiple calls', () {
        final metrics = CognitiveMetrics();
        
        metrics.simulateAppSwitch();
        expect(metrics.unlocks, equals(3));
        expect(metrics.appSwitches, equals(2));
        
        metrics.simulateAppSwitch();
        expect(metrics.unlocks, equals(6));
        expect(metrics.appSwitches, equals(4));
        
        metrics.simulateAppSwitch();
        expect(metrics.unlocks, equals(9));
        expect(metrics.appSwitches, equals(6));
      });

      // Property-Based Test
      // **Validates: Requirements 3.1, 3.2**
      test('Property 4: Simulation Increases Metrics - for any initial state, simulateAppSwitch increases unlocks by 3 and appSwitches by 2', () {
        final random = Random(42); // Use seed for reproducibility
        const iterations = 100;
        
        for (int i = 0; i < iterations; i++) {
          // Generate random initial metric values
          final initialUnlocks = random.nextInt(100);
          final initialAppSwitches = random.nextInt(100);
          final initialNightMinutes = random.nextInt(100);
          
          // Create metrics with initial values
          final metrics = CognitiveMetrics(
            unlocks: initialUnlocks,
            appSwitches: initialAppSwitches,
            nightMinutes: initialNightMinutes,
          );
          
          // Call simulateAppSwitch
          metrics.simulateAppSwitch();
          
          // Verify unlocks increased by exactly 3
          expect(
            metrics.unlocks,
            equals(initialUnlocks + 3),
            reason: 'Unlocks should increase by 3 (initial=$initialUnlocks)'
          );
          
          // Verify appSwitches increased by exactly 2
          expect(
            metrics.appSwitches,
            equals(initialAppSwitches + 2),
            reason: 'AppSwitches should increase by 2 (initial=$initialAppSwitches)'
          );
          
          // Verify nightMinutes did not change
          expect(
            metrics.nightMinutes,
            equals(initialNightMinutes),
            reason: 'NightMinutes should not change (initial=$initialNightMinutes)'
          );
        }
      });
    });

    group('applyInterventionEffect', () {
      test('reduces all metrics by 50% from zero state', () {
        final metrics = CognitiveMetrics();
        metrics.applyInterventionEffect();
        
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
        expect(metrics.nightMinutes, equals(0));
      });

      test('reduces all metrics by 50% with even values', () {
        final metrics = CognitiveMetrics(
          unlocks: 10,
          appSwitches: 20,
          nightMinutes: 30,
        );
        metrics.applyInterventionEffect();
        
        expect(metrics.unlocks, equals(5)); // 10 * 0.5 = 5
        expect(metrics.appSwitches, equals(10)); // 20 * 0.5 = 10
        expect(metrics.nightMinutes, equals(15)); // 30 * 0.5 = 15
      });

      test('rounds correctly with odd values', () {
        final metrics = CognitiveMetrics(
          unlocks: 11,
          appSwitches: 21,
          nightMinutes: 31,
        );
        metrics.applyInterventionEffect();
        
        expect(metrics.unlocks, equals(6)); // 11 * 0.5 = 5.5 -> rounds to 6
        expect(metrics.appSwitches, equals(11)); // 21 * 0.5 = 10.5 -> rounds to 11
        expect(metrics.nightMinutes, equals(16)); // 31 * 0.5 = 15.5 -> rounds to 16
      });

      test('handles large values correctly', () {
        final metrics = CognitiveMetrics(
          unlocks: 100,
          appSwitches: 150,
          nightMinutes: 200,
        );
        metrics.applyInterventionEffect();
        
        expect(metrics.unlocks, equals(50));
        expect(metrics.appSwitches, equals(75));
        expect(metrics.nightMinutes, equals(100));
      });

      // Property-Based Test
      // **Validates: Requirements 6.3**
      test('Property 6: Intervention Metrics Reduction - for any metrics, intervention reduces each to 50% (rounded)', () {
        final random = Random(42); // Use seed for reproducibility
        const iterations = 100;
        
        for (int i = 0; i < iterations; i++) {
          // Generate random metric values
          final initialUnlocks = random.nextInt(200);
          final initialAppSwitches = random.nextInt(200);
          final initialNightMinutes = random.nextInt(200);
          
          // Create metrics with initial values
          final metrics = CognitiveMetrics(
            unlocks: initialUnlocks,
            appSwitches: initialAppSwitches,
            nightMinutes: initialNightMinutes,
          );
          
          // Apply intervention effect
          metrics.applyInterventionEffect();
          
          // Calculate expected values (50% reduction, rounded)
          final expectedUnlocks = (initialUnlocks * 0.5).round();
          final expectedAppSwitches = (initialAppSwitches * 0.5).round();
          final expectedNightMinutes = (initialNightMinutes * 0.5).round();
          
          // Verify each metric is reduced to 50% (rounded)
          expect(
            metrics.unlocks,
            equals(expectedUnlocks),
            reason: 'Unlocks should be reduced to 50% rounded (initial=$initialUnlocks, expected=$expectedUnlocks)'
          );
          
          expect(
            metrics.appSwitches,
            equals(expectedAppSwitches),
            reason: 'AppSwitches should be reduced to 50% rounded (initial=$initialAppSwitches, expected=$expectedAppSwitches)'
          );
          
          expect(
            metrics.nightMinutes,
            equals(expectedNightMinutes),
            reason: 'NightMinutes should be reduced to 50% rounded (initial=$initialNightMinutes, expected=$expectedNightMinutes)'
          );
        }
      });
    });

    group('reset', () {
      test('resets all metrics to zero from non-zero values', () {
        final metrics = CognitiveMetrics(
          unlocks: 50,
          appSwitches: 30,
          nightMinutes: 100,
        );
        metrics.reset();
        
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
        expect(metrics.nightMinutes, equals(0));
      });

      test('resets all metrics to zero from already zero values', () {
        final metrics = CognitiveMetrics();
        metrics.reset();
        
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
        expect(metrics.nightMinutes, equals(0));
      });

      test('resets after simulation', () {
        final metrics = CognitiveMetrics();
        metrics.simulateAppSwitch();
        metrics.simulateAppSwitch();
        
        expect(metrics.unlocks, equals(6));
        expect(metrics.appSwitches, equals(4));
        
        metrics.reset();
        
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
        expect(metrics.nightMinutes, equals(0));
      });

      test('resets after intervention', () {
        final metrics = CognitiveMetrics(
          unlocks: 100,
          appSwitches: 80,
          nightMinutes: 60,
        );
        metrics.applyInterventionEffect();
        
        expect(metrics.unlocks, equals(50));
        expect(metrics.appSwitches, equals(40));
        expect(metrics.nightMinutes, equals(30));
        
        metrics.reset();
        
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
        expect(metrics.nightMinutes, equals(0));
      });
    });

    group('integration scenarios', () {
      test('complete simulation and intervention cycle', () {
        final metrics = CognitiveMetrics();
        
        // Simulate multiple app switches
        metrics.simulateAppSwitch();
        metrics.simulateAppSwitch();
        metrics.simulateAppSwitch();
        
        expect(metrics.unlocks, equals(9));
        expect(metrics.appSwitches, equals(6));
        
        // Apply intervention
        metrics.applyInterventionEffect();
        
        expect(metrics.unlocks, equals(5)); // 9 * 0.5 = 4.5 -> rounds to 5
        expect(metrics.appSwitches, equals(3)); // 6 * 0.5 = 3
        
        // Reset for new session
        metrics.reset();
        
        expect(metrics.unlocks, equals(0));
        expect(metrics.appSwitches, equals(0));
      });

      test('multiple intervention cycles', () {
        final metrics = CognitiveMetrics(
          unlocks: 100,
          appSwitches: 100,
          nightMinutes: 100,
        );
        
        // First intervention
        metrics.applyInterventionEffect();
        expect(metrics.unlocks, equals(50));
        expect(metrics.appSwitches, equals(50));
        expect(metrics.nightMinutes, equals(50));
        
        // Second intervention
        metrics.applyInterventionEffect();
        expect(metrics.unlocks, equals(25));
        expect(metrics.appSwitches, equals(25));
        expect(metrics.nightMinutes, equals(25));
        
        // Third intervention
        metrics.applyInterventionEffect();
        expect(metrics.unlocks, equals(13)); // 25 * 0.5 = 12.5 -> rounds to 13
        expect(metrics.appSwitches, equals(13));
        expect(metrics.nightMinutes, equals(13));
      });
    });
  });
}
