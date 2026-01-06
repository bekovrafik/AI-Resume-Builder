import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManagerService {
  static final AdManagerService instance = AdManagerService._internal();

  AdManagerService._internal();

  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoading = false;
  DateTime? _unlockExpirationTime;

  // TEST ID for Rewarded Interstitial
  // Replace with real ID in production
  final String _adUnitId = 'ca-app-pub-3940256099942544/5354046379';

  void preloadAd() {
    if (_rewardedInterstitialAd != null || _isAdLoading) return;

    _isAdLoading = true;
    RewardedInterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdManager: Ad loaded.');
          _rewardedInterstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Ad failed to load: $error');
          _isAdLoading = false;
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
  }

  void showRewardedAd({
    required VoidCallback onReward,
    required VoidCallback onDismiss,
    required VoidCallback onError,
  }) {
    if (isExportUnlocked()) {
      onReward();
      return;
    }

    if (_rewardedInterstitialAd == null) {
      debugPrint(
          'AdManager: Ad not ready. Attempting to reload and failing over.');
      preloadAd();
      // Fallback: If ad isn't ready, you might want to let them pass or show error.
      // For better UX, we'll let them pass this time or show a specific error.
      // Here we'll treat it as an error to trigger the "try again" or fallback UI.
      onError();
      return;
    }

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
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
