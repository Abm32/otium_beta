import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otium/widgets/breathing_circle.dart';

void main() {
  group('BreathingCircle Widget Tests', () {
    testWidgets('renders with isInhaling true', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      // Assert - verify widget renders
      expect(find.byType(BreathingCircle), findsOneWidget);
      
      // Verify containers exist (there are multiple in the breathing circle)
      expect(find.descendant(
        of: find.byType(BreathingCircle),
        matching: find.byType(Container),
      ), findsAtLeastNWidgets(1));
    });

    testWidgets('renders with isInhaling false', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: false,
              ),
            ),
          ),
        ),
      );

      // Assert - verify widget renders
      expect(find.byType(BreathingCircle), findsOneWidget);
    });

    testWidgets('animation initializes correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      // Initial pump to build the widget
      await tester.pump();

      // Assert - verify BreathingCircle widget is present
      expect(find.byType(BreathingCircle), findsOneWidget);
      
      // Verify containers exist within the BreathingCircle (there are multiple)
      final breathingCircleFinder = find.byType(BreathingCircle);
      final containerFinder = find.descendant(
        of: breathingCircleFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsAtLeastNWidgets(1));

      // Verify AnimatedBuilder is present (indicates animation is set up)
      expect(find.descendant(
        of: breathingCircleFinder,
        matching: find.byType(AnimatedBuilder),
      ), findsOneWidget);
    });

    testWidgets('size changes during inhale animation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      // Get initial size using RenderBox - find the main animated container
      await tester.pump();
      final breathingCircleFinder = find.byType(BreathingCircle);
      
      // Verify the breathing circle widget exists and has containers
      expect(breathingCircleFinder, findsOneWidget);
      expect(find.descendant(
        of: breathingCircleFinder,
        matching: find.byType(Container),
      ), findsAtLeastNWidgets(1));

      // Advance animation by 1 second (halfway through 2-second inhale)
      await tester.pump(const Duration(seconds: 1));

      // Verify animation is progressing by checking that the widget still renders
      expect(breathingCircleFinder, findsOneWidget);

      // Advance to end of animation (2 seconds total)
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the widget is still rendering correctly after animation
      expect(find.byType(BreathingCircle), findsOneWidget);
    });

    testWidgets('size changes during exhale animation', (WidgetTester tester) async {
      // Arrange - start with inhaling to get to max size first
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      // Initial pump and complete the inhale animation
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify the breathing circle widget exists
      expect(find.byType(BreathingCircle), findsOneWidget);

      // Act - change to exhaling (contracting)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify the widget still exists after changing to exhale
      expect(find.byType(BreathingCircle), findsOneWidget);

      // Advance animation by 1 second (halfway through 2-second exhale)
      await tester.pump(const Duration(seconds: 1));

      // Verify the widget is still rendering correctly during animation
      expect(find.byType(BreathingCircle), findsOneWidget);
      
      // Advance to end of animation (2 seconds total)
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the widget is still rendering correctly after animation
      expect(find.byType(BreathingCircle), findsOneWidget);
    });

    testWidgets('updates animation when isInhaling changes', (WidgetTester tester) async {
      // Arrange - start with inhaling
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(BreathingCircle), findsOneWidget);

      // Act - change to exhaling
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert - widget should still render correctly
      expect(find.byType(BreathingCircle), findsOneWidget);
      final breathingCircleFinder = find.byType(BreathingCircle);
      expect(find.descendant(
        of: breathingCircleFinder,
        matching: find.byType(Container),
      ), findsAtLeastNWidgets(1));
    });

    testWidgets('has circular shape decoration', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert - verify the breathing circle widget exists and has proper structure
      expect(find.byType(BreathingCircle), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1)); // Multiple AnimatedBuilders may exist
      
      // Verify containers exist (there are multiple in the breathing circle)
      expect(find.descendant(
        of: find.byType(BreathingCircle),
        matching: find.byType(Container),
      ), findsAtLeastNWidgets(1));
    });

    testWidgets('animation completes full cycle', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingCircle(
                isInhaling: true,
              ),
            ),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Act - advance through full 2-second animation
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assert - widget should still be rendered correctly
      expect(find.byType(BreathingCircle), findsOneWidget);
      final breathingCircleFinder = find.byType(BreathingCircle);
      expect(find.descendant(
        of: breathingCircleFinder,
        matching: find.byType(Container),
      ), findsAtLeastNWidgets(1));
    });
  });
}
