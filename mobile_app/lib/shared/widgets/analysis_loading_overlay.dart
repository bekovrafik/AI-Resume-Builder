import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class AnalysisLoadingOverlay extends StatefulWidget {
  final String statusText;
  const AnalysisLoadingOverlay(
      {super.key,
      this.statusText = "Initiating High-Compute Architectural Synthesis..."});

  @override
  State<AnalysisLoadingOverlay> createState() => _AnalysisLoadingOverlayState();
}

class _AnalysisLoadingOverlayState extends State<AnalysisLoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.midnightNavy.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology,
                    size: 80, color: AppColors.strategicGold)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white),
            const SizedBox(height: 32),
            Text(
              widget.statusText,
              textAlign: TextAlign.center,
              style: AppTextStyles.headerSmall.copyWith(color: Colors.white),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: const LinearProgressIndicator(
                backgroundColor: AppColors.slateGrey,
                color: AppColors.strategicGold,
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(),
            ),
            const SizedBox(height: 16),
            Text(
              "Optimizing ATS Vectors...",
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
