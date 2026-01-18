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

  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }
}
