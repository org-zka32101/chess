import 'package:flutter/material.dart';

/// Animation and page transition utilities for Chess Tactics Master
class AnimationTransitions {
  // Private constructor to prevent instantiation
  AnimationTransitions._();

  // ============================================================
  // Page Transitions
  // ============================================================

  /// Fade transition for pages
  static Route<T> fadeTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: duration,
    );
  }

  /// Slide transition for pages (left to right)
  static Route<T> slideTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
    Axis direction = Axis.horizontal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        if (direction == Axis.horizontal) {
          begin = const Offset(1.0, 0.0);
        } else {
          begin = const Offset(0.0, 1.0);
        }

        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Scale transition for pages
  static Route<T> scaleTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        final tween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Combined fade and slide transition
  static Route<T> fadeSlideTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        // Slide animation
        final slideBegin = Offset(0.3, 0.0);
        final slideTween = Tween(begin: slideBegin, end: Offset.zero)
            .chain(CurveTween(curve: curve));
        final slideAnimation = animation.drive(slideTween);

        // Fade animation
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: curve));
        final fadeAnimation = animation.drive(fadeTween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // ============================================================
  // Micro-interactions
  // ============================================================

  /// Animated button press (scale animation)
  static Widget createAnimatedPressButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration pressDuration = const Duration(milliseconds: 150),
  }) {
    return _AnimatedPressButton(
      onPressed: onPressed,
      duration: pressDuration,
      child: child,
    );
  }

  /// Animated icon button with rotation
  static Widget createRotatingIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Duration rotateDuration = const Duration(milliseconds: 600),
  }) {
    return _RotatingIconButton(
      icon: icon,
      onPressed: onPressed,
      duration: rotateDuration,
    );
  }

  /// Animated scale on tap
  static Widget createTapScaleAnimation({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = const Duration(milliseconds: 200),
    double minScale = 0.9,
    double maxScale = 1.0,
  }) {
    return _TapScaleAnimation(
      onTap: onTap,
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
      child: child,
    );
  }

  /// Animated slide-in from bottom
  static Widget createSlideInAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
  }) {
    return _SlideInAnimation(
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// Animated bounce effect
  static Widget createBounceAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return _BounceAnimation(
      duration: duration,
      child: child,
    );
  }
}

// ============================================================
// Private Animation Widgets
// ============================================================

class _AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  const _AnimatedPressButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });

  @override
  State<_AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<_AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _RotatingIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Duration duration;

  const _RotatingIconButton({
    required this.icon,
    required this.onPressed,
    required this.duration,
  });

  @override
  State<_RotatingIconButton> createState() => _RotatingIconButtonState();
}

class _RotatingIconButtonState extends State<_RotatingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  void _handlePress() {
    _controller.forward(from: 0.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: _handlePress,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TapScaleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const _TapScaleAnimation({
    required this.child,
    required this.onTap,
    required this.duration,
    required this.minScale,
    required this.maxScale,
  });

  @override
  State<_TapScaleAnimation> createState() => _TapScaleAnimationState();
}

class _TapScaleAnimationState extends State<_TapScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.maxScale,
      end: widget.minScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _SlideInAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<_SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _BounceAnimation({
    required this.child,
    required this.duration,
  });

  @override
  State<_BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<_BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
