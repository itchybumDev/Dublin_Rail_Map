import 'package:dublin_rail_map/services/StationNameConst.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class AllStationsPage extends StatefulWidget {
  final Function callback;

  AllStationsPage({
    Key key, this.callback,
  }) : super(key: key);

  static final topAppBar = AppBar(
    elevation: 0.1
  );

  @override
  State<AllStationsPage> createState() => _AllStationsPageState();
}

class _AllStationsPageState extends State<AllStationsPage> {
  TextEditingController _queryTextController = TextEditingController();
  List<String> stationData = [];

  _populateStationData() {
    setState(() {
      stationData = STATION_NAMES;
    });
    }

  _filterStationData(String val) {
    if (val == "") {
      stationData = STATION_NAMES;
      return;
    } else {
      Set<String> priority_One = STATION_NAMES.where((i) => i.toLowerCase().startsWith(val.toLowerCase())).toSet();
      Set<String> priority_Two = STATION_NAMES.where((i) => i.toLowerCase().contains(val.toLowerCase())).toSet();
      Set<String> in_second_but_not_in_first = priority_Two.difference(priority_One);
      stationData = []..addAll(priority_One)..addAll(in_second_but_not_in_first);
    }
  }

  @override
  void initState() {
    super.initState();
    _populateStationData();
    _queryTextController.addListener((){
      //use setState to rebuild the widget
      if (_queryTextController.text.length > 0) {
        setState(() {
          _filterStationData(_queryTextController.text);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AllStationsPage.topAppBar,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
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
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      controller: _queryTextController,
                      style: TextStyle(
                          color:
                          Theme.of(context).brightness == Brightness.light ? Colors.black87 : null,
                          fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: "Stations",
                        hintStyle: TextStyle(
                          color:
                          Theme.of(context).brightness == Brightness.light ? Colors.black45 : null,
                          fontSize: 16.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _queryTextController.text = '';
                      _populateStationData();
                    },
                    child: '' == ''
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
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
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: stationData.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    widget.callback(stationData[index]);
                    Navigator.of(context).pop();
                  },
                  child: Card(
                    elevation: 2.0,
                    margin:
                        new EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Text(stationData[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
