import 'package:flutter/material.dart';

/// An animated widget that guides users through breathing exercises.
///
/// This widget displays a circle that expands and contracts in a 4-second cycle
/// (2 seconds expand, 2 seconds contract) to provide visual breathing guidance.
/// The animation uses smooth easing curves for a calming effect.
///
/// Validates: Requirements 5.2, 5.3, 5.4, 9.2, 9.4
class BreathingCircle extends StatefulWidget {
  /// Whether the circle should be in the inhaling (expanding) phase
  final bool isInhaling;

  const BreathingCircle({
    Key? key,
    required this.isInhaling,
  }) : super(key: key);

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  // Size constants for the breathing circle
  static const double _minSize = 120.0;
  static const double _maxSize = 240.0;

  @override
  void initState() {
    super.initState();

    // Create animation controller with 2-second duration (half of the 4-second cycle)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create size animation with smooth easing curve
    _sizeAnimation = Tween<double>(
      begin: _minSize,
      end: _maxSize,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth easing for calming effect
      ),
    );

    // Start the animation based on initial isInhaling state
    _updateAnimation();
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation when isInhaling parameter changes
    if (oldWidget.isInhaling != widget.isInhaling) {
      _updateAnimation();
    }
  }

  /// Updates the animation direction based on the isInhaling parameter
  void _updateAnimation() {
    if (widget.isInhaling) {
      // Expand: animate from current position to max size
      _controller.forward(from: _controller.value);
    } else {
      // Contract: animate from current position to min size
      _controller.reverse(from: _controller.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sizeAnimation,
      builder: (context, child) {
        return Container(
          width: 300,
          height: 300,
          alignment: Alignment.center,
          child: Container(
            width: _sizeAnimation.value,
            height: _sizeAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4A90A4).withValues(alpha: 0.3),
                  const Color(0xFF4A90A4).withValues(alpha: 0.6),
                  const Color(0xFF4A90A4).withValues(alpha: 0.8),
                  const Color(0xFF2C5F6F),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                // Inner glow
                BoxShadow(
                  color: const Color(0xFF4A90A4).withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
                // Outer glow
                BoxShadow(
                  color: const Color(0xFF4A90A4).withValues(alpha: 0.2),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: _sizeAnimation.value * 0.3,
                  height: _sizeAnimation.value * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90A4).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
