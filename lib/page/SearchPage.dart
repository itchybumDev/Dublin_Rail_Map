import 'package:dublin_rail_map/page/OverviewPage.dart';
import 'package:dublin_rail_map/page/SearchBar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tweet_webview/tweet_webview.dart';

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
    final tweets = [
      '1346562858713313282',
      '1325399463624663040',
    ];

    final list = ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: tweets.length,
      itemBuilder: (context, index) {
        var tweetID = tweets[index];
        return Card(
          color: Colors.white,
          child: TweetWebView.tweetID(tweetID),
        );
      },
    );

    return Stack(
      children: <Widget>[
        Positioned(
          top: 200,
          left: 1,
          right: 1,
          bottom: 10,
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 5.0),
            child: list,
          ),
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
            top: 59,
            left: 13,
            child: Icon(
              FontAwesomeIcons.longArrowAltDown,
              size: 20.0,
            )),
        Align(
          alignment: Alignment.topCenter,
          child: AutocompleteSearchBar(
              margin: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              overlayBorderRadius: BorderRadius.all(Radius.circular(20)),
              onSearchResultTap: _setOrigin,
              hintText: "Origin Station"),
        )
      ],
    );
  }
}
