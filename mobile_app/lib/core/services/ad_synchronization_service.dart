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

  bool _hasShownAd = false;
  // bool _isShowingAd = false; // logic simplified for single-show
  // DateTime? _lastAdShowTime; // Removed per user request

  void showAppOpenAdIfAvailable() {
    // 1. One-time only check
    if (_hasShownAd) return;

    // 2. Check if ad is already showing (safety)
    // if (_isShowingAd) return;

    // 3. Check if ad is available
    if (!_isAppOpenAdAvailable || _appOpenAd == null) {
      loadAppOpenAd();
      return;
    }

    // _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        // _isShowingAd = false;
        ad.dispose();
        // Do NOT load next ad since we only show once
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        // _isShowingAd = false;
        ad.dispose();
        // If failed, maybe we allow retry?
        // For 'strictly once', maybe we don't retry if it failed to *show*?
        // usually failing to show means we should try again or just give up.
        // Let's assume we allow retry if it completely failed to present content?
        // But user said "just once". I'll reset _hasShownAd to false if it failed?
        // No, let's keep it simple. If it tries to show, we count it.
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
    _isAppOpenAdAvailable = false;
    _hasShownAd = true;
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
