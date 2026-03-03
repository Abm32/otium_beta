import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/app_state.dart';

/// Premium settings screen with real sensing controls and app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real Sensing Section
                  _buildSectionHeader('Real Sensing', Icons.sensors_rounded),
                  const SizedBox(height: 16),
                  _buildRealSensingCard(appState),
                  
                  const SizedBox(height: 32),
                  
                  // Monitoring Section
                  _buildSectionHeader('Monitoring', Icons.monitor_heart_rounded),
                  const SizedBox(height: 16),
                  _buildMonitoringCard(appState),
                  
                  const SizedBox(height: 32),
                  
                  // Statistics Section
                  _buildSectionHeader('Statistics', Icons.analytics_rounded),
                  const SizedBox(height: 16),
                  _buildStatisticsCard(appState),
                  
                  const SizedBox(height: 32),
                  
                  // About Section
                  _buildSectionHeader('About', Icons.info_rounded),
                  const SizedBox(height: 16),
                  _buildAboutCard(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90A4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF4A90A4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildRealSensingCard(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Real Sensing Toggle
          _buildSettingTile(
            icon: Icons.psychology_rounded,
            title: 'Real Device Sensing',
            subtitle: appState.useRealSensing 
                ? 'Using actual device usage data'
                : 'Using simulated data for demo',
            trailing: Switch.adaptive(
              value: appState.useRealSensing,
              onChanged: (value) async {
                if (value && !appState.useRealSensing) {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Initializing real sensing...'),
                        ],
                      ),
                    ),
                  );
                  
                  try {
                    await appState.initializeRealSensing();
                    if (mounted) Navigator.pop(context);
                    
                    if (!appState.useRealSensing && mounted) {
                      // Show permission dialog if initialization failed
                      _showPermissionDialog();
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      _showPermissionDialog();
                    }
                  }
                } else {
                  appState.toggleSensingMode();
                }
              },
              activeColor: const Color(0xFF4A90A4),
            ),
            isFirst: true,
          ),
          
          if (appState.useRealSensing) ...[
            const Divider(height: 1, indent: 60),
            
            // Sensing Status
            _buildInfoTile(
              icon: Icons.check_circle_rounded,
              title: 'Sensing Status',
              subtitle: 'Active • Last updated ${_formatLastUpdate(appState.lastRealSensingUpdate)}',
              iconColor: const Color(0xFF10B981),
            ),
            
            const Divider(height: 1, indent: 60),
            
            // Refresh Button
            _buildActionTile(
              icon: Icons.refresh_rounded,
              title: 'Refresh Metrics',
              subtitle: 'Get latest device usage data',
              onTap: () async {
                await appState.refreshMetricsFromRealSensing();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Metrics refreshed'),
                      backgroundColor: const Color(0xFF4A90A4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              isLast: true,
            ),
          ] else ...[
            const Divider(height: 1, indent: 60),
            
            _buildInfoTile(
              icon: Icons.info_rounded,
              title: 'Demo Mode',
              subtitle: 'Tap "Simulate App Switch" to increase overload',
              iconColor: const Color(0xFFF59E0B),
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonitoringCard(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Background Monitoring Toggle
          _buildSettingTile(
            icon: Icons.schedule_rounded,
            title: 'Background Monitoring',
            subtitle: appState.backgroundMonitoringEnabled
                ? 'Checking overload every 30 minutes'
                : 'Manual monitoring only',
            trailing: Switch.adaptive(
              value: appState.backgroundMonitoringEnabled,
              onChanged: appState.useRealSensing
                  ? (value) async {
                      try {
                        await appState.setBackgroundMonitoring(value);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value 
                                  ? 'Background monitoring enabled'
                                  : 'Background monitoring disabled'),
                              backgroundColor: const Color(0xFF4A90A4),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to ${value ? 'enable' : 'disable'} background monitoring'),
                              backgroundColor: const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              activeColor: const Color(0xFF4A90A4),
            ),
            isFirst: true,
          ),
          
          if (!appState.useRealSensing) ...[
            const Divider(height: 1, indent: 60),
            
            _buildInfoTile(
              icon: Icons.warning_rounded,
              title: 'Real Sensing Required',
              subtitle: 'Enable real sensing to use background monitoring',
              iconColor: const Color(0xFFF59E0B),
              isLast: true,
            ),
          ] else if (appState.backgroundMonitoringEnabled) ...[
            const Divider(height: 1, indent: 60),
            
            _buildInfoTile(
              icon: Icons.battery_saver_rounded,
              title: 'Battery Optimized',
              subtitle: 'Designed for <2% daily battery impact',
              iconColor: const Color(0xFF10B981),
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current Metrics
          _buildInfoTile(
            icon: Icons.analytics_rounded,
            title: 'Current Overload Score',
            subtitle: '${appState.currentScore.toStringAsFixed(1)} • ${appState.classification}',
            iconColor: _getScoreColor(appState.currentScore),
            isFirst: true,
          ),
          
          const Divider(height: 1, indent: 60),
          
          // Data Source
          _buildInfoTile(
            icon: appState.useRealSensing ? Icons.smartphone_rounded : Icons.play_circle_rounded,
            title: 'Data Source',
            subtitle: appState.sensingMode,
            iconColor: appState.useRealSensing ? const Color(0xFF4A90A4) : const Color(0xFF6B7280),
          ),
          
          if (appState.useRealSensing) ...[
            const Divider(height: 1, indent: 60),
            
            // Intervention Stats
            FutureBuilder<Map<String, dynamic>?>(
              future: appState.getInterventionStats(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final stats = snapshot.data!;
                  return _buildInfoTile(
                    icon: Icons.self_improvement_rounded,
                    title: 'Today\'s Interventions',
                    subtitle: '${stats['interventionsToday']} completed • ${stats['remainingToday']} remaining',
                    iconColor: const Color(0xFF8B5CF6),
                  );
                }
                return _buildInfoTile(
                  icon: Icons.self_improvement_rounded,
                  title: 'Today\'s Interventions',
                  subtitle: 'Loading...',
                  iconColor: const Color(0xFF8B5CF6),
                );
              },
            ),
          ],
          
          const Divider(height: 1, indent: 60),
          
          // View History
          _buildActionTile(
            icon: Icons.history_rounded,
            title: 'View History',
            subtitle: 'See your overload trends over time',
            onTap: () {
              // TODO: Navigate to history screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('History view coming soon'),
                  backgroundColor: const Color(0xFF4A90A4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.favorite_rounded,
            title: 'Otium',
            subtitle: 'Digital wellness through cognitive overload detection',
            iconColor: const Color(0xFFEF4444),
            isFirst: true,
          ),
          
          const Divider(height: 1, indent: 60),
          
          _buildInfoTile(
            icon: Icons.security_rounded,
            title: 'Privacy First',
            subtitle: 'All data stays on your device',
            iconColor: const Color(0xFF10B981),
          ),
          
          const Divider(height: 1, indent: 60),
          
          _buildInfoTile(
            icon: Icons.code_rounded,
            title: 'Version',
            subtitle: '1.0.0 (Phase 1)',
            iconColor: const Color(0xFF6B7280),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90A4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF4A90A4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90A4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF4A90A4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdate(DateTime? lastUpdate) {
    if (lastUpdate == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getScoreColor(double score) {
    if (score < 30) return const Color(0xFF10B981); // Green
    if (score <= 60) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Otium needs access to usage statistics to detect real cognitive overload patterns.\n\n'
          'This permission allows the app to:\n'
          '• Monitor app switching frequency\n'
          '• Track screen time sessions\n'
          '• Detect night usage patterns\n\n'
          'All data stays on your device and is never shared.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
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
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}