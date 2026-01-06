import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Using Rewarded Interstitial ID for Interstitial requests as well, per user mapping
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7841436065695087/8046193084';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7841436065695087/2751302671';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-7841436065695087/8429142945';
    if (Platform.isIOS) return 'ca-app-pub-7841436065695087/9411052120';
    throw UnsupportedError('Unsupported platform');
  }

  // Rewarded Ad Removed

  static String get rewardedInterstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-7841436065695087/8046193084';
    if (Platform.isIOS) return 'ca-app-pub-7841436065695087/2751302671';
    throw UnsupportedError('Unsupported platform');
  }

  // Banner ads are not in the new strategy, but keeping fallback or removing?
  // User didn't provide banner ID. Using Native ID or Test ID placeholder if absolutely needed.
  // Ideally, we shouldn't use Banners anymore as per "Institutional" strategy.
  // Leaving a placeholder to prevent compile errors if referenced, but recommending removal later.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID (Fallback)
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID (Fallback)
    }
  }

  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }
}
