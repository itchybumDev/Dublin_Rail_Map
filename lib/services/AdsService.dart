// InterstitialAd _interstitialAd;
import 'dart:io';

import 'package:dublin_rail_map/services/Const.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return bannerAdId;
    } else if (Platform.isIOS) {
      return iOsbannerAdId;
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return interstitialAdId;
    } else if (Platform.isIOS) {
      return iOsinterstitialAdId;
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}
