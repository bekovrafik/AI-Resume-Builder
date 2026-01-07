import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Using Rewarded Interstitial ID for Interstitial requests as well, per user mapping
  static String get interstitialAdUnitId {
    // User provided Reward ID, mapping to interstitial if used interchangeably or using specific if user meant Interstitial.
    // However, typically Interstitial and Reward are different.
    // The user list says "Reward". The previous code mapped Reward to this getter.
    // We will update it to match the "Reward" ID provided.
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

  static String get rewardedInterstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-7841436065695087/8046193084';
    if (Platform.isIOS) return 'ca-app-pub-7841436065695087/2751302671';
    throw UnsupportedError('Unsupported platform');
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-7841436065695087/9235808214';
    if (Platform.isIOS) return 'ca-app-pub-7841436065695087/1492393022';
    throw UnsupportedError('Unsupported platform');
  }

  // Banner ads: Replaced by Native in strategy, but keeping placeholder or using Native?
  // User didn't provide Banner ID. Keeping fallback setup or returning Native if appropriate?
  // We'll keep the test ID for Banner to avoid breaking older widgets if they exist,
  // but adding a comment.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
  }

  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }
}
