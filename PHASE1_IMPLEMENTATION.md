# Phase 1: Real Cognitive Overload Detection - Implementation Guide

## 🎯 Objective

Transform Otium from a simulated demo into a **scientifically defensible, working digital wellness system** by replacing simulation with **real passive detection** of cognitive overload signals.

## ✅ What We Built

### Core Architecture

```
lib/core/
├── phenotyping/              # Digital phenotyping engine
│   ├── usage_collector.dart  # Real device usage data collection
│   ├── overload_engine.dart  # Cognitive overload computation
│   └── intervention_trigger.dart # Smart intervention timing
├── background/
│   └── background_monitor.dart # Periodic monitoring (every 30 min)
└── services/
    └── real_sensing_service.dart # Integration layer
```

### Key Components

#### 1. **UsageCollector** - Real Device Sensing
- Integrates with Android `UsageStats` API via platform channels
- Collects actual device behavior:
  - **App switching frequency** (attention fragmentation proxy)
  - **Screen time sessions** (compulsive checking indicator)
  - **Night usage patterns** (sleep disruption measure)
- Privacy-first: All data stays on-device

#### 2. **OverloadEngine** - Scientific Computation
- Implements evidence-based formula:
  ```
  score = (0.4 × unlocks) + (0.4 × appSwitches) + (0.2 × nightMinutes)
  ```
- Classification thresholds:
  - **Calm**: < 30
  - **Moderate**: 30-60
  - **High Overload**: > 60
- Provides detailed breakdown and risk analysis

#### 3. **InterventionTrigger** - Smart Timing
- Rate limiting: Max 6 interventions/day, 2-hour minimum interval
- Context awareness (placeholder for future DND integration)
- Prevents intervention fatigue
- Tracks effectiveness metrics

#### 4. **BackgroundMonitor** - Passive Monitoring
- Runs every 30 minutes using `workmanager`
- Collects usage data → Computes score → Triggers intervention if needed
- Stores historical data for trend analysis
- Battery-efficient with smart constraints

#### 5. **RealSensingService** - Integration Layer
- Bridges real sensing with existing app UI
- Manages permissions and initialization
- Provides caching for performance
- Exposes clean API for UI consumption

## 📦 Dependencies Added

```yaml
dependencies:
  workmanager: ^0.5.2              # Background task execution
  shared_preferences: ^2.2.2       # Local data storage
  permission_handler: ^11.3.0      # Permission management
  usage_stats: ^1.3.0              # Android UsageStats API access
```

## 🚀 How to Use

### 1. Install Dependencies

```bash
cd otium
flutter pub get
```

### 2. Request Permissions

On first launch, the app will request **Usage Access** permission:

```dart
final service = await RealSensingService.create();
final initialized = await service.initialize();

if (!initialized) {
  // Guide user to Settings → Apps → Special Access → Usage Access
  // Enable permission for Otium
}
```

### 3. Collect Real Metrics

```dart
// Get current overload metrics from real device usage
final metrics = await service.getCurrentMetrics();

print('Overload Score: ${metrics['score']}');
print('Classification: ${metrics['classification']}');
print('Unlocks: ${metrics['unlocks']}');
print('App Switches: ${metrics['appSwitches']}');
print('Night Usage: ${metrics['nightMinutes']} minutes');
```

### 4. Enable Background Monitoring

```dart
// Start passive monitoring (runs every 30 minutes)
await service.setBackgroundMonitoring(true);

// Check if monitoring is active
final isActive = service.isBackgroundMonitoringEnabled();
```

### 5. Get Detailed Analysis

```dart
// Get breakdown of overload contributors
final analysis = await service.getDetailedAnalysis();

print('Score: ${analysis['score']}');
print('Should Intervene: ${analysis['shouldIntervene']}');
print('Breakdown:');
print('  Unlocks contribute: ${analysis['breakdown']['unlocks']['percentage']}%');
print('  App switches contribute: ${analysis['breakdown']['appSwitches']['percentage']}%');
print('  Night usage contributes: ${analysis['breakdown']['nightUsage']['percentage']}%');
```

### 6. View Historical Data

```dart
// Get score history (last 24 hours)
final history = await service.getScoreHistory();

for (var entry in history) {
  print('${entry['timestamp']}: ${entry['score']} (${entry['classification']})');
}
```

## 🔧 Integration with Existing App

### Update AppState to Use Real Sensing

```dart
class AppState extends ChangeNotifier {
  RealSensingService? _sensingService;
  bool _useRealSensing = false;

  // Initialize real sensing
  Future<void> initializeRealSensing() async {
    _sensingService = await RealSensingService.create();
    final initialized = await _sensingService!.initialize();
    
    if (initialized) {
      _useRealSensing = true;
      await refreshMetrics();
    }
  }

  // Refresh metrics from real device usage
  Future<void> refreshMetrics() async {
    if (_useRealSensing && _sensingService != null) {
      final metrics = await _sensingService!.getCurrentMetrics();
      
      // Update app state with real metrics
      this.metrics.unlocks = metrics['unlocks'];
      this.metrics.appSwitches = metrics['appSwitches'];
      this.metrics.nightMinutes = metrics['nightMinutes'];
      
      notifyListeners();
    }
  }

  // Toggle between real and simulated mode
  void toggleSensingMode() {
    _useRealSensing = !_useRealSensing;
    notifyListeners();
  }
}
```

### Add Settings Screen

Create a settings screen to:
- Toggle between real and simulated sensing
- View background monitoring status
- Check intervention statistics
- View historical trends
- Manage permissions

## 📊 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Background Monitor                        │
│                  (Runs every 30 minutes)                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    UsageCollector                            │
│         Queries Android UsageStats API                       │
│    (unlocks, app switches, night usage)                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    OverloadEngine                            │
│         Computes cognitive overload score                    │
│         Classifies: Calm / Moderate / High                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 InterventionTrigger                          │
│         Checks: Score > 60? Rate limits OK?                  │
│         Decision: Trigger intervention or wait               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Notification / Alert                        │
│         "Cognitive overload detected!"                       │
│         Opens app → Breathing screen                         │
└─────────────────────────────────────────────────────────────┘
```

## 🧪 Testing Real Sensing

### Manual Testing

1. **Grant Permissions**
   ```bash
   # Open app and grant Usage Access permission
   # Settings → Apps → Special Access → Usage Access → Otium → Enable
   ```

2. **Use Your Phone Normally**
   - Switch between apps frequently
   - Check phone multiple times
   - Use phone late at night

3. **Check Metrics**
   ```dart
   final metrics = await service.collectFreshMetrics();
   print('Real usage detected: $metrics');
   ```

4. **Trigger Background Check**
   ```dart
   await service.runImmediateCheck();
   // Wait 10 seconds, then check logs
   ```

### Automated Testing

```dart
// Test overload computation
test('OverloadEngine computes correct score', () {
  final engine = OverloadEngine();
  final score = engine.compute(
    unlocks: 50,
    switches: 100,
    nightMinutes: 30,
  );
  expect(score, equals(56.0)); // (0.4*50) + (0.4*100) + (0.2*30)
});

// Test intervention rate limiting
test('InterventionTrigger respects rate limits', () async {
  final prefs = await SharedPreferences.getInstance();
  final trigger = InterventionTrigger(prefs);
  
  // First intervention should be allowed
  final canTrigger1 = await trigger.shouldTrigger(
    overloadScore: 70,
    threshold: 60,
  );
  expect(canTrigger1, isTrue);
  
  await trigger.recordIntervention();
  
  // Second intervention within 2 hours should be blocked
  final canTrigger2 = await trigger.shouldTrigger(
    overloadScore: 70,
    threshold: 60,
  );
  expect(canTrigger2, isFalse);
});
```

## 🔐 Privacy & Security

### Privacy-First Design

1. **All data stays on-device**
   - No cloud uploads
   - No external analytics
   - No third-party tracking

2. **Minimal data collection**
   - Only aggregate metrics (counts, durations)
   - No app content or personal data
   - No location tracking

3. **User control**
   - Explicit permission requests
   - Easy to disable monitoring
   - Clear data deletion

4. **Transparent computation**
   - Open-source formula
   - Explainable results
   - User can audit logic

## 📈 Next Steps (Phase 2)

After Phase 1 is stable, consider:

1. **Enhanced Sensing**
   - Heart rate variability (if wearable available)
   - Typing patterns (stress indicators)
   - Notification frequency

2. **Smarter Interventions**
   - Personalized thresholds (ML-based)
   - Multiple intervention types (meditation, micro-breaks)
   - Adaptive timing based on user response

3. **Better Context Awareness**
   - Calendar integration (don't interrupt meetings)
   - Do Not Disturb respect
   - Activity recognition (driving, exercising)

4. **Long-term Tracking**
   - Weekly/monthly trends
   - Intervention effectiveness analysis
   - Personalized insights

5. **Social Features**
   - Anonymous benchmarking
   - Team wellness dashboards
   - Shared challenges

## 🐛 Troubleshooting

### Permission Issues

**Problem**: Usage Access permission not granted

**Solution**:
```dart
// Check permission status
final hasPermission = await UsageCollector().requestPermissions();

if (!hasPermission) {
  // Guide user to settings
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Permission Required'),
      content: Text('Please enable Usage Access in Settings'),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

### Background Monitoring Not Running

**Problem**: Background tasks not executing

**Solution**:
1. Check battery optimization settings
2. Ensure app is not in "restricted" battery mode
3. Verify Workmanager initialization
4. Check Android logs for errors

### No Data Collected

**Problem**: Usage stats returning empty

**Solution**:
1. Verify permission is granted
2. Check time range (must be within last 7 days)
3. Ensure device has usage data (use phone normally)
4. Test with `collectToday()` instead of custom range

## 📚 Resources

- [Android UsageStats API](https://developer.android.com/reference/android/app/usage/UsageStatsManager)
- [Flutter Workmanager](https://pub.dev/packages/workmanager)
- [Digital Phenotyping Research](https://www.nature.com/articles/s41746-019-0145-1)
- [Cognitive Load Theory](https://www.sciencedirect.com/topics/psychology/cognitive-load-theory)

## 🎉 Success Criteria

Phase 1 is complete when:

- ✅ Real device usage data is collected successfully
- ✅ Overload scores computed from actual behavior
- ✅ Background monitoring runs reliably every 30 minutes
- ✅ Interventions triggered based on real overload detection
- ✅ Historical data stored and accessible
- ✅ Privacy guarantees maintained (all data on-device)
- ✅ Battery impact < 2% per day
- ✅ User can toggle between real and simulated modes

---

**Built with ❤️ for digital wellness and mental health**

*Remember: The goal is not to track everything, but to detect meaningful patterns that indicate cognitive overload and provide timely, effective interventions.*
