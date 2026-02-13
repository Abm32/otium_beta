import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otium/widgets/cognitive_meter.dart';

void main() {
  group('CognitiveMeter Widget Tests', () {
    testWidgets('renders with low score (Calm)', (WidgetTester tester) async {
      // Arrange
      const score = 15.0;
      const classification = 'Calm';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cognitive Load'), findsOneWidget);
      expect(find.text('15.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places
      
      // Verify the circular progress indicator exists
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2)); // Background + progress
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with moderate score', (WidgetTester tester) async {
      // Arrange
      const score = 45.5;
      const classification = 'Moderate';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cognitive Load'), findsOneWidget);
      expect(find.text('45.5'), findsOneWidget);
      expect(find.text('Moderate'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('renders with high score (High Overload)', (WidgetTester tester) async {
      // Arrange
      const score = 75.0;
      const classification = 'High Overload';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cognitive Load'), findsOneWidget);
      expect(find.text('75.0'), findsOneWidget);
      expect(find.text('High Overload'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('renders with zero score', (WidgetTester tester) async {
      // Arrange
      const score = 0.0;
      const classification = 'Calm';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0.0'), findsOneWidget);
      expect(find.text('Calm'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('renders with maximum score', (WidgetTester tester) async {
      // Arrange
      const score = 100.0;
      const classification = 'High Overload';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('100.0'), findsOneWidget);
      expect(find.text('High Overload'), findsAtLeastNWidgets(1)); // May appear in multiple places
    });

    testWidgets('renders with score above 100 (clamped)', (WidgetTester tester) async {
      // Arrange
      const score = 150.0;
      const classification = 'High Overload';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert - should display the score but progress should be clamped to 100%
      expect(find.text('150.0'), findsOneWidget);
      expect(find.text('High Overload'), findsAtLeastNWidgets(1)); // May appear in multiple places
      
      // Verify the widget renders without errors
      expect(find.byType(CognitiveMeter), findsOneWidget);
    });

    testWidgets('color changes based on classification - Calm', (WidgetTester tester) async {
      // Arrange
      const score = 20.0;
      const classification = 'Calm';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert - verify widget renders (color testing is visual, hard to test directly)
      expect(find.byType(CognitiveMeter), findsOneWidget);
      
      // Find the progress indicators
      final progressIndicators = tester.widgetList<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      // The second one should be the progress indicator with color
      final progressIndicator = progressIndicators.elementAt(1);
      expect(progressIndicator.valueColor, isA<AlwaysStoppedAnimation<Color>>());
      
      final colorAnimation = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnimation.value, Colors.green);
    });

    testWidgets('color changes based on classification - Moderate', (WidgetTester tester) async {
      // Arrange
      const score = 45.0;
      const classification = 'Moderate';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CognitiveMeter), findsOneWidget);
      
      final progressIndicators = tester.widgetList<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      final progressIndicator = progressIndicators.elementAt(1);
      final colorAnimation = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnimation.value, Colors.orange);
    });

    testWidgets('color changes based on classification - High Overload', (WidgetTester tester) async {
      // Arrange
      const score = 75.0;
      const classification = 'High Overload';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveMeter(
              score: score,
              classification: classification,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CognitiveMeter), findsOneWidget);
      
      final progressIndicators = tester.widgetList<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      final progressIndicator = progressIndicators.elementAt(1);
      final colorAnimation = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnimation.value, Colors.red);
    });
  });
}
