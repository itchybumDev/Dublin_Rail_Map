import 'dart:io' show Platform;

import 'package:dublin_rail_map/page/OverviewPage.dart';
import 'package:dublin_rail_map/page/SearchBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  goToResultPage({@required BuildContext context}) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OverviewPage(
              origin: _origin,
              destination: _destination,
            )));
  }

  String _origin = '';
  String _destination = '';
  List<String> tweetIds = [];

  Function _setOrigin(String station) {
    setState(() {
      _origin = station;
    });
  }

  Function _setDestination(String station) {
    setState(() {
      _destination = station;
    });
  }

  void _getResult(BuildContext context) {
    if (_origin != '' && _destination != '') {
      goToResultPage(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const padding_top = 40.0;

    Widget legends = getLegends(context);

    return Stack(
      children: <Widget>[
        Positioned(top: 190, right: 0, left: 0, child: Platform.isAndroid ? legends : Container()),
        Positioned(
            top: 140 + padding_top,
            right: 30,
            child: RaisedButton(
              color: Colors.greenAccent,
              onPressed: () => {_getResult(context)},
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black38),
              ),
              child: new Text("Search"),
            )),
        Align(
          alignment: Alignment.topCenter,
          child: AutocompleteSearchBar(
              margin: EdgeInsets.fromLTRB(3, 80 + padding_top, 3, 0),
              overlayBorderRadius: BorderRadius.all(Radius.circular(20)),
              onSearchResultTap: _setDestination,
              hintText: "Destination Station"),
        ),
        Positioned(
            top: 59 + padding_top,
            left: 13,
            child: Icon(
              FontAwesomeIcons.longArrowAltDown,
              size: 20.0,
            )),
        Align(
          alignment: Alignment.topCenter,
          child: AutocompleteSearchBar(
              margin: EdgeInsets.fromLTRB(3, 10 + padding_top, 3, 10),
              overlayBorderRadius: BorderRadius.all(Radius.circular(20)),
              onSearchResultTap: _setOrigin,
              hintText: "Origin Station"),
        )
      ],
    );
  }

  Widget getLegends(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Image.asset("assets/poster.jpg"),
    );
  }
}
