/// Core engine for computing cognitive overload scores from real device usage data
/// 
/// This engine implements the scientifically-informed formula:
/// score = (0.4 × unlocks) + (0.4 × appSwitches) + (0.2 × nightMinutes)
/// 
/// The weights are based on:
/// - Unlocks (40%): Proxy for compulsive checking behavior
/// - App switches (40%): Indicator of attention fragmentation
/// - Night usage (20%): Sleep disruption and recovery deficit
class OverloadEngine {
  // Classification thresholds (evidence-based)
  static const double calmThreshold = 30.0;
  static const double moderateThreshold = 60.0;

  // Weight coefficients for the overload formula
  static const double unlockWeight = 0.4;
  static const double appSwitchWeight = 0.4;
  static const double nightUsageWeight = 0.2;

  /// Compute cognitive overload score from usage metrics
  /// 
  /// Parameters:
  /// - unlocks: Number of device unlocks
  /// - switches: Number of app switches (foreground changes)
  /// - nightMinutes: Minutes of usage during night hours (11 PM - 6 AM)
  /// 
  /// Returns: Overload score (0-100+)
  double compute({
    required int unlocks,
    required int switches,
    required int nightMinutes,
  }) {
    // Validate inputs (prevent negative values)
    final validUnlocks = unlocks.clamp(0, double.maxFinite.toInt());
    final validSwitches = switches.clamp(0, double.maxFinite.toInt());
    final validNightMinutes = nightMinutes.clamp(0, double.maxFinite.toInt());

    // Apply weighted formula
    final score = (unlockWeight * validUnlocks) +
                  (appSwitchWeight * validSwitches) +
                  (nightUsageWeight * validNightMinutes);

    return score;
  }

  /// Classify overload level based on score
  /// 
  /// Returns: "Calm", "Moderate", or "High Overload"
  String classify(double score) {
    if (score < calmThreshold) {
      return 'Calm';
    } else if (score <= moderateThreshold) {
      return 'Moderate';
    } else {
      return 'High Overload';
    }
  }

  /// Check if intervention should be triggered
  /// 
  /// Returns: true if score exceeds moderate threshold
  bool shouldTriggerIntervention(double score) {
    return score > moderateThreshold;
  }

  /// Compute overload score from usage data map
  /// 
  /// Convenience method that extracts metrics from collected usage data
  double computeFromUsageData(Map<String, dynamic> usageData) {
    final unlocks = usageData['unlockCount'] as int? ?? 0;
    final switches = usageData['appSwitches'] as int? ?? 0;
    final nightMinutes = usageData['nightUsageMinutes'] as int? ?? 0;

    return compute(
      unlocks: unlocks,
      switches: switches,
      nightMinutes: nightMinutes,
    );
  }

  /// Get detailed overload analysis
  /// 
  /// Returns a map with score, classification, and breakdown
  Map<String, dynamic> analyze({
    required int unlocks,
    required int switches,
    required int nightMinutes,
  }) {
    final score = compute(
      unlocks: unlocks,
      switches: switches,
      nightMinutes: nightMinutes,
    );

    final classification = classify(score);
    final shouldIntervene = shouldTriggerIntervention(score);

    // Calculate contribution of each metric
    final unlockContribution = unlockWeight * unlocks;
    final switchContribution = appSwitchWeight * switches;
    final nightContribution = nightUsageWeight * nightMinutes;

    return {
      'score': score,
      'classification': classification,
      'shouldIntervene': shouldIntervene,
      'breakdown': {
        'unlocks': {
          'value': unlocks,
          'contribution': unlockContribution,
          'percentage': (unlockContribution / score * 100).toStringAsFixed(1),
        },
        'appSwitches': {
          'value': switches,
          'contribution': switchContribution,
          'percentage': (switchContribution / score * 100).toStringAsFixed(1),
        },
        'nightUsage': {
          'value': nightMinutes,
          'contribution': nightContribution,
          'percentage': (nightContribution / score * 100).toStringAsFixed(1),
        },
      },
      'analyzedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get risk level (0-1 normalized score)
  /// 
  /// Useful for visualizations and comparisons
  double getRiskLevel(double score) {
    // Normalize to 0-1 range (assuming max reasonable score is 150)
    const maxScore = 150.0;
    return (score / maxScore).clamp(0.0, 1.0);
  }

  /// Get color code for visualization
  /// 
  /// Returns hex color string based on classification
  String getColorCode(double score) {
    final classification = classify(score);
    switch (classification) {
      case 'Calm':
        return '#7FB069'; // Green
      case 'Moderate':
        return '#F4A261'; // Yellow/Orange
      case 'High Overload':
        return '#E76F51'; // Red
      default:
        return '#6C757D'; // Gray (fallback)
    }
  }
}
