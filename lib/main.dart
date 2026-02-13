import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const OtiumApp());
}

class OtiumApp extends StatelessWidget {
  const OtiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Otium',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90A4), // Calming teal-blue
            brightness: Brightness.light,
          ).copyWith(
            // Enhanced calming color palette
            primary: const Color(0xFF4A90A4),
            secondary: const Color(0xFF7FB069),
            surface: const Color(0xFFF8FFFE),
            surfaceContainerHighest: const Color(0xFFE8F4F8),
            onSurface: const Color(0xFF2C3E50),
            onSurfaceVariant: const Color(0xFF5A6C7D),
          ),
          useMaterial3: true,
          
          // Enhanced typography for better readability
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              letterSpacing: -1.5,
              color: Color(0xFF2C3E50),
            ),
            displayMedium: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
              color: Color(0xFF2C3E50),
            ),
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
              color: Color(0xFF2C3E50),
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: Color(0xFF2C3E50),
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: Color(0xFF2C3E50),
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: Color(0xFF2C3E50),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
              color: Color(0xFF2C3E50),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              color: Color(0xFF2C3E50),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
              color: Color(0xFF5A6C7D),
            ),
          ),
          
          // Enhanced card theme for consistent elevation and spacing
          cardTheme: CardTheme(
            elevation: 3,
            shadowColor: const Color(0xFF4A90A4).withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFFF8FFFE),
          ),
          
          // Enhanced button themes for better visual hierarchy
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90A4),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0xFF4A90A4).withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Enhanced app bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE8F4F8),
            foregroundColor: Color(0xFF2C3E50),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              letterSpacing: 0.15,
            ),
          ),
          
          // Enhanced progress indicator theme
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFF4A90A4),
            linearTrackColor: Color(0xFFE8F4F8),
            circularTrackColor: Color(0xFFE8F4F8),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/alert': (context) {
            final score = ModalRoute.of(context)?.settings.arguments as double;
            return AlertScreen(currentScore: score);
          },
          '/breathing': (context) => const BreathingScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
