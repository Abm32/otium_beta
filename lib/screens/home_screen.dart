import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/app_state.dart';
import '../widgets/cognitive_meter.dart';
import 'settings_screen.dart';

/// Premium home screen with real sensing integration and enhanced UI
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
    
    // Initialize real sensing on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (!appState.useRealSensing) {
        _showRealSensingPrompt();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if we need to navigate to AlertScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNavigationToAlert();
    });
  }

  void _showRealSensingPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90A4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Color(0xFF4A90A4),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Enable Real Sensing?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Otium can detect real cognitive overload using your device usage patterns. This provides more accurate insights than simulated data.\n\nAll data stays on your device.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.initializeRealSensing();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90A4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _checkNavigationToAlert() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (appState.currentScore > 60) {
      Navigator.of(context).pushNamed(
        '/alert',
        arguments: appState.currentScore,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return CustomScrollView(
            slivers: [
              // Premium App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A90A4),
                          Color(0xFF7FB069),
                        ],
                      ),
                    ),
                  ),
                  title: const Text(
                    'Otium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_rounded, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        _buildStatusCard(appState),
                        
                        const SizedBox(height: 24),
                        
                        // Cognitive Meter
                        _buildCognitiveMeterCard(appState),
                        
                        const SizedBox(height: 24),
                        
                        // Metrics Grid
                        _buildMetricsGrid(appState),
                        
                        const SizedBox(height: 24),
                        
                        // Action Button
                        _buildActionButton(appState),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appState.useRealSensing 
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              appState.useRealSensing ? Icons.sensors_rounded : Icons.play_circle_rounded,
              color: appState.useRealSensing 
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.useRealSensing ? 'Real Sensing Active' : 'Demo Mode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appState.useRealSensing
                      ? 'Monitoring your device usage patterns'
                      : 'Using simulated data for demonstration',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (appState.useRealSensing)
            IconButton(
              onPressed: () => appState.refreshMetricsFromRealSensing(),
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF4A90A4),
              ),
              tooltip: 'Refresh metrics',
            ),
        ],
      ),
    );
  }

  Widget _buildCognitiveMeterCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90A4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF4A90A4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cognitive Load Monitor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: _pulseAnimation,
            child: CognitiveMeter(
              score: appState.currentScore,
              classification: appState.classification,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90A4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Color(0xFF4A90A4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Usage Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.lock_open_rounded,
                label: 'Unlocks',
                value: appState.metrics.unlocks.toString(),
                color: const Color(0xFF4A90A4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.swap_horiz_rounded,
                label: 'App Switches',
                value: appState.metrics.appSwitches.toString(),
                color: const Color(0xFF7FB069),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          icon: Icons.nightlight_round,
          label: 'Night Usage (minutes)',
          value: appState.metrics.nightMinutes.toString(),
          color: const Color(0xFF8B5CF6),
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton(AppState appState) {
    if (appState.useRealSensing) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Real sensing is monitoring your device usage patterns automatically.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF065F46),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A90A4),
            Color(0xFF7FB069),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90A4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          appState.simulateAppSwitch();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkNavigationToAlert();
          });
        },
        icon: const Icon(Icons.phone_android_rounded, size: 24, color: Colors.white),
        label: const Text(
          'Simulate App Switch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
