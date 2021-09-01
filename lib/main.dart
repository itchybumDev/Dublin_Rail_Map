import 'package:dublin_rail_map/page/MapPage.dart';
import 'package:dublin_rail_map/page/SearchPage.dart';
import 'package:dublin_rail_map/page/TweetsPage.dart';
import 'package:dublin_rail_map/services/AdsService.dart';
import 'package:dublin_rail_map/services/StationNameConst.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share/share.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Dublin Rail Map',
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(scaffoldBackgroundColor: backgroundColor),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  final int index;

  const MyApp({Key key, this.index}) : super(key: key);

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  int _selectedIndex = 0;
  final myController = TextEditingController();

  static const TextStyle optionStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w400);
  static List<Widget> _widgetOptions = <Widget>[SearchPage(), MapPage(), TweetsPage()];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showInterstitialAd();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();

    _createBannerAd();
    _createInterstitialAd();

    _selectedIndex = widget.index ?? 0;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
          _widgetOptions.elementAt(_selectedIndex),
          if (_isBannerAdReady)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Direction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.twitter),
            label: 'Tweets',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("share");
          Share.share(
              'Check out Dublin Rail on '
              '\nAndroid: https://play.google.com/store/apps/details?id=com.itchybumr.dublinrailmap'
              '\niOS: https://apps.apple.com/ie/app/dublin-rail/id1556125231',
              subject: 'Dublin Rail');
        },
        child: const Icon(Icons.share),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
