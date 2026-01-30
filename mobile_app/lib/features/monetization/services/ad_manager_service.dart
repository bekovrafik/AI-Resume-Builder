import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_app/core/utils/ad_helper.dart';
import 'package:mobile_app/core/services/analytics_service.dart';

class AdManagerService {
  static final AdManagerService instance = AdManagerService._internal();

  AdManagerService._internal();

  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoading = false;
  DateTime? _unlockExpirationTime;

  // TEST ID for Rewarded Interstitial
  // Replace with real ID in production
  String get _adUnitId => AdHelper.rewardedInterstitialAdUnitId;

  void preloadAd() {
    if (_rewardedInterstitialAd != null || _isAdLoading) return;

    _isAdLoading = true;
    debugPrint('AdManager: Requesting new ad...');

    RewardedInterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdManager: Ad loaded.');
          _rewardedInterstitialAd = ad;
          _isAdLoading = false;
          AnalyticsService.logEvent(
              name: 'ad_loaded', parameters: {'type': 'rewarded_interstitial'});
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Ad failed to load: $error');
          _isAdLoading = false;
          AnalyticsService.logAdFailed(
              adUnitId: _adUnitId, error: error.message);
        },
      ),
    );
  }

  bool isExportUnlocked() {
    if (_unlockExpirationTime == null) return false;
    return DateTime.now().isBefore(_unlockExpirationTime!);
  }

  void _unlockExport() {
    _unlockExpirationTime = DateTime.now().add(const Duration(minutes: 30));
    debugPrint('AdManager: Export unlocked until $_unlockExpirationTime');
    AnalyticsService.logExportUnlocked();
  }

  Future<void> showRewardedAd({
    required VoidCallback onReward,
    required VoidCallback onDismiss,
    required VoidCallback onError,
  }) async {
    if (isExportUnlocked()) {
      onReward();
      return;
    }

    if (_rewardedInterstitialAd == null) {
      if (!_isAdLoading) {
        preloadAd(); // Start loading if not already
      }

      // Smart Wait: Poll for up to 3 seconds
      debugPrint('AdManager: Ad not ready. Waiting...');
      int attempts = 0;
      while (_rewardedInterstitialAd == null && attempts < 30) {
        // 30 * 100ms = 3s
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (_rewardedInterstitialAd == null) {
        debugPrint(
            'AdManager: Ad still not ready after waiting. Failing over.');
        AnalyticsService.logEvent(name: 'ad_timeout');
        onError();
        return;
      }
    }

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AnalyticsService.logAdImpression(
            adUnitId: _adUnitId, adType: 'rewarded_interstitial');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdManager: Ad dismissed.');
        ad.dispose();
        _rewardedInterstitialAd = null;
        preloadAd(); // Reload for next time
        onDismiss();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdManager: Ad failed to show: $error');
        ad.dispose();
        _rewardedInterstitialAd = null;
        preloadAd();
        AnalyticsService.logAdFailed(
            adUnitId: _adUnitId, error: "Show Error: ${error.message}");
        onError();
      },
    );

    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('AdManager: User earned reward.');
        _unlockExport();
        onReward();
      },
    );
  }
}
