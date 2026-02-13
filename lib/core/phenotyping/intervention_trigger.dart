import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Manages intervention triggering logic with smart timing and frequency controls
/// 
/// This class ensures interventions are:
/// - Timely: Triggered when overload is detected
/// - Non-intrusive: Respects user context and preferences
/// - Effective: Prevents intervention fatigue through rate limiting
class InterventionTrigger {
  // Rate limiting constants
  static const Duration minInterventionInterval = Duration(hours: 2);
  static const int maxInterventionsPerDay = 6;
  
  // Preference keys
  static const String _lastInterventionKey = 'last_intervention_time';
  static const String _interventionCountKey = 'intervention_count_today';
  static const String _lastResetDateKey = 'last_reset_date';

  final SharedPreferences _prefs;

  InterventionTrigger(this._prefs);

  /// Factory constructor to create instance with SharedPreferences
  static Future<InterventionTrigger> create() async {
    final prefs = await SharedPreferences.getInstance();
    return InterventionTrigger(prefs);
  }

  /// Check if intervention should be triggered based on overload score
  /// 
  /// Returns true if:
  /// - Score exceeds threshold (>60)
  /// - Minimum time interval has passed since last intervention
  /// - Daily intervention limit not exceeded
  /// - User is not in "do not disturb" context
  Future<bool> shouldTrigger({
    required double overloadScore,
    required double threshold,
  }) async {
    // Check if score exceeds threshold
    if (overloadScore <= threshold) {
      return false;
    }

    // Reset daily counter if it's a new day
    await _resetDailyCounterIfNeeded();

    // Check rate limiting
    if (!await _canTriggerIntervention()) {
      return false;
    }

    // Check user context (future: integrate with system DND, calendar, etc.)
    if (await _isUserBusy()) {
      return false;
    }

    return true;
  }

  /// Record that an intervention was triggered
  Future<void> recordIntervention() async {
    final now = DateTime.now();
    
    // Save last intervention time
    await _prefs.setString(
      _lastInterventionKey,
      now.toIso8601String(),
    );

    // Increment daily counter
    final currentCount = await _getTodayInterventionCount();
    await _prefs.setInt(_interventionCountKey, currentCount + 1);
  }

  /// Check if enough time has passed since last intervention
  Future<bool> _canTriggerIntervention() async {
    // Check time interval
    final lastInterventionStr = _prefs.getString(_lastInterventionKey);
    if (lastInterventionStr != null) {
      final lastIntervention = DateTime.parse(lastInterventionStr);
      final timeSince = DateTime.now().difference(lastIntervention);
      
      if (timeSince < minInterventionInterval) {
        return false;
      }
    }

    // Check daily limit
    final todayCount = await _getTodayInterventionCount();
    if (todayCount >= maxInterventionsPerDay) {
      return false;
    }

    return true;
  }

  /// Get number of interventions triggered today
  Future<int> _getTodayInterventionCount() async {
    await _resetDailyCounterIfNeeded();
    return _prefs.getInt(_interventionCountKey) ?? 0;
  }

  /// Reset daily counter if it's a new day
  Future<void> _resetDailyCounterIfNeeded() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastResetDate = _prefs.getString(_lastResetDateKey);
    
    if (lastResetDate != todayStr) {
      // New day - reset counter
      await _prefs.setInt(_interventionCountKey, 0);
      await _prefs.setString(_lastResetDateKey, todayStr);
    }
  }

  /// Check if user is in a busy context (placeholder for future enhancement)
  /// 
  /// Future integrations:
  /// - System Do Not Disturb status
  /// - Calendar events (meetings, focus time)
  /// - Active phone calls
  /// - Driving mode
  Future<bool> _isUserBusy() async {
    // Placeholder - always return false for now
    // In production, integrate with:
    // - Android NotificationManager.getCurrentInterruptionFilter()
    // - Calendar API
    // - Activity recognition
    return false;
  }

  /// Get time until next intervention is allowed
  Future<Duration?> getTimeUntilNextIntervention() async {
    final lastInterventionStr = _prefs.getString(_lastInterventionKey);
    if (lastInterventionStr == null) {
      return null; // No previous intervention
    }

    final lastIntervention = DateTime.parse(lastInterventionStr);
    final timeSince = DateTime.now().difference(lastIntervention);
    
    if (timeSince >= minInterventionInterval) {
      return null; // Can trigger now
    }

    return minInterventionInterval - timeSince;
  }

  /// Get remaining interventions allowed today
  Future<int> getRemainingInterventionsToday() async {
    final todayCount = await _getTodayInterventionCount();
    return (maxInterventionsPerDay - todayCount).clamp(0, maxInterventionsPerDay);
  }

  /// Get intervention statistics for today
  Future<Map<String, dynamic>> getTodayStats() async {
    final count = await _getTodayInterventionCount();
    final remaining = await getRemainingInterventionsToday();
    final timeUntilNext = await getTimeUntilNextIntervention();

    return {
      'interventionsToday': count,
      'remainingToday': remaining,
      'maxPerDay': maxInterventionsPerDay,
      'timeUntilNext': timeUntilNext?.inMinutes,
      'canTriggerNow': await _canTriggerIntervention(),
    };
  }

  /// Clear all intervention history (for testing/reset)
  Future<void> clearHistory() async {
    await _prefs.remove(_lastInterventionKey);
    await _prefs.remove(_interventionCountKey);
    await _prefs.remove(_lastResetDateKey);
  }
}
