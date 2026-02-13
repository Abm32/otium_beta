# Otium - Cognitive Overload Detection & Intervention App 🧠

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Otium** is a Flutter-based mobile application that detects cognitive overload through simulated usage metrics and provides guided breathing interventions to help users manage mental stress. The app demonstrates a complete feedback loop: detecting overload, alerting the user, delivering a therapeutic intervention, and showing measurable improvement.

> **Latin Origin**: *Otium* means "leisure" or "free time" - representing the mental clarity and peace we aim to restore.

## 🎯 About the Project

In today's hyper-connected world, cognitive overload from constant app switching, notifications, and digital multitasking has become a silent epidemic affecting mental health and productivity. Otium addresses this by:

- **Detecting** cognitive overload through usage pattern analysis
- **Alerting** users when their mental load reaches critical levels
- **Intervening** with evidence-based breathing exercises
- **Measuring** the effectiveness of interventions with before/after metrics

This hackathon demo showcases how technology can be part of the solution to digital wellness, not just the problem.

## ✨ Key Features

### 🔍 Cognitive Overload Detection
- **Real-time Score Calculation**: Uses a weighted formula based on phone unlocks, app switches, and nighttime usage
- **Smart Classification**: Categorizes mental state as Calm (<30), Moderate (30-60), or High Overload (>60)
- **Visual Feedback**: Color-coded cognitive meter with intuitive progress indicators

### 🚨 Intelligent Alerting
- **Automatic Triggers**: Alerts activate when overload score exceeds threshold (>60)
- **Clear Messaging**: Encourages users to take a "Neuro Reset" with actionable prompts
- **Seamless Navigation**: Smooth transition from detection to intervention

### 🫁 Guided Breathing Intervention
- **90-Second Exercise**: Scientifically-timed breathing session for stress reduction
- **Animated Guidance**: Beautiful breathing circle with 4-second inhale/exhale cycles
- **Calming Design**: Soothing colors and smooth animations create a therapeutic environment
- **Progress Tracking**: Real-time countdown timer keeps users engaged

### 📊 Results Dashboard
- **Before/After Comparison**: Visual representation of score reduction
- **Percentage Metrics**: Shows exact improvement (typically 50% reduction)
- **Mood Tracking**: Emoji-based mood check-in for emotional awareness
- **Session History**: Records intervention effectiveness over time

### 🎨 Professional UI/UX
- **Calming Color Palette**: Teal and blue tones promote relaxation
- **Smooth Animations**: Fluid transitions and breathing circle animations
- **Responsive Design**: Works seamlessly across different screen sizes
- **Accessibility**: High contrast text and clear visual hierarchy

## 🏗️ Architecture

```
otium/
├── lib/
│   ├── logic/                    # Business logic & state management
│   │   ├── app_state.dart        # Global app state with ChangeNotifier
│   │   ├── cognitive_metrics.dart # Usage metrics model
│   │   ├── intervention_session.dart # Session tracking
│   │   └── overload_calculator.dart  # Score calculation engine
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Main dashboard with metrics
│   │   ├── alert_screen.dart     # Overload alert & intervention prompt
│   │   ├── breathing_screen.dart # Guided breathing exercise
│   │   └── dashboard_screen.dart # Results & mood tracking
│   ├── widgets/                  # Reusable UI components
│   │   ├── cognitive_meter.dart  # Visual overload indicator
│   │   └── breathing_circle.dart # Animated breathing guide
│   └── main.dart                 # App entry point
├── test/                         # Unit & widget tests (99.3% pass rate)
└── integration_test/             # End-to-end flow tests
```

### State Management
- **Provider Pattern**: Uses `ChangeNotifier` for reactive state updates
- **Centralized State**: Single `AppState` class manages all app data
- **Efficient Updates**: Only rebuilds widgets that depend on changed data

### Navigation Flow
```
Home Screen → Alert Screen → Breathing Screen → Dashboard → Home Screen
    ↓             ↓               ↓                ↓
 Monitor      Trigger         Intervene         Measure
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.0 or higher
- **Dart SDK**: Version 3.0 or higher
- **Android Studio** / **Xcode** (for mobile development)
- **Git**: For cloning the repository
- **Android Device/Emulator**: For Phase 1 real sensing (requires Android 5.0+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Abm32/otium_beta.git
   cd otium_beta
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   
   **For Android (Recommended for Phase 1):**
   ```bash
   flutter run
   ```
   
   **For iOS:**
   ```bash
   flutter run -d ios
   ```
   
   **For Web (Simulated mode only):**
   ```bash
   flutter run -d chrome
   ```

### Phase 1: Enable Real Sensing

To use real cognitive overload detection:

1. **Grant Usage Access Permission**
   - Open app and tap "Enable Real Sensing"
   - Navigate to: Settings → Apps → Special Access → Usage Access
   - Enable permission for Otium

2. **Enable Background Monitoring**
   - In app settings, toggle "Background Monitoring"
   - App will check cognitive overload every 30 minutes

3. **Use Your Phone Normally**
   - Real metrics will be collected passively
   - View real-time overload scores on home screen

See [PHASE1_IMPLEMENTATION.md](PHASE1_IMPLEMENTATION.md) for detailed setup.

### Building for Production

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS App:**
```bash
flutter build ios --release
```

**Web App:**
```bash
flutter build web
# Output: build/web/
```

## 🎮 How to Use (Demo Flow)

### Complete Demo: ~2 Minutes

1. **Start on Home Screen** (0:00)
   - View your current cognitive overload score (starts at 0)
   - See breakdown of metrics: unlocks, app switches, night minutes

2. **Simulate App Usage** (0:00 - 0:30)
   - Tap "Simulate App Switch" button ~35 times
   - Watch your overload score increase in real-time
   - Observe the cognitive meter change colors (green → yellow → red)

3. **Automatic Alert** (0:30)
   - When score exceeds 60, automatic navigation to Alert Screen
   - See warning message: "Your cognitive load is high. Take a Neuro Reset?"
   - Tap "Start Breathing Exercise"

4. **Breathing Intervention** (0:30 - 2:00)
   - Follow the animated breathing circle for 90 seconds
   - Inhale when circle expands (2 seconds)
   - Exhale when circle contracts (2 seconds)
   - Watch countdown timer

5. **View Results** (2:00 - 2:10)
   - Automatic navigation to Dashboard
   - See before/after score comparison
   - Observe 50% score reduction
   - Select your mood (😊 😐 😟)
   - Tap "Return to Home"

6. **Continue Monitoring** (2:10+)
   - Back on Home Screen with reduced metrics
   - Continue using the app or exit

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Test Coverage
- **Total Tests**: 150
- **Passing**: 149 (99.3%)
- **Coverage Areas**:
  - Unit tests for all logic classes
  - Widget tests for all UI components
  - Property-based tests for correctness
  - Integration tests for complete flow

### Manual Testing Script
```bash
dart test_demo_flow.dart
```

## 📈 Technical Highlights

### Overload Score Formula
```dart
score = (0.4 × unlocks) + (0.4 × appSwitches) + (0.2 × nightMinutes)
```

### Classification Thresholds
- **Calm**: score < 30 (Green)
- **Moderate**: 30 ≤ score ≤ 60 (Yellow)
- **High Overload**: score > 60 (Red)

### Intervention Effectiveness
- **Score Reduction**: 50% (post-score = pre-score × 0.5)
- **Metrics Reduction**: All metrics reduced by 50%
- **Session Duration**: 90 seconds (evidence-based timing)

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider (ChangeNotifier)
- **Testing**: flutter_test, integration_test
- **Background Tasks**: workmanager (Phase 1)
- **Real Sensing**: usage_stats, permission_handler (Phase 1)
- **Local Storage**: shared_preferences (Phase 1)
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

### Phase 1 Architecture

```
lib/
├── core/                          # Real sensing infrastructure
│   ├── phenotyping/               # Digital phenotyping engine
│   │   ├── usage_collector.dart   # Android UsageStats integration
│   │   ├── overload_engine.dart   # Scientific computation
│   │   └── intervention_trigger.dart # Smart timing
│   ├── background/
│   │   └── background_monitor.dart # Periodic monitoring
│   └── services/
│       └── real_sensing_service.dart # Integration layer
├── logic/                         # Business logic (original)
├── screens/                       # UI screens
└── widgets/                       # Reusable components
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ Tested | Primary demo platform |
| iOS      | ✅ Ready | Requires Xcode for building |
| Web      | ✅ Tested | Works in Chrome/Firefox |
| Windows  | ⚠️ Untested | Should work with Flutter 3.0+ |
| macOS    | ⚠️ Untested | Should work with Flutter 3.0+ |
| Linux    | ⚠️ Untested | Should work with Flutter 3.0+ |

## 🎯 Future Enhancements

### ✅ Phase 1: Real Cognitive Overload Detection (IMPLEMENTED)

**Status**: Complete - See [PHASE1_IMPLEMENTATION.md](PHASE1_IMPLEMENTATION.md) for details

Phase 1 transforms Otium from a simulated demo into a real digital wellness system with:

- ✅ **Real Device Sensing**: Android UsageStats API integration for actual app switching, unlocks, and night usage
- ✅ **Scientific Computation**: Evidence-based overload formula with detailed breakdown
- ✅ **Background Monitoring**: Passive detection every 30 minutes using workmanager
- ✅ **Smart Intervention Timing**: Rate limiting (6/day, 2hr intervals) to prevent fatigue
- ✅ **Privacy-First Architecture**: All data stays on-device, no cloud uploads
- ✅ **Historical Tracking**: 24-hour score history for trend analysis

**Key Components**:
- `UsageCollector`: Real device usage data collection
- `OverloadEngine`: Cognitive overload computation
- `InterventionTrigger`: Smart timing and rate limiting
- `BackgroundMonitor`: Periodic passive monitoring
- `RealSensingService`: Integration layer for UI

**How to Use**:
```dart
// Initialize real sensing
final service = await RealSensingService.create();
await service.initialize();

// Get real metrics
final metrics = await service.getCurrentMetrics();
print('Real overload score: ${metrics['score']}');

// Enable background monitoring
await service.setBackgroundMonitoring(true);
```

See [PHASE1_IMPLEMENTATION.md](PHASE1_IMPLEMENTATION.md) for complete documentation.

---

### 🔮 Phase 2: Enhanced Sensing & Personalization

- [ ] Real device tracking (actual phone unlocks, app switches)
- [ ] Historical data visualization with charts
- [ ] Multiple intervention types (meditation, micro-breaks)
- [ ] Personalized threshold settings
- [ ] Social features (share progress, challenges)
- [ ] Wearable device integration
- [ ] Machine learning for predictive alerts
- [ ] Gamification with achievements and streaks

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

Built with ❤️ for digital wellness and mental health awareness.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Mental health researchers for breathing exercise science
- Open source community for inspiration and support

## 📞 Contact

For questions, feedback, or collaboration opportunities:
- **GitHub**: [@Abm32](https://github.com/Abm32)
- **Repository**: [otium_beta](https://github.com/Abm32/otium_beta)

---

**Remember**: Taking care of your mental health is not a luxury, it's a necessity. 🧠💚
