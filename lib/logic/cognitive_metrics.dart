/// Model class for storing and managing cognitive overload usage metrics.
///
/// This class tracks three key metrics:
/// - unlocks: Number of device unlocks
/// - appSwitches: Number of app context switches
/// - nightMinutes: Minutes of device usage during night hours
class CognitiveMetrics {
  /// Number of device unlocks
  int unlocks;

  /// Number of app context switches
  int appSwitches;

  /// Minutes of device usage during night hours
  int nightMinutes;

  /// Creates a new CognitiveMetrics instance with optional initial values.
  ///
  /// All metrics default to 0 if not specified.
  CognitiveMetrics({
    this.unlocks = 0,
    this.appSwitches = 0,
    this.nightMinutes = 0,
  });

  /// Simulates an app switching event for demo purposes.
  ///
  /// Increases unlocks by 3 and appSwitches by 2 to demonstrate
  /// cognitive overload accumulation.
  ///
  /// Requirements: 3.1, 3.2
  void simulateAppSwitch() {
    unlocks += 3;
    appSwitches += 2;
  }

  /// Applies the intervention effect by reducing all metrics by 50%.
  ///
  /// This simulates the positive impact of the breathing intervention
  /// on cognitive overload metrics. All values are rounded to the nearest integer.
  ///
  /// Requirements: 6.3
  void applyInterventionEffect() {
    unlocks = (unlocks * 0.5).round();
    appSwitches = (appSwitches * 0.5).round();
    nightMinutes = (nightMinutes * 0.5).round();
  }

  /// Resets all metrics to zero.
  ///
  /// Used to clear the current session and start fresh.
  void reset() {
    unlocks = 0;
    appSwitches = 0;
    nightMinutes = 0;
  }
}
