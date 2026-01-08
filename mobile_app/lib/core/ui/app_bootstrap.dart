import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/ad_synchronization_service.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';

/// A widget that initializes the app and waits for the App Open Ad.
/// This prevents the "pop-in" effect by showing a splash screen until
/// the ad is ready or a timeout occurs.
class AppBootstrap extends ConsumerStatefulWidget {
  final Widget child;

  const AppBootstrap({super.key, required this.child});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final adService = ref.read(adSynchronizationProvider);

    // 1. Start loading the ad.
    // We race the ad load against a 3-second timeout.
    // If timeout wins, we proceed. If ad wins, we show it (if available).
    try {
      await adService.loadAppOpenAd().timeout(const Duration(seconds: 4));
    } catch (_) {
      // Timeout or error, just proceed
    }

    // 2. Determine if ad is available
    // The service handles setting the internal state.
    // Now trigger the show logic if available.
    adService.showAppOpenAdIfAvailable();

    // 3. Mark as ready to show the app
    // We add a small delay if ad was shown?
    // No, showAppOpenAdIfAvailable is synchronous trigger but the ad overlay is separate.
    // If ad shows, it covers the screen.
    // We can just switch _isReady to true now.
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return widget.child;
    }

    // Custom Splash Screen while waiting for Ad
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.midnightNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.strategicGold,
                ),
                child: const Icon(Icons.psychology,
                    size: 60, color: AppColors.midnightNavy),
              ),
              const SizedBox(height: 24),
              Text(
                "AI RESUME",
                style: AppTypography.header1.copyWith(
                  color: Colors.white,
                  letterSpacing: 4.0,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "CAREER FORGE",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.strategicGold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: AppColors.strategicGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
