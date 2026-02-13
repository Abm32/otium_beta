import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../phenotyping/usage_collector.dart';
import '../phenotyping/overload_engine.dart';
import '../phenotyping/intervention_trigger.dart';

/// Background monitoring service for passive cognitive overload detection
/// 
/// This service runs periodically (every 30 minutes) to:
/// 1. Collect device usage data
/// 2. Compute overload score
/// 3. Trigger intervention if needed
/// 4. Store metrics for historical analysis
class BackgroundMonitor {
  static const String monitorTaskName = 'cognitive_overload_monitor';
  static const String uniqueTaskName = 'otium_monitor';

  /// Initialize background monitoring
  /// 
  /// This should be called once during app initialization
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  /// Register periodic monitoring task
  /// 
  /// Runs every 30 minutes to check cognitive overload
  static Future<void> registerPeriodicMonitoring() async {
    await Workmanager().registerPeriodicTask(
      uniqueTaskName,
      monitorTaskName,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  /// Cancel background monitoring
  static Future<void> cancelMonitoring() async {
    await Workmanager().cancelByUniqueName(uniqueTaskName);
  }

  /// Run immediate monitoring check (for testing)
  static Future<void> runImmediateCheck() async {
    await Workmanager().registerOneOffTask(
      'immediate_check',
      monitorTaskName,
      initialDelay: const Duration(seconds: 5),
    );
  }
}

/// Background task callback dispatcher
/// 
/// This function runs in a separate isolate and must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('[BackgroundMonitor] Starting task: $task');

      // Initialize components
      final collector = UsageCollector();
      final engine = OverloadEngine();
      final prefs = await SharedPreferences.getInstance();
      final trigger = InterventionTrigger(prefs);

      // Step 1: Collect usage data for the last 30 minutes
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(minutes: 30));
      
      final usageData = await collector.collectUsageData(
        startTime: startTime,
        endTime: now,
      );

      print('[BackgroundMonitor] Usage data collected: $usageData');

      // Step 2: Compute overload score
      final score = engine.computeFromUsageData(usageData);
      final classification = engine.classify(score);

      print('[BackgroundMonitor] Overload score: $score ($classification)');

      // Step 3: Store metrics
      await _storeMetrics(prefs, score, classification, usageData);

      // Step 4: Check if intervention should be triggered
      final shouldTrigger = await trigger.shouldTrigger(
        overloadScore: score,
        threshold: OverloadEngine.moderateThreshold,
      );

      if (shouldTrigger) {
        print('[BackgroundMonitor] Triggering intervention');
        
        // Record intervention
        await trigger.recordIntervention();
        
        // Show notification (future: implement notification service)
        await _showInterventionNotification(score, classification);
      } else {
        print('[BackgroundMonitor] No intervention needed');
      }

      print('[BackgroundMonitor] Task completed successfully');
      return Future.value(true);
    } catch (e) {
      print('[BackgroundMonitor] Error: $e');
      return Future.value(false);
    }
  });
}

/// Store metrics in local storage for historical analysis
Future<void> _storeMetrics(
  SharedPreferences prefs,
  double score,
  String classification,
  Map<String, dynamic> usageData,
) async {
  // Store latest score
  await prefs.setDouble('latest_overload_score', score);
  await prefs.setString('latest_classification', classification);
  await prefs.setString('latest_update', DateTime.now().toIso8601String());

  // Store usage metrics
  await prefs.setInt('latest_unlocks', usageData['unlockCount'] ?? 0);
  await prefs.setInt('latest_app_switches', usageData['appSwitches'] ?? 0);
  await prefs.setInt('latest_night_minutes', usageData['nightUsageMinutes'] ?? 0);

  // Store historical data (last 24 hours)
  final historyKey = 'score_history';
  final history = prefs.getStringList(historyKey) ?? [];
  
  final entry = '${DateTime.now().toIso8601String()}|$score|$classification';
  history.add(entry);
  
  // Keep only last 48 entries (24 hours at 30-min intervals)
  if (history.length > 48) {
    history.removeAt(0);
  }
  
  await prefs.setStringList(historyKey, history);
}

/// Show intervention notification to user
/// 
/// Future enhancement: Implement proper notification service
Future<void> _showInterventionNotification(
  double score,
  String classification,
) async {
  // Placeholder for notification implementation
  // In production, use flutter_local_notifications package
  print('[Notification] Cognitive overload detected: $score ($classification)');
  print('[Notification] Time for a Neuro Reset!');
  
  // TODO: Implement actual notification with:
  // - Title: "Cognitive Overload Detected"
  // - Body: "Your mental load is high. Take a 90-second breathing break?"
  // - Action: Open app to breathing screen
  // - Priority: High
  // - Sound: Calming notification sound
}
