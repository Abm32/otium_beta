import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/app_state.dart';
import '../widgets/breathing_circle.dart';

/// Screen that guides users through a 90-second breathing intervention.
///
/// This screen displays a breathing circle animation, countdown timer,
/// and breathing instructions to help users reduce cognitive overload.
/// The screen automatically navigates to the dashboard when the timer completes.
///
/// Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 6.1, 6.3, 8.4, 9.4
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  // Timer for the 90-second intervention
  Timer? _interventionTimer;
  
  // Timer for the 4-second breathing cycle (2s inhale, 2s exhale)
  Timer? _breathingTimer;
  
  // Remaining time in seconds (starts at 90)
  int _remainingSeconds = 90;
  
  // Current breathing phase (true = inhaling, false = exhaling)
  bool _isInhaling = true;

  @override
  void initState() {
    super.initState();
    _startIntervention();
    _startTimers();
  }

  /// Starts the intervention session in app state
  void _startIntervention() {
    // Defer the intervention start until after the widget is built
    // to avoid calling notifyListeners during the build process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.startIntervention();
    });
  }

  /// Starts both the intervention timer and breathing cycle timer
  void _startTimers() {
    // Start the 90-second countdown timer
    _interventionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _remainingSeconds--;
        });
        
        // When timer reaches 0, complete intervention and navigate
        if (_remainingSeconds <= 0) {
          _completeIntervention();
        }
      },
    );

    // Start the 4-second breathing cycle timer (toggle every 2 seconds)
    _breathingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        setState(() {
          _isInhaling = !_isInhaling;
        });
      },
    );
  }

  /// Completes the intervention and navigates to dashboard
  void _completeIntervention() {
    // Cancel timers
    _interventionTimer?.cancel();
    _breathingTimer?.cancel();
    
    // Complete intervention in app state
    final appState = Provider.of<AppState>(context, listen: false);
    appState.completeIntervention(null);
    
    // Navigate to dashboard screen
    // Note: DashboardScreen will be implemented in task 10.1
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  /// Formats remaining seconds as MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Gets the breathing instruction text based on current phase
  String get _breathingInstruction {
    return _isInhaling ? 'Inhale' : 'Exhale';
  }

  @override
  void dispose() {
    _interventionTimer?.cancel();
    _breathingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Enhanced calming gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F4F8), // Light blue-teal
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFE0F2F1), // Very light teal
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Countdown timer display with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90A4).withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Time Remaining',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF2C5F6F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: const Color(0xFF4A90A4),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Breathing circle widget
                    BreathingCircle(isInhaling: _isInhaling),
                    
                    // Breathing instruction text with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90A4).withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _breathingInstruction,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF4A90A4),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isInhaling ? 'Breathe in slowly' : 'Breathe out gently',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF2C5F6F),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Enhanced progress indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF2C5F6F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 280,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A90A4).withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (90 - _remainingSeconds) / 90,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4A90A4),
                                      Color(0xFF7FB069),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${((90 - _remainingSeconds) / 90 * 100).toInt()}% Complete',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2C5F6F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}