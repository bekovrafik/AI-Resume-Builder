import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_app/core/utils/ad_helper.dart';

final adSynchronizationProvider = Provider<AdSynchronizationService>((ref) {
  return AdSynchronizationService(autoStart: true);
});

class AdSynchronizationService {
  AppOpenAd? _appOpenAd;
  // RewardedAd? _rewardedAd; // Removed
  RewardedInterstitialAd? _rewardedInterstitialAd;

  bool _isAppOpenAdAvailable = false;
  // bool _isRewardedAdAvailable = false; // Removed
  bool _isRewardedInterstitialAdAvailable = false;

  AdSynchronizationService({bool autoStart = true}) {
    if (autoStart) _initPreloading();
  }

  void _initPreloading() {
    // Initial pre-load of all high-value units
    loadAppOpenAd();
    // loadRewardedAd(); // Removed
    loadRewardedInterstitialAd();
  }

  // --- App Open Ad (Warm Start) ---
  Future<void> loadAppOpenAd() {
    final completer = Completer<void>();
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdAvailable = true;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdAvailable = false;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  void showAppOpenAdIfAvailable() {
    if (_isAppOpenAdAvailable && _appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAppOpenAd(); // Pre-load next
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadAppOpenAd();
        },
      );
      _appOpenAd!.show();
      _appOpenAd = null;
      _isAppOpenAdAvailable = false;
    } else {
      loadAppOpenAd();
    }
  }

  // --- Rewarded Ad Removed per configuration ---

  // --- Rewarded Interstitial (Resume Build / PDF) ---
  void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.rewardedInterstitialAdUnitId, // Need to add
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedInterstitialAdAvailable = false;
        },
      ),
    );
  }

  void showRewardedInterstitialAd(
      {required Function(RewardItem) onUserEarnedReward}) {
    if (_isRewardedInterstitialAdAvailable && _rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedInterstitialAd();
        },
      );
      _rewardedInterstitialAd!
          .show(onUserEarnedReward: (ad, reward) => onUserEarnedReward(reward));
      _rewardedInterstitialAd = null;
      _isRewardedInterstitialAdAvailable = false;
    } else {
      loadRewardedInterstitialAd();
    }
  }
}
