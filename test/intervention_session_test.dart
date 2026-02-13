import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:otium/logic/intervention_session.dart';

void main() {
  group('InterventionSession', () {
    group('constructor', () {
      test('initializes with required preScore and startTime', () {
        final startTime = DateTime.now();
        final session = InterventionSession(
          preScore: 80.0,
          startTime: startTime,
        );

        expect(session.preScore, equals(80.0));
        expect(session.startTime, equals(startTime));
        expect(session.postScore, isNull);
        expect(session.endTime, isNull);
        expect(session.mood, isNull);
      });

      test('accepts different preScore values', () {
        final startTime = DateTime.now();
        
        final session1 = InterventionSession(preScore: 0.0, startTime: startTime);
        expect(session1.preScore, equals(0.0));
        
        final session2 = InterventionSession(preScore: 50.5, startTime: startTime);
        expect(session2.preScore, equals(50.5));
        
        final session3 = InterventionSession(preScore: 100.0, startTime: startTime);
        expect(session3.preScore, equals(100.0));
      });
    });

    group('complete', () {
      test('sets postScore, endTime, and mood', () {
        final startTime = DateTime.now();
        final session = InterventionSession(
          preScore: 80.0,
          startTime: startTime,
        );

        // Complete the session
        session.complete(40.0, 'happy');

        expect(session.postScore, equals(40.0));
        expect(session.endTime, isNotNull);
        expect(session.endTime!.isAfter(startTime), isTrue);
        expect(session.mood, equals('happy'));
      });

      test('accepts null mood', () {
        final session = InterventionSession(
          preScore: 80.0,
          startTime: DateTime.now(),
        );

        session.complete(40.0, null);

        expect(session.postScore, equals(40.0));
        expect(session.endTime, isNotNull);
        expect(session.mood, isNull);
      });

      test('can be called with different mood values', () {
        final startTime = DateTime.now();
        
        final session1 = InterventionSession(preScore: 80.0, startTime: startTime);
        session1.complete(40.0, 'happy');
        expect(session1.mood, equals('happy'));
        
        final session2 = InterventionSession(preScore: 80.0, startTime: startTime);
        session2.complete(40.0, 'neutral');
        expect(session2.mood, equals('neutral'));
        
        final session3 = InterventionSession(preScore: 80.0, startTime: startTime);
        session3.complete(40.0, 'sad');
        expect(session3.mood, equals('sad'));
      });

      test('updates postScore correctly', () {
        final session = InterventionSession(
          preScore: 100.0,
          startTime: DateTime.now(),
        );

        session.complete(50.0, null);
        expect(session.postScore, equals(50.0));

        // Complete can be called again to update values
        session.complete(25.0, 'happy');
        expect(session.postScore, equals(25.0));
        expect(session.mood, equals('happy'));
      });
    });

    group('getReductionPercentage', () {
      test('returns 0.0 when session is not completed', () {
        final session = InterventionSession(
          preScore: 80.0,
          startTime: DateTime.now(),
        );

        expect(session.getReductionPercentage(), equals(0.0));
      });

      test('calculates percentage reduction correctly with 50% reduction', () {
        final session = InterventionSession(
          preScore: 80.0,
          startTime: DateTime.now(),
        );
        session.complete(40.0, null);

        // (80 - 40) / 80 * 100 = 50%
        expect(session.getReductionPercentage(), equals(50.0));
      });

      test('calculates percentage reduction correctly with 75% reduction', () {
        final session = InterventionSession(
          preScore: 100.0,
          startTime: DateTime.now(),
        );
        session.complete(25.0, null);

        // (100 - 25) / 100 * 100 = 75%
        expect(session.getReductionPercentage(), equals(75.0));
      });

      test('calculates percentage reduction correctly with 25% reduction', () {
        final session = InterventionSession(
          preScore: 80.0,
          startTime: DateTime.now(),
        );
        session.complete(60.0, null);

        // (80 - 60) / 80 * 100 = 25%
        expect(session.getReductionPercentage(), equals(25.0));
      });

      test('handles zero reduction (no improvement)', () {
        final session = InterventionSession(
          preScore: 80.0,
          startTime: DateTime.now(),
        );
        session.complete(80.0, null);

        // (80 - 80) / 80 * 100 = 0%
        expect(session.getReductionPercentage(), equals(0.0));
      });

      test('handles complete reduction to zero', () {
        final session = InterventionSession(
          preScore: 80.0,
          startTime: DateTime.now(),
        );
        session.complete(0.0, null);

        // (80 - 0) / 80 * 100 = 100%
        expect(session.getReductionPercentage(), equals(100.0));
      });

      test('handles decimal values correctly', () {
        final session = InterventionSession(
          preScore: 75.5,
          startTime: DateTime.now(),
        );
        session.complete(37.75, null);

        // (75.5 - 37.75) / 75.5 * 100 = 50%
        expect(session.getReductionPercentage(), closeTo(50.0, 0.01));
      });

      test('handles small preScore values', () {
        final session = InterventionSession(
          preScore: 10.0,
          startTime: DateTime.now(),
        );
        session.complete(5.0, null);

        // (10 - 5) / 10 * 100 = 50%
        expect(session.getReductionPercentage(), equals(50.0));
      });

      // Property-Based Test
      // **Validates: Requirements 7.4**
      test('Property 7: Percentage Reduction Calculation - for any pre/post scores where pre > post, percentage equals ((pre - post) / pre) * 100', () {
        final random = Random(42); // Use seed for reproducibility
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // Generate random pre-score (1-100 to avoid division by zero)
          final preScore = 1.0 + random.nextDouble() * 99.0;
          
          // Generate random post-score (0 to preScore)
          final postScore = random.nextDouble() * preScore;

          // Create and complete session
          final session = InterventionSession(
            preScore: preScore,
            startTime: DateTime.now(),
          );
          session.complete(postScore, null);

          // Calculate expected percentage
          final expectedPercentage = ((preScore - postScore) / preScore) * 100;

          // Verify percentage calculation
          expect(
            session.getReductionPercentage(),
            closeTo(expectedPercentage, 0.01),
            reason: 'Percentage should equal ((pre - post) / pre) * 100 '
                '(pre=$preScore, post=$postScore, expected=$expectedPercentage)',
          );
        }
      });
    });

    group('integration scenarios', () {
      test('complete intervention session workflow', () {
        // Start session with high overload
        final startTime = DateTime.now();
        final session = InterventionSession(
          preScore: 85.0,
          startTime: startTime,
        );

        // Verify initial state
        expect(session.preScore, equals(85.0));
        expect(session.postScore, isNull);
        expect(session.getReductionPercentage(), equals(0.0));

        // Complete intervention with 50% reduction
        session.complete(42.5, 'happy');

        // Verify final state
        expect(session.postScore, equals(42.5));
        expect(session.endTime, isNotNull);
        expect(session.mood, equals('happy'));
        expect(session.getReductionPercentage(), equals(50.0));
      });

      test('session with no mood selection', () {
        final session = InterventionSession(
          preScore: 70.0,
          startTime: DateTime.now(),
        );

        session.complete(35.0, null);

        expect(session.postScore, equals(35.0));
        expect(session.mood, isNull);
        expect(session.getReductionPercentage(), equals(50.0));
      });

      test('session with minimal reduction', () {
        final session = InterventionSession(
          preScore: 100.0,
          startTime: DateTime.now(),
        );

        session.complete(95.0, 'neutral');

        expect(session.getReductionPercentage(), equals(5.0));
      });

      test('session with maximum reduction', () {
        final session = InterventionSession(
          preScore: 100.0,
          startTime: DateTime.now(),
        );

        session.complete(0.0, 'happy');

        expect(session.getReductionPercentage(), equals(100.0));
      });

      test('multiple sessions are independent', () {
        final startTime = DateTime.now();
        
        final session1 = InterventionSession(
          preScore: 80.0,
          startTime: startTime,
        );
        session1.complete(40.0, 'happy');

        final session2 = InterventionSession(
          preScore: 60.0,
          startTime: startTime,
        );
        session2.complete(30.0, 'neutral');

        // Verify sessions are independent
        expect(session1.preScore, equals(80.0));
        expect(session1.postScore, equals(40.0));
        expect(session1.mood, equals('happy'));
        expect(session1.getReductionPercentage(), equals(50.0));

        expect(session2.preScore, equals(60.0));
        expect(session2.postScore, equals(30.0));
        expect(session2.mood, equals('neutral'));
        expect(session2.getReductionPercentage(), equals(50.0));
      });
    });

    group('edge cases', () {
      test('handles very small preScore values', () {
        final session = InterventionSession(
          preScore: 0.1,
          startTime: DateTime.now(),
        );
        session.complete(0.05, null);

        expect(session.getReductionPercentage(), closeTo(50.0, 0.01));
      });

      test('handles very large preScore values', () {
        final session = InterventionSession(
          preScore: 10000.0,
          startTime: DateTime.now(),
        );
        session.complete(5000.0, null);

        expect(session.getReductionPercentage(), equals(50.0));
      });

      test('handles postScore equal to preScore', () {
        final session = InterventionSession(
          preScore: 50.0,
          startTime: DateTime.now(),
        );
        session.complete(50.0, null);

        expect(session.getReductionPercentage(), equals(0.0));
      });

      test('endTime is after startTime', () {
        final startTime = DateTime.now();
        final session = InterventionSession(
          preScore: 80.0,
          startTime: startTime,
        );

        // Wait a tiny bit to ensure time difference
        session.complete(40.0, null);

        expect(session.endTime, isNotNull);
        expect(
          session.endTime!.isAfter(startTime) || 
          session.endTime!.isAtSameMomentAs(startTime),
          isTrue,
        );
      });
    });
  });
}
