import 'package:flutter/material.dart';

import 'animated_orb.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool withOrbs;

  const GradientBackground({
    super.key,
    required this.child,
    this.withOrbs = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on Theme or static AppColors
    // For now using static colors to match React design
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF073b4c) : Colors.white; // React 'midnightNavy'

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Color/Gradient
          Positioned.fill(
            child: Container(
              color: bgColor,
            ),
          ),

          // Glowing Orbs
          if (withOrbs) ...[
            // Top Left Orb
            Positioned(
              top: -50,
              left: -50,
              child: AnimatedOrb(
                color: isDark
                    ? const Color(0xFFCA8A04).withOpacity(0.15) // Darker Gold
                    : const Color(0xFFEAB308).withOpacity(0.1), // Gold
                size: 300,
                offset: const Offset(0.1, 0.1), // Small movement
                duration: const Duration(seconds: 6),
              ),
            ),
            // Bottom Right Orb
            Positioned(
              bottom: -50,
              right: -50,
              child: AnimatedOrb(
                color: isDark
                    ? const Color(0xFFCA8A04).withOpacity(0.1)
                    : const Color(0xFFEAB308).withOpacity(0.15),
                size: 350,
                offset: const Offset(-0.1, -0.1),
                duration: const Duration(seconds: 8),
              ),
            ),
          ],

          // Main Content
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}
