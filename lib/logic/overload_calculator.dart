import 'package:flutter/material.dart';

/// Calculator for cognitive overload scores based on usage metrics.
///
/// This class provides methods to calculate overload scores from usage metrics,
/// classify the overload level, and provide visual feedback colors.
class OverloadCalculator {
  /// Calculates the cognitive overload score from usage metrics.
  ///
  /// Formula: (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes)
  ///
  /// Parameters:
  /// - [unlocks]: Number of device unlocks
  /// - [appSwitches]: Number of app switches
  /// - [nightMinutes]: Minutes of usage during night hours
  ///
  /// Returns: A double representing the overload score (typically 0-100 range)
  ///
  /// Validates: Requirements 1.1
  static double calculateScore(int unlocks, int appSwitches, int nightMinutes) {
    // Clamp negative values to 0 for safety
    final safeUnlocks = unlocks < 0 ? 0 : unlocks;
    final safeAppSwitches = appSwitches < 0 ? 0 : appSwitches;
    final safeNightMinutes = nightMinutes < 0 ? 0 : nightMinutes;
    
    final score = (0.4 * safeUnlocks) + (0.4 * safeAppSwitches) + (0.2 * safeNightMinutes);
    
    // Ensure score is never negative
    return score < 0 ? 0 : score;
  }

  /// Gets the classification string based on the overload score.
  ///
  /// Classification thresholds:
  /// - score < 30: "Calm"
  /// - 30 <= score <= 60: "Moderate"
  /// - score > 60: "High Overload"
  ///
  /// Parameters:
  /// - [score]: The overload score to classify
  ///
  /// Returns: A string classification ("Calm", "Moderate", or "High Overload")
  ///
  /// Validates: Requirements 1.2, 1.3, 1.4
  static String getClassification(double score) {
    if (score < 30) {
      return "Calm";
    } else if (score <= 60) {
      return "Moderate";
    } else {
      return "High Overload";
    }
  }

  /// Gets the color for visual representation based on the overload score.
  ///
  /// Color mapping:
  /// - Calm (< 30): Green
  /// - Moderate (30-60): Orange/Yellow
  /// - High Overload (> 60): Red
  ///
  /// Parameters:
  /// - [score]: The overload score to get color for
  ///
  /// Returns: A Color object for visual feedback
  ///
  /// Validates: Requirements 9.3
  static Color getScoreColor(double score) {
    if (score < 30) {
      return Colors.green;
    } else if (score <= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
