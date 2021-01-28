import 'package:dublin_rail_map/page/MapPage.dart';
import 'package:dublin_rail_map/page/SearchPage.dart';
import 'package:dublin_rail_map/services/AdsService.dart';
import 'package:dublin_rail_map/services/DataService.dart';
import 'package:dublin_rail_map/services/StationNameConst.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: 'Dublin Rail Map',
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

  int _selectedIndex = 0;
  final myController = TextEditingController();

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    SearchPage(),
    MapPage(),
    Center(
      child: Text(
        'Thank you for viewing the ads\n',
        style: optionStyle,
      ),
    ),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      createInterstitialAd()..load()..show();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance.initialize(appId: adsAppId);

    _bannerAd = createBannerAd()
      ..load()
      ..show(anchorType: AnchorType.bottom, anchorOffset: 68.0);

    _selectedIndex = widget.index ?? 0;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
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
            icon: Icon(FontAwesomeIcons.handHoldingUsd),
            label: 'Ads',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
