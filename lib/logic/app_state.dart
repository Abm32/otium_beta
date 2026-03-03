import 'package:flutter/foundation.dart';
import 'cognitive_metrics.dart';
import 'intervention_session.dart';
import 'overload_calculator.dart';
import '../core/services/real_sensing_service.dart';
import '../core/services/real_sensing_service.dart';

/// Central state management class for the Otium app.
///
/// This class extends ChangeNotifier to provide reactive state updates
/// throughout the app. It manages cognitive metrics, intervention sessions,
/// and provides computed properties for the current overload score and classification.
///
/// Phase 1 Update: Added real sensing capabilities with toggle between
/// simulated and real device usage data collection.
///
/// Requirements: 10.1, 10.2, 10.3, 10.4
class AppState extends ChangeNotifier {
  /// Current cognitive metrics (unlocks, app switches, night minutes)
  CognitiveMetrics metrics = CognitiveMetrics();

  /// Current or most recent intervention session (null if no session started)
  InterventionSession? currentSession;

  /// Real sensing service for collecting actual device usage data
  RealSensingService? _realSensingService;

  /// Whether to use real sensing (true) or simulated data (false)
  bool _useRealSensing = false;

  /// Whether background monitoring is enabled
  bool _backgroundMonitoringEnabled = false;

  /// Last time metrics were refreshed from real sensing
  DateTime? _lastRealSensingUpdate;

  /// Initialize real sensing service
  Future<void> initializeRealSensing() async {
    try {
      _realSensingService = await RealSensingService.create();
      final initialized = await _realSensingService!.initialize();
      
      if (initialized) {
        _useRealSensing = true;
        _backgroundMonitoringEnabled = _realSensingService!.isBackgroundMonitoringEnabled();
        await refreshMetricsFromRealSensing();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to initialize real sensing: $e');
      _useRealSensing = false;
      notifyListeners();
    }
  }

  /// Refresh metrics from real sensing service
  Future<void> refreshMetricsFromRealSensing() async {
    if (_realSensingService == null || !_useRealSensing) return;

    try {
      final realMetrics = await _realSensingService!.getCurrentMetrics();
      
      // Update metrics with real data
      metrics.unlocks = realMetrics['unlocks'] ?? 0;
      metrics.appSwitches = realMetrics['appSwitches'] ?? 0;
      metrics.nightMinutes = realMetrics['nightMinutes'] ?? 0;
      
      _lastRealSensingUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('Failed to refresh real sensing metrics: $e');
    }
  }

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
  /// Only works in simulated mode.
  ///
  /// Requirements: 3.1, 3.2, 10.3
  void simulateAppSwitch() {
    if (!_useRealSensing) {
      metrics.simulateAppSwitch();
      notifyListeners();
    }
  }

  /// Starts a new intervention session.
  ///
  /// Creates a new InterventionSession with the current overload score
  /// as the pre-intervention baseline and notifies listeners.
  /// Records intervention in real sensing service if available.
  ///
  /// Requirements: 10.3
  void startIntervention() {
    currentSession = InterventionSession(
      preScore: currentScore,
      startTime: DateTime.now(),
    );
    
    // Record intervention in real sensing service
    _realSensingService?.recordIntervention();
    
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

  /// Toggle between real sensing and simulated mode
  void toggleSensingMode() {
    _useRealSensing = !_useRealSensing;
    
    if (_useRealSensing && _realSensingService != null) {
      refreshMetricsFromRealSensing();
    }
    
    notifyListeners();
  }

  /// Enable or disable background monitoring
  Future<void> setBackgroundMonitoring(bool enabled) async {
    if (_realSensingService != null) {
      await _realSensingService!.setBackgroundMonitoring(enabled);
      _backgroundMonitoringEnabled = enabled;
      notifyListeners();
    }
  }

  /// Get intervention statistics from real sensing service
  Future<Map<String, dynamic>?> getInterventionStats() async {
    if (_realSensingService != null) {
      return await _realSensingService!.getInterventionStats();
    }
    return null;
  }

  /// Get historical score data from real sensing service
  Future<List<Map<String, dynamic>>> getScoreHistory() async {
    if (_realSensingService != null) {
      return await _realSensingService!.getScoreHistory();
    }
    return [];
  }

  /// Check if real sensing is available
  Future<bool> isRealSensingAvailable() async {
    if (_realSensingService != null) {
      return await _realSensingService!.isAvailable();
    }
    return false;
  }

  /// Run immediate sensing check (for testing)
  Future<void> runImmediateCheck() async {
    if (_realSensingService != null) {
      await _realSensingService!.runImmediateCheck();
    }
  }

  // Getters for UI
  bool get useRealSensing => _useRealSensing;
  bool get backgroundMonitoringEnabled => _backgroundMonitoringEnabled;
  DateTime? get lastRealSensingUpdate => _lastRealSensingUpdate;
  String get sensingMode => _useRealSensing ? 'Real' : 'Simulated';
}
