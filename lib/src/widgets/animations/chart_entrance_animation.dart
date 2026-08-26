import 'package:flutter/material.dart';

/// Animated entrance for chart widgets with fade and scale effect
class ChartEntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ChartEntranceAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<ChartEntranceAnimation> createState() => _ChartEntranceAnimationState();
}

class _ChartEntranceAnimationState extends State<ChartEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
