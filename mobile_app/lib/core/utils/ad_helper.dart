import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Using Rewarded Interstitial ID for Interstitial requests as well, per user mapping
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      // Test ID for Rewarded Interstitial (Android/iOS)
      // Note: AdMob has specific test IDs for different formats.
      // This is the Rewarded Interstitial Test ID.
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5354046379';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/6978759866';
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-7841436065695087/8046193084';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7841436065695087/2751302671';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get appOpenAdUnitId {
    if (kDebugMode) {
      // Test ID for App Open
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/3419835294';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/5662855259';
    }

    if (Platform.isAndroid) return 'ca-app-pub-7841436065695087/8429142945';
    if (Platform.isIOS) return 'ca-app-pub-7841436065695087/9411052120';
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedInterstitialAdUnitId {
    if (kDebugMode) {
      // Test ID for Rewarded Interstitial
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5354046379';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/6978759866';
    }

    if (Platform.isAndroid) return 'ca-app-pub-7841436065695087/8046193084';
    if (Platform.isIOS) return 'ca-app-pub-7841436065695087/2751302671';
    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }
}
