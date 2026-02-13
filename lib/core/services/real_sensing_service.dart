import 'package:shared_preferences/shared_preferences.dart';
import '../phenotyping/usage_collector.dart';
import '../phenotyping/overload_engine.dart';
import '../phenotyping/intervention_trigger.dart';
import '../background/background_monitor.dart';

/// Service layer that bridges real sensing with the existing app
/// 
/// This service provides:
/// - Real-time usage data collection
/// - Overload score computation from real metrics
/// - Background monitoring management
/// - Historical data access
class RealSensingService {
  final UsageCollector _collector;
  final OverloadEngine _engine;
  final InterventionTrigger _trigger;
  final SharedPreferences _prefs;

  RealSensingService({
    required UsageCollector collector,
    required OverloadEngine engine,
    required InterventionTrigger trigger,
    required SharedPreferences prefs,
  })  : _collector = collector,
        _engine = engine,
        _trigger = trigger,
        _prefs = prefs;

  /// Factory constructor to create service with dependencies
  static Future<RealSensingService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return RealSensingService(
      collector: UsageCollector(),
      engine: OverloadEngine(),
      trigger: await InterventionTrigger.create(),
      prefs: prefs,
    );
  }

  /// Initialize real sensing (request permissions, start background monitoring)
  Future<bool> initialize() async {
    // Request usage stats permission
    final hasPermission = await _collector.requestPermissions();
    if (!hasPermission) {
      return false;
    }

    // Initialize background monitoring
    await BackgroundMonitor.initialize();
    await BackgroundMonitor.registerPeriodicMonitoring();

    return true;
  }

  /// Get current overload metrics from real device usage
  Future<Map<String, dynamic>> getCurrentMetrics() async {
    // Try to get latest metrics from background monitoring first
    final latestScore = _prefs.getDouble('latest_overload_score');
    final latestUpdate = _prefs.getString('latest_update');

    if (latestScore != null && latestUpdate != null) {
      final updateTime = DateTime.parse(latestUpdate);
      final age = DateTime.now().difference(updateTime);

      // If metrics are recent (< 30 minutes), use cached data
      if (age.inMinutes < 30) {
        return {
          'score': latestScore,
          'classification': _prefs.getString('latest_classification') ?? 'Unknown',
          'unlocks': _prefs.getInt('latest_unlocks') ?? 0,
          'appSwitches': _prefs.getInt('latest_app_switches') ?? 0,
          'nightMinutes': _prefs.getInt('latest_night_minutes') ?? 0,
          'source': 'cached',
          'age': age.inMinutes,
        };
      }
    }

    // Otherwise, collect fresh data
    return await collectFreshMetrics();
  }

  /// Collect fresh metrics from device
  Future<Map<String, dynamic>> collectFreshMetrics() async {
    // Collect usage data for today
    final usageData = await _collector.collectToday();

    // Compute overload score
    final score = _engine.computeFromUsageData(usageData);
    final classification = _engine.classify(score);

    // Store in cache
    await _prefs.setDouble('latest_overload_score', score);
    await _prefs.setString('latest_classification', classification);
    await _prefs.setString('latest_update', DateTime.now().toIso8601String());
    await _prefs.setInt('latest_unlocks', usageData['unlockCount'] ?? 0);
    await _prefs.setInt('latest_app_switches', usageData['appSwitches'] ?? 0);
    await _prefs.setInt('latest_night_minutes', usageData['nightUsageMinutes'] ?? 0);

    return {
      'score': score,
      'classification': classification,
      'unlocks': usageData['unlockCount'] ?? 0,
      'appSwitches': usageData['appSwitches'] ?? 0,
      'nightMinutes': usageData['nightUsageMinutes'] ?? 0,
      'topApps': usageData['topApps'] ?? [],
      'source': 'fresh',
      'age': 0,
    };
  }

  /// Check if intervention should be triggered
  Future<bool> shouldTriggerIntervention(double score) async {
    return await _trigger.shouldTrigger(
      overloadScore: score,
      threshold: OverloadEngine.moderateThreshold,
    );
  }

  /// Record intervention completion
  Future<void> recordIntervention() async {
    await _trigger.recordIntervention();
  }

  /// Get intervention statistics
  Future<Map<String, dynamic>> getInterventionStats() async {
    return await _trigger.getTodayStats();
  }

  /// Get historical overload scores
  Future<List<Map<String, dynamic>>> getScoreHistory() async {
    final history = _prefs.getStringList('score_history') ?? [];
    
    return history.map((entry) {
      final parts = entry.split('|');
      if (parts.length >= 3) {
        return {
          'timestamp': parts[0],
          'score': double.tryParse(parts[1]) ?? 0.0,
          'classification': parts[2],
        };
      }
      return <String, dynamic>{};
    }).toList();
  }

  /// Get detailed analysis of current overload
  Future<Map<String, dynamic>> getDetailedAnalysis() async {
    final metrics = await getCurrentMetrics();
    
    return _engine.analyze(
      unlocks: metrics['unlocks'] ?? 0,
      switches: metrics['appSwitches'] ?? 0,
      nightMinutes: metrics['nightMinutes'] ?? 0,
    );
  }

  /// Enable/disable background monitoring
  Future<void> setBackgroundMonitoring(bool enabled) async {
    if (enabled) {
      await BackgroundMonitor.registerPeriodicMonitoring();
    } else {
      await BackgroundMonitor.cancelMonitoring();
    }
    await _prefs.setBool('background_monitoring_enabled', enabled);
  }

  /// Check if background monitoring is enabled
  bool isBackgroundMonitoringEnabled() {
    return _prefs.getBool('background_monitoring_enabled') ?? false;
  }

  /// Run immediate monitoring check (for testing)
  Future<void> runImmediateCheck() async {
    await BackgroundMonitor.runImmediateCheck();
  }

  /// Check if real sensing is available (permissions granted)
  Future<bool> isAvailable() async {
    return await _collector.requestPermissions();
  }

  /// Get sensing mode (real vs simulated)
  String getSensingMode() {
    return 'real'; // Always real in this service
  }
}
