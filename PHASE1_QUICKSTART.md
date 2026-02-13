# Phase 1 Quick Start Guide

## 🚀 From Demo to Real System in 5 Steps

### Step 1: Install Dependencies
```bash
cd otium
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
# App launches in demo mode (simulated metrics)
```

### Step 3: Enable Real Sensing
```dart
// In your app initialization (main.dart or settings screen)
import 'package:otium/core/services/real_sensing_service.dart';

final service = await RealSensingService.create();
final initialized = await service.initialize();

if (initialized) {
  print('✅ Real sensing enabled!');
} else {
  print('❌ Permission required - guide user to settings');
}
```

### Step 4: Grant Permission
1. Open Android Settings
2. Navigate to: **Apps → Special Access → Usage Access**
3. Find **Otium** and toggle ON
4. Return to app

### Step 5: Start Background Monitoring
```dart
// Enable passive monitoring (every 30 minutes)
await service.setBackgroundMonitoring(true);

print('🔄 Background monitoring active');
```

---

## 📊 Quick API Reference

### Get Current Metrics
```dart
final metrics = await service.getCurrentMetrics();

print('Score: ${metrics['score']}');
print('Classification: ${metrics['classification']}');
print('Unlocks: ${metrics['unlocks']}');
print('App Switches: ${metrics['appSwitches']}');
print('Night Usage: ${metrics['nightMinutes']} min');
```

### Check Intervention Status
```dart
final stats = await service.getInterventionStats();

print('Interventions today: ${stats['interventionsToday']}');
print('Remaining: ${stats['remainingToday']}');
print('Can trigger now: ${stats['canTriggerNow']}');
```

### Get Historical Data
```dart
final history = await service.getScoreHistory();

for (var entry in history) {
  print('${entry['timestamp']}: ${entry['score']}');
}
```

### Detailed Analysis
```dart
final analysis = await service.getDetailedAnalysis();

print('Score: ${analysis['score']}');
print('Should intervene: ${analysis['shouldIntervene']}');
print('Breakdown:');
print('  Unlocks: ${analysis['breakdown']['unlocks']['percentage']}%');
print('  Switches: ${analysis['breakdown']['appSwitches']['percentage']}%');
print('  Night: ${analysis['breakdown']['nightUsage']['percentage']}%');
```

---

## 🎨 UI Integration Example

### Toggle Real/Simulated Mode
```dart
class AppState extends ChangeNotifier {
  RealSensingService? _sensingService;
  bool _useRealSensing = false;

  Future<void> initializeRealSensing() async {
    _sensingService = await RealSensingService.create();
    final initialized = await _sensingService!.initialize();
    
    if (initialized) {
      _useRealSensing = true;
      await refreshMetrics();
      notifyListeners();
    }
  }

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

  void toggleSensingMode() {
    _useRealSensing = !_useRealSensing;
    notifyListeners();
  }
}
```

### Settings Screen Widget
```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return ListView(
          children: [
            SwitchListTile(
              title: Text('Real Sensing'),
              subtitle: Text('Use actual device usage data'),
              value: appState.useRealSensing,
              onChanged: (value) {
                if (value) {
                  appState.initializeRealSensing();
                } else {
                  appState.toggleSensingMode();
                }
              },
            ),
            SwitchListTile(
              title: Text('Background Monitoring'),
              subtitle: Text('Check overload every 30 minutes'),
              value: appState.backgroundMonitoringEnabled,
              onChanged: (value) async {
                await appState.setBackgroundMonitoring(value);
              },
            ),
            ListTile(
              title: Text('Intervention Stats'),
              subtitle: FutureBuilder(
                future: appState.getInterventionStats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final stats = snapshot.data as Map<String, dynamic>;
                    return Text(
                      '${stats['interventionsToday']} today, '
                      '${stats['remainingToday']} remaining'
                    );
                  }
                  return Text('Loading...');
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

---

## 🧪 Testing Real Sensing

### Manual Test Flow
1. **Install app** on Android device
2. **Grant permission** (Usage Access)
3. **Use phone normally** for 1-2 hours:
   - Switch between apps frequently
   - Check phone multiple times
   - Use phone late at night (optional)
4. **Open Otium** and check metrics
5. **Verify** real data is displayed

### Trigger Immediate Check
```dart
// For testing - runs background check immediately
await service.runImmediateCheck();

// Wait 10 seconds
await Future.delayed(Duration(seconds: 10));

// Check updated metrics
final metrics = await service.getCurrentMetrics();
print('Updated score: ${metrics['score']}');
```

### Check Logs
```bash
# View background monitoring logs
adb logcat | grep BackgroundMonitor

# Expected output:
# [BackgroundMonitor] Starting task: cognitive_overload_monitor
# [BackgroundMonitor] Usage data collected: {...}
# [BackgroundMonitor] Overload score: 45.2 (Moderate)
# [BackgroundMonitor] No intervention needed
# [BackgroundMonitor] Task completed successfully
```

---

## 🔧 Troubleshooting

### Permission Not Granted
**Symptom**: `initialize()` returns `false`

**Solution**:
```dart
// Show dialog guiding user to settings
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Permission Required'),
    content: Text(
      'Otium needs Usage Access permission to detect cognitive overload.\n\n'
      'Go to: Settings → Apps → Special Access → Usage Access → Otium'
    ),
    actions: [
      TextButton(
        onPressed: () {
          // Open app settings
          openAppSettings();
        },
        child: Text('Open Settings'),
      ),
    ],
  ),
);
```

### No Data Collected
**Symptom**: All metrics return 0

**Solutions**:
1. Verify permission is granted
2. Use phone normally for at least 30 minutes
3. Check time range (must be within last 7 days)
4. Try `collectToday()` instead of custom range

### Background Monitoring Not Running
**Symptom**: No periodic updates

**Solutions**:
1. Check battery optimization settings
2. Ensure app is not in "restricted" mode
3. Verify Workmanager initialization
4. Check Android logs for errors

---

## 📈 Expected Results

### After 1 Hour of Normal Use
```
Unlocks: 15-30
App Switches: 40-80
Night Usage: 0-5 minutes
Score: 20-40 (Calm to Moderate)
```

### After 4 Hours of Heavy Use
```
Unlocks: 60-100
App Switches: 150-250
Night Usage: 10-30 minutes
Score: 60-100 (High Overload)
```

### After Intervention
```
Pre-score: 70.0
Post-score: 35.0
Reduction: 50%
Classification: High Overload → Moderate
```

---

## 🎯 Success Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs successfully
- [ ] Real sensing initialized
- [ ] Usage Access permission granted
- [ ] Background monitoring enabled
- [ ] Real metrics displayed (non-zero values)
- [ ] Historical data accumulating
- [ ] Intervention triggered when score > 60
- [ ] Battery impact < 2% per day

---

## 📚 Full Documentation

- **Complete Guide**: [PHASE1_IMPLEMENTATION.md](PHASE1_IMPLEMENTATION.md)
- **Project Overview**: [README.md](README.md)
- **Implementation Summary**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

---

## 💡 Pro Tips

1. **Test with Real Usage**: Don't just open/close apps rapidly - use phone naturally
2. **Check at Different Times**: Morning vs evening usage patterns differ
3. **Monitor Battery**: Use Android battery stats to verify < 2% impact
4. **Review Logs**: Background monitoring logs show detailed execution
5. **Historical Trends**: Wait 24 hours to see meaningful trend data

---

## 🚀 Next Steps

Once Phase 1 is working:

1. **Add UI Toggle**: Settings screen to switch real/simulated mode
2. **Implement Notifications**: Alert user when overload detected
3. **Visualize Trends**: Charts showing score over time
4. **Personalize Thresholds**: Let users adjust sensitivity
5. **iOS Support**: Implement Screen Time API equivalent

---

**Ready to transform Otium from demo to real digital wellness system!** 🎉

For questions or issues, see [PHASE1_IMPLEMENTATION.md](PHASE1_IMPLEMENTATION.md) or open an issue on GitHub.
