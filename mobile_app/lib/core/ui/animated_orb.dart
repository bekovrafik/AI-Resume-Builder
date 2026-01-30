import 'package:flutter/material.dart';

class AnimatedOrb extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final Offset offset; // Max offset for movement

  const AnimatedOrb({
    super.key,
    this.color = const Color(0xFFEAB308), // Default yellow
    this.size = 200,
    this.duration = const Duration(seconds: 5),
    this.offset = const Offset(30, 30),
  });

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: _animation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Optimization: BoxShadow with large blur is expensive.
            // Using RadialGradient simulates the glow effect much cheaper.
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: 0.6),
                widget.color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}
