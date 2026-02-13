import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/app_state.dart';
import '../widgets/cognitive_meter.dart';

/// Home screen displaying current cognitive overload status and metrics.
///
/// This screen shows:
/// - CognitiveMeter widget with current score
/// - Current metric values (unlocks, app switches, night minutes)
/// - "Simulate App Switch" button for demo purposes
/// - Auto-navigation to AlertScreen when score > 60
///
/// Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 4.1, 8.1, 8.2
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if we need to navigate to AlertScreen
    // This runs after the widget is built, so we can safely navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNavigationToAlert();
    });
  }

  /// Checks if the score exceeds threshold and navigates to AlertScreen.
  ///
  /// This method is called after each build to check if auto-navigation
  /// should occur when the overload score exceeds 60.
  ///
  /// Validates: Requirements 4.1, 8.2
  void _checkNavigationToAlert() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (appState.currentScore > 60) {
      // Navigate to AlertScreen
      Navigator.of(context).pushNamed(
        '/alert',
        arguments: appState.currentScore,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Otium'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message with enhanced styling
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        'Monitor Your Cognitive Load',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Track your app usage and manage cognitive overload',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Cognitive Meter widget
                CognitiveMeter(
                  score: appState.currentScore,
                  classification: appState.classification,
                ),
                
                const SizedBox(height: 32),
                
                // Current metrics display with enhanced styling
                Card(
                  elevation: 4,
                  shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.analytics_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Current Metrics',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Unlocks metric
                          _buildMetricRow(
                            context,
                            icon: Icons.lock_open_rounded,
                            label: 'Device Unlocks',
                            value: appState.metrics.unlocks.toString(),
                            color: const Color(0xFF4A90A4),
                          ),
                          const SizedBox(height: 16),
                          
                          // App switches metric
                          _buildMetricRow(
                            context,
                            icon: Icons.swap_horiz_rounded,
                            label: 'App Switches',
                            value: appState.metrics.appSwitches.toString(),
                            color: const Color(0xFF7FB069),
                          ),
                          const SizedBox(height: 16),
                          
                          // Night minutes metric
                          _buildMetricRow(
                            context,
                            icon: Icons.nightlight_round,
                            label: 'Night Minutes',
                            value: appState.metrics.nightMinutes.toString(),
                            color: const Color(0xFF9C88FF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Simulate App Switch button with enhanced styling
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.simulateAppSwitch();
                      // Check navigation after state update
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _checkNavigationToAlert();
                      });
                    },
                    icon: const Icon(Icons.phone_android_rounded, size: 28),
                    label: const Text(
                      'Simulate App Switch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0, // Remove default elevation since we have custom shadow
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Info text with enhanced styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap the button to simulate app switching behavior and increase your cognitive load metrics.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a row displaying a single metric with icon, label, and value.
  ///
  /// Parameters:
  /// - [context]: Build context
  /// - [icon]: Icon to display
  /// - [label]: Metric label text
  /// - [value]: Metric value text
  /// - [color]: Color for the icon
  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
