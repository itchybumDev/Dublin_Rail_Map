import 'package:dublin_rail_map/model/RecentSearchItem.dart';
import 'package:dublin_rail_map/page/OverviewPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AllStationsPage.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    print(station);
    setState(() {
      _origin = station;
    });
  }

  Function _setDestination(String station) {
    print(station);
    setState(() {
      _destination = station;
    });
  }

  void _getResult(BuildContext context) {
    if (_origin != '' && _destination != '' && _origin != _destination) {
      _setRecentSearch(_origin, _destination);
      goToResultPage(context: context);
    }
  }

  void _populateOriginAndDestination(RecentSearchItem item, BuildContext context) {
    setState(() {
      _origin = item.origin;
      _destination = item.destination;
    });

    final snackBar = SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('Tap "Search" for train time'));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  Future<List<RecentSearchItem>> _getRecentSearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSearch = prefs.getStringList('recentSearch') ?? [];

    if (recentSearch.length > 0) {
      List<RecentSearchItem> toBeSorted = recentSearch.map((e) {
        List<String> args = e.split("?");
        DateTime time = DateTime.parse(args[2]);
        return RecentSearchItem(args[0], args[1], time);
      }).toList();
      toBeSorted.sort((b, a) => a.time.compareTo(b.time));

      return toBeSorted;
    } else {
      return [];
    }
  }

  void _setRecentSearch(String origin, String destination) async {
    String toBeSave = '$origin?$destination?${DateTime.now()}';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSearch = prefs.getStringList('recentSearch') ?? [];
    recentSearch.add(toBeSave);
    prefs.setStringList('recentSearch', recentSearch);
    print("Done saving");
  }

  Future<void> _updateRecentSearch(List<RecentSearchItem> recentSearch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> toBeSave = recentSearch.map((e) => e.toString()).toList();
    prefs.setStringList('recentSearch', toBeSave);
    print("Done saving");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        SearchBox(
          hintText: "Origin Station",
          callback: _setOrigin,
          station: _origin,
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            setState(() {
              var tmp = _origin;
              _origin = _destination;
              _destination = tmp;
            });
          },
          child: Container(
              padding: EdgeInsets.only(right: 80),
              alignment: Alignment.centerRight,
              child: Icon(
                FontAwesomeIcons.arrowsAltV,
                size: 20.0,
              )),
        ),
        SizedBox(height: 5),
        SearchBox(
          hintText: "Destination Station",
          callback: _setDestination,
          station: _destination,
        ),
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          child: RaisedButton(
            color: Colors.greenAccent,
            onPressed: () => {_getResult(context)},
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.black38),
            ),
            child: new Text("Search"),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text("Recent search",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text("Swipe left to remove search",
                  style: TextStyle(fontSize: 12.0)),
            ),
          ],
        ),
        FutureBuilder(
            future: _getRecentSearch(),
            builder: (ctx, AsyncSnapshot<List<RecentSearchItem>> snapshot) {
              if (snapshot.hasData) {
                final now = new DateTime.now();

                return Flexible(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        RecentSearchItem item = snapshot.data[index];

                        final difference = now.difference(item.time);

                        return Dismissible(
                          key: new Key(snapshot.data[index].toString()),
                          onDismissed: (direction) async {
                            snapshot.data.removeAt(index);
                            await _updateRecentSearch(snapshot.data);
                            setState(() {});
                          },
                          background: Container(color: Colors.red),
                          child: ListTile(
                            onTap: () => {_populateOriginAndDestination(item, context)},
                            title: Text(item.displayString()),
                            subtitle:
                                Text(timeago.format(now.subtract(difference))),
                          ),
                        );
                      }),
                );
              } else {
                return Container();
              }
            })
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  final String hintText;
  final String station;
  final Function callback;

  SearchBox({this.hintText, this.callback, this.station});

  _goToSearchStation(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AllStationsPage(callback: callback)));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          _goToSearchStation(context);
        },
        child: Container(
            child: Material(
          elevation: 2.0,
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                color: Colors.black45,
                icon: Icon(Icons.search),
              ),
              Expanded(
                child: Padding(
                  child: Text(
                    station == "" ? this.hintText : station,
                    style: TextStyle(
                      color: station == "" ? Colors.black45 : Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),
                  padding: const EdgeInsets.only(right: 8.0, top: 15),
                ),
              ),
              GestureDetector(
                onTap: () {
                  callback("");
                },
                child: '' == ''
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.grey[200],
                        ),
                        child: Text(
                          "Clear",
                          style: Theme.of(context).textTheme.bodyText2,
                        ))
                    : Container(
                        height: 0,
                        width: 0,
                      ),
              ),
              SizedBox(width: 10)
            ],
          ),
        )),
      ),
    );
  }
}
