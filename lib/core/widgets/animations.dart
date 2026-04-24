import 'package:flutter/material.dart';

/// Smooth page transition animation (fade + slide)
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final AxisDirection axisDirection;

  SmoothPageTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.axisDirection = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: _getOffset(axisDirection),
              end: Offset.zero,
            );
            final offsetAnimation = animation.drive(
              tween.chain(CurveTween(curve: curve)),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
        );

  static Offset _getOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.right:
        return const Offset(-0.3, 0);
      case AxisDirection.left:
        return const Offset(0.3, 0);
      case AxisDirection.down:
        return const Offset(0, -0.3);
      case AxisDirection.up:
        return const Offset(0, 0.3);
    }
  }
}

/// Fade transition animation
class FadeTransitionPage extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  FadeTransitionPage({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

/// Smooth scale transition
class ScaleTransitionPage extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ScaleTransitionPage({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: 0.0, end: 1.0);
            final scaleTween = animation.drive(
              tween.chain(CurveTween(curve: Curves.easeOutBack)),
            );

            return ScaleTransition(
              scale: scaleTween,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
}

/// Animation builder for staggered animations
class StaggeredAnimationBuilder extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Axis direction;

  const StaggeredAnimationBuilder({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 500),
    this.delay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredAnimationBuilder> createState() =>
      _StaggeredAnimationBuilderState();
}

class _StaggeredAnimationBuilderState extends State<StaggeredAnimationBuilder>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (i) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers
        .asMap()
        .entries
        .map(
          (entry) => Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: entry.value, curve: widget.curve)),
        )
        .toList();

    Future.delayed(Duration.zero, () {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(widget.delay * i, () {
          if (mounted) {
            _controllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(
            children: List.generate(
              widget.children.length,
              (i) => FadeTransition(
                opacity: _animations[i],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_animations[i]),
                  child: widget.children[i],
                ),
              ),
            ),
          )
        : Row(
            children: List.generate(
              widget.children.length,
              (i) => FadeTransition(
                opacity: _animations[i],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(_animations[i]),
                  child: widget.children[i],
                ),
              ),
            ),
          );
  }
}

/// Animated counter for smooth number transitions
class AnimatedCounter extends StatefulWidget {
  final int end;
  final Duration duration;
  final TextStyle? textStyle;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.end,
    this.duration = const Duration(milliseconds: 1000),
    this.textStyle,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(
      begin: 0,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.textStyle,
        );
      },
    );
  }
}
