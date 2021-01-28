
import 'package:firebase_admob/firebase_admob.dart';
// InterstitialAd _interstitialAd;

String testBannerAdId = BannerAd.testAdUnitId;
String testInterstitialAdId = InterstitialAd.testAdUnitId;
String testAppId = FirebaseAdMob.testAppId;

void showAds(int index) {
  if (index == 2) {
    createInterstitialAd()..load()..show();
  }
}

BannerAd createBannerAd() {
  return BannerAd(
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.banner,
    listener: (MobileAdEvent event) {
      print("BannerAd event $event");
    },
  );
}

InterstitialAd createInterstitialAd() {
  return InterstitialAd(
    adUnitId: InterstitialAd.testAdUnitId,
    listener: (MobileAdEvent event) {
      print("InterstitialAd event $event");
    },
  );
}