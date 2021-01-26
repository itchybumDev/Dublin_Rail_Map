import 'package:dublin_rail_map/page/OverviewPage.dart';
import 'package:dublin_rail_map/page/ResultPage.dart';
import 'package:dublin_rail_map/page/SearchBar.dart';
import 'package:dublin_rail_map/services/DataService.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';

class SearchPage extends StatefulWidget {
  final callback;

  const SearchPage({
    Key key,
    @required this.callback,
  }) : super(key: key);

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
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
        ),
        Positioned(
            top: 140,
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
              margin: EdgeInsets.fromLTRB(3, 80, 3, 0),
              overlayBorderRadius: BorderRadius.all(Radius.circular(20)),
              onSearchResultTap: _setDestination,
              hintText: "Destination Station"),
        ),
        Positioned(
            top: 55,
            right: 30,
            child: RawMaterialButton(
              onPressed: () {
                print('swapping');
              },
              elevation: 3.0,
              fillColor: Colors.white,
              child: Icon(
                FontAwesomeIcons.arrowsAltV,
                size: 15.0,
              ),
              padding: EdgeInsets.all(5.0),
              shape: CircleBorder(),
            )),
        Align(
          alignment: Alignment.topCenter,
          child: AutocompleteSearchBar(
              margin: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              overlayBorderRadius: BorderRadius.all(Radius.circular(20)),
              onSearchResultTap: _setOrigin,
              hintText: "Origin Station"),
        ),
      ],
    );
  }
}
