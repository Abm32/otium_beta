import 'package:flutter/foundation.dart';
import 'cognitive_metrics.dart';
import 'intervention_session.dart';
import 'overload_calculator.dart';

/// Central state management class for the Otium app.
///
/// This class extends ChangeNotifier to provide reactive state updates
/// throughout the app. It manages cognitive metrics, intervention sessions,
/// and provides computed properties for the current overload score and classification.
///
/// Requirements: 10.1, 10.2, 10.3, 10.4
class AppState extends ChangeNotifier {
  /// Current cognitive metrics (unlocks, app switches, night minutes)
  CognitiveMetrics metrics = CognitiveMetrics();

  /// Current or most recent intervention session (null if no session started)
  InterventionSession? currentSession;

  /// Calculates and returns the current overload score based on metrics.
  ///
  /// This getter dynamically calculates the score using the OverloadCalculator
  /// whenever it's accessed, ensuring the score is always up-to-date with
  /// the current metrics.
  ///
  /// Returns: A double representing the current overload score
  ///
  /// Requirements: 10.2
  double get currentScore {
    return OverloadCalculator.calculateScore(
      metrics.unlocks,
      metrics.appSwitches,
      metrics.nightMinutes,
    );
  }

  /// Gets the classification string for the current overload score.
  ///
  /// Returns one of: "Calm", "Moderate", or "High Overload"
  ///
  /// Requirements: 10.2
  String get classification {
    return OverloadCalculator.getClassification(currentScore);
  }

  /// Simulates an app switching event for demo purposes.
  ///
  /// This method increases the metrics (unlocks +3, appSwitches +2) and
  /// notifies all listeners to update the UI.
  ///
  /// Requirements: 3.1, 3.2, 10.3
  void simulateAppSwitch() {
    metrics.simulateAppSwitch();
    notifyListeners();
  }

  /// Starts a new intervention session.
  ///
  /// Creates a new InterventionSession with the current overload score
  /// as the pre-intervention baseline and notifies listeners.
  ///
  /// Requirements: 10.3
  void startIntervention() {
    currentSession = InterventionSession(
      preScore: currentScore,
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Completes the current intervention session.
  ///
  /// Applies the intervention effect to metrics (reduces by 50%),
  /// completes the session with the new score and optional mood,
  /// and notifies listeners.
  ///
  /// Parameters:
  /// - [mood]: Optional user-selected mood after intervention
  ///
  /// Requirements: 6.1, 6.3, 10.4
  void completeIntervention(String? mood) {
    metrics.applyInterventionEffect();
    currentSession?.complete(currentScore, mood);
    notifyListeners();
  }

  /// Updates the mood for the current intervention session.
  ///
  /// Parameters:
  /// - [mood]: The selected mood value
  ///
  /// Requirements: 7.6, 10.4
  void updateSessionMood(String mood) {
    if (currentSession != null) {
      currentSession!.mood = mood;
      notifyListeners();
    }
  }
}
