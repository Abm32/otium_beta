import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otium/logic/overload_calculator.dart';

void main() {
  group('OverloadCalculator', () {
    group('calculateScore', () {
      test('calculates score with zero values', () {
        final score = OverloadCalculator.calculateScore(0, 0, 0);
        expect(score, equals(0.0));
      });

      test('calculates score with formula: (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes)', () {
        // Test case 1: unlocks=10, appSwitches=5, nightMinutes=20
        // Expected: (0.4 * 10) + (0.4 * 5) + (0.2 * 20) = 4 + 2 + 4 = 10
        final score1 = OverloadCalculator.calculateScore(10, 5, 20);
        expect(score1, equals(10.0));

        // Test case 2: unlocks=50, appSwitches=30, nightMinutes=100
        // Expected: (0.4 * 50) + (0.4 * 30) + (0.2 * 100) = 20 + 12 + 20 = 52
        final score2 = OverloadCalculator.calculateScore(50, 30, 100);
        expect(score2, equals(52.0));

        // Test case 3: unlocks=100, appSwitches=100, nightMinutes=50
        // Expected: (0.4 * 100) + (0.4 * 100) + (0.2 * 50) = 40 + 40 + 10 = 90
        final score3 = OverloadCalculator.calculateScore(100, 100, 50);
        expect(score3, equals(90.0));
      });

      test('handles negative inputs by clamping to 0', () {
        final score = OverloadCalculator.calculateScore(-10, -5, -20);
        expect(score, equals(0.0));
      });

      test('handles mixed negative and positive inputs', () {
        // unlocks=-10 (clamped to 0), appSwitches=10, nightMinutes=20
        // Expected: (0.4 * 0) + (0.4 * 10) + (0.2 * 20) = 0 + 4 + 4 = 8
        final score = OverloadCalculator.calculateScore(-10, 10, 20);
        expect(score, equals(8.0));
      });

      test('calculates score at threshold boundary (30)', () {
        // To get score of 30: (0.4 * 50) + (0.4 * 25) + (0.2 * 0) = 20 + 10 + 0 = 30
        final score = OverloadCalculator.calculateScore(50, 25, 0);
        expect(score, equals(30.0));
      });

      test('calculates score at threshold boundary (60)', () {
        // To get score of 60: (0.4 * 100) + (0.4 * 50) + (0.2 * 0) = 40 + 20 + 0 = 60
        final score = OverloadCalculator.calculateScore(100, 50, 0);
        expect(score, equals(60.0));
      });

      // Property-Based Test
      // **Validates: Requirements 1.1**
      test('Property 1: Score Calculation Correctness - for any set of metric values, score equals formula', () {
        final random = Random(42); // Use seed for reproducibility
        const iterations = 100;
        
        for (int i = 0; i < iterations; i++) {
          // Generate random metric values (0-200 range to test various scenarios)
          final unlocks = random.nextInt(200);
          final appSwitches = random.nextInt(200);
          final nightMinutes = random.nextInt(200);
          
          // Calculate score using the implementation
          final actualScore = OverloadCalculator.calculateScore(
            unlocks, 
            appSwitches, 
            nightMinutes
          );
          
          // Calculate expected score using the formula
          final expectedScore = (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes);
          
          // Verify the score matches the formula (with small tolerance for floating point)
          expect(
            actualScore, 
            closeTo(expectedScore, 0.001),
            reason: 'Failed for unlocks=$unlocks, appSwitches=$appSwitches, nightMinutes=$nightMinutes'
          );
        }
      });
    });

    group('getClassification', () {
      test('returns "Calm" for score less than 30', () {
        expect(OverloadCalculator.getClassification(0), equals("Calm"));
        expect(OverloadCalculator.getClassification(15), equals("Calm"));
        expect(OverloadCalculator.getClassification(29.9), equals("Calm"));
      });

      test('returns "Moderate" for score between 30 and 60 (inclusive)', () {
        expect(OverloadCalculator.getClassification(30), equals("Moderate"));
        expect(OverloadCalculator.getClassification(45), equals("Moderate"));
        expect(OverloadCalculator.getClassification(60), equals("Moderate"));
      });

      test('returns "High Overload" for score greater than 60', () {
        expect(OverloadCalculator.getClassification(60.1), equals("High Overload"));
        expect(OverloadCalculator.getClassification(75), equals("High Overload"));
        expect(OverloadCalculator.getClassification(100), equals("High Overload"));
        expect(OverloadCalculator.getClassification(150), equals("High Overload"));
      });

      test('handles exact threshold boundaries', () {
        expect(OverloadCalculator.getClassification(29.99), equals("Calm"));
        expect(OverloadCalculator.getClassification(30.0), equals("Moderate"));
        expect(OverloadCalculator.getClassification(60.0), equals("Moderate"));
        expect(OverloadCalculator.getClassification(60.01), equals("High Overload"));
      });

      // Property-Based Test
      // **Validates: Requirements 1.2, 1.3, 1.4**
      test('Property 2: Classification Correctness - for any score, classification matches threshold rules', () {
        final random = Random(42); // Use seed for reproducibility
        const iterations = 100;
        
        for (int i = 0; i < iterations; i++) {
          // Generate random score values across a wide range (0-200)
          // This tests beyond typical ranges to ensure robustness
          final score = random.nextDouble() * 200;
          
          // Get the classification from the implementation
          final classification = OverloadCalculator.getClassification(score);
          
          // Verify classification matches the expected threshold rules
          if (score < 30) {
            expect(
              classification, 
              equals("Calm"),
              reason: 'Score $score should be classified as "Calm" (< 30)'
            );
          } else if (score <= 60) {
            expect(
              classification, 
              equals("Moderate"),
              reason: 'Score $score should be classified as "Moderate" (30-60)'
            );
          } else {
            expect(
              classification, 
              equals("High Overload"),
              reason: 'Score $score should be classified as "High Overload" (> 60)'
            );
          }
        }
      });
    });

    group('getScoreColor', () {
      test('returns green for Calm scores (< 30)', () {
        expect(OverloadCalculator.getScoreColor(0), equals(Colors.green));
        expect(OverloadCalculator.getScoreColor(15), equals(Colors.green));
        expect(OverloadCalculator.getScoreColor(29.9), equals(Colors.green));
      });

      test('returns orange for Moderate scores (30-60)', () {
        expect(OverloadCalculator.getScoreColor(30), equals(Colors.orange));
        expect(OverloadCalculator.getScoreColor(45), equals(Colors.orange));
        expect(OverloadCalculator.getScoreColor(60), equals(Colors.orange));
      });

      test('returns red for High Overload scores (> 60)', () {
        expect(OverloadCalculator.getScoreColor(60.1), equals(Colors.red));
        expect(OverloadCalculator.getScoreColor(75), equals(Colors.red));
        expect(OverloadCalculator.getScoreColor(100), equals(Colors.red));
      });

      test('handles exact threshold boundaries', () {
        expect(OverloadCalculator.getScoreColor(29.99), equals(Colors.green));
        expect(OverloadCalculator.getScoreColor(30.0), equals(Colors.orange));
        expect(OverloadCalculator.getScoreColor(60.0), equals(Colors.orange));
        expect(OverloadCalculator.getScoreColor(60.01), equals(Colors.red));
      });
    });
  });
}
