import 'package:usage_stats/usage_stats.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

/// Collects real device usage data from Android UsageStats API
/// 
/// This class provides privacy-first passive sensing of:
/// - App switching frequency (attention fragmentation)
/// - Screen time sessions (compulsive checking)
/// - Night usage patterns (sleep disruption)
class UsageCollector {
  /// Request necessary permissions for usage stats access
  Future<bool> requestPermissions() async {
    // Check if usage access permission is granted
    final status = await Permission.appTrackingTransparency.status;
    
    if (status.isDenied) {
      // Request permission
      final result = await Permission.appTrackingTransparency.request();
      return result.isGranted;
    }
    
    return status.isGranted;
  }

  /// Collect usage data for the specified time range
  /// 
  /// Returns a map containing:
  /// - unlockCount: Number of device unlocks
  /// - appSwitches: Number of foreground app switches
  /// - nightUsageMinutes: Minutes of usage between 11 PM - 6 AM
  /// - topApps: List of most used apps
  Future<Map<String, dynamic>> collectUsageData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Query usage stats for the time range
      final usageStats = await UsageStats.queryUsageStats(
        startTime,
        endTime,
      );

      // Query usage events for detailed app switching data
      final events = await UsageStats.queryEvents(
        startTime,
        endTime,
      );

      // Process the data
      final metrics = _processUsageData(usageStats, events, startTime, endTime);
      
      return metrics;
    } catch (e) {
      print('Error collecting usage data: $e');
      return _getEmptyMetrics();
    }
  }

  /// Process raw usage stats into cognitive overload metrics
  Map<String, dynamic> _processUsageData(
    List<UsageInfo> usageStats,
    List<EventUsageInfo> events,
    DateTime startTime,
    DateTime endTime,
  ) {
    // Count app switches (foreground app changes)
    int appSwitches = 0;
    int unlockCount = 0;
    int nightUsageMinutes = 0;
    
    // Track app usage for top apps
    Map<String, int> appUsageDuration = {};

    // Process events to count switches and unlocks
    String? lastApp;
    for (var event in events) {
      // Count screen unlocks
      if (event.eventType == '1') { // SCREEN_INTERACTIVE
        unlockCount++;
      }
      
      // Count app switches
      if (event.eventType == '2' && event.packageName != lastApp) { // MOVE_TO_FOREGROUND
        appSwitches++;
        lastApp = event.packageName;
        
        // Check if usage is during night hours (11 PM - 6 AM)
        final eventTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(event.timeStamp ?? '0')
        );
        if (_isNightTime(eventTime)) {
          nightUsageMinutes += 1; // Approximate
        }
      }
    }

    // Process usage stats for app duration
    for (var stat in usageStats) {
      final packageName = stat.packageName ?? 'unknown';
      final duration = int.parse(stat.totalTimeInForeground ?? '0');
      appUsageDuration[packageName] = duration;
    }

    // Get top 5 apps by usage time
    final topApps = appUsageDuration.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    final topAppNames = topApps
        .take(5)
        .map((e) => _getAppName(e.key))
        .toList();

    return {
      'unlockCount': unlockCount,
      'appSwitches': appSwitches,
      'nightUsageMinutes': nightUsageMinutes,
      'topApps': topAppNames,
      'totalAppsUsed': usageStats.length,
      'collectedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Check if a given time is during night hours (11 PM - 6 AM)
  bool _isNightTime(DateTime time) {
    final hour = time.hour;
    return hour >= 23 || hour < 6;
  }

  /// Extract readable app name from package name
  String _getAppName(String packageName) {
    // Simple extraction - in production, use package_info or app name lookup
    final parts = packageName.split('.');
    return parts.isNotEmpty ? parts.last : packageName;
  }

  /// Return empty metrics structure
  Map<String, dynamic> _getEmptyMetrics() {
    return {
      'unlockCount': 0,
      'appSwitches': 0,
      'nightUsageMinutes': 0,
      'topApps': <String>[],
      'totalAppsUsed': 0,
      'collectedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Collect usage data for the last 24 hours
  Future<Map<String, dynamic>> collectLast24Hours() async {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(hours: 24));
    return collectUsageData(startTime: startTime, endTime: endTime);
  }

  /// Collect usage data for today
  Future<Map<String, dynamic>> collectToday() async {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day);
    return collectUsageData(startTime: startTime, endTime: now);
  }
}
