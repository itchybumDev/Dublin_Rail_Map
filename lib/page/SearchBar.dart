import 'dart:async';

import 'package:dublin_rail_map/services/StationNameConst.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AutocompleteSearchBarState with ChangeNotifier {
  TextEditingController _queryTextController = TextEditingController();
  List<String> _response;
  Timer _debounce;
  String _prevQuery;

  final _queryBehavior = BehaviorSubject<String>.seeded('');

  AutocompleteSearchBarState() {
    _queryTextController.addListener(_onQueryChange);
    _queryBehavior.stream.listen(_doSearch);
    _prevQuery = "";
  }

  List<String> get response => _response;

  set response(res) {
    _response = res;
    notifyListeners();
  }

  set queryText(text) {
    _queryTextController.text = text;
  }

  void _onQueryChange() {
    if (_debounce?.isActive ?? false) _debounce.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () {
      _queryBehavior.add(_queryTextController.text);
    });
  }

  void _onResponseError(List<String> res) {
    response = null;
  }

  void _onResponse(List<String> res) {
    response = res;
  }

  List<String> getNames(String val) {
    List<String> brandsList = STATION_NAMES;
    List<String> suggestionsList = [];
    suggestionsList = brandsList.where((i) => i.toLowerCase().contains(val.toLowerCase())).toList();
    return suggestionsList;
  }

  Future<Null> _doSearch(String value) async {
    if (_prevQuery == value) {
      return null;
    }

    if (value.isNotEmpty) {
      final res = getNames(value);
      _onResponse(res);
    } else {
      _onResponse(null);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _queryBehavior.close();
    _queryTextController.removeListener(_onQueryChange);
  }
}

class AutocompleteSearchBar extends StatelessWidget {
  final overlayBorderRadius;
  final Function onSearchResultTap;
  final margin;
  final String hintText;

  const AutocompleteSearchBar(
      {Key key,
      @required this.hintText,
      this.overlayBorderRadius,
      this.onSearchResultTap,
      this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AutocompleteSearchBarState(),
      child: Container(
          height: 200,
          margin: margin,
          child: Stack(children: <Widget>[
            SearchBar(overlayBorderRadius, onSearchResultTap, hintText),
            Padding(
              padding: EdgeInsets.only(top: 48.0),
              child: SearchResultList(overlayBorderRadius, onSearchResultTap),
            ),
          ])),
    );
  }
}

class SearchBar extends StatelessWidget {
  final overlayBorderRadius;
  final Function onSearchResultTap;
  final String hintText;

  SearchBar(this.overlayBorderRadius, this.onSearchResultTap, this.hintText);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<AutocompleteSearchBarState>(context);

    final headerTopLeftBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.topLeft : Radius.circular(2);

    final headerTopRightBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.topRight : Radius.circular(2);

    final headerBottomLeftBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.bottomLeft : Radius.circular(2);

    final headerBottomRightBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.bottomRight : Radius.circular(2);

    return Column(children: <Widget>[
      Material(
        elevation: 2.0,
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.only(
            topLeft: headerTopLeftBorderRadius,
            topRight: headerTopRightBorderRadius,
            bottomLeft: headerBottomLeftBorderRadius,
            bottomRight: headerBottomRightBorderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: Colors.black45,
              icon: Icon(Icons.search),
            ),
            Expanded(
              child: Padding(
                child: TextField(
                  textInputAction: TextInputAction.search,
                  controller: state._queryTextController,
                  style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.light ? Colors.black87 : null,
                      fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.light ? Colors.black45 : null,
                      fontSize: 16.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                padding: const EdgeInsets.only(right: 8.0),
              ),
            ),
            GestureDetector(
              onTap: () {
                state.queryText = '';
                state.response = null;
                onSearchResultTap(null);
              },
              child: state._queryTextController.text != ''
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
            )
          ],
        ),
      ),
    ]);
  }
}

class SearchResultList extends StatelessWidget {
  final overlayBorderRadius;
  final Function onSearchResultTap;

  SearchResultList(this.overlayBorderRadius, this.onSearchResultTap);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<AutocompleteSearchBarState>(context);

    final headerTopLeftBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.topLeft : Radius.circular(2);

    final headerTopRightBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.topRight : Radius.circular(2);

    final headerBottomLeftBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.bottomLeft : Radius.circular(2);

    final headerBottomRightBorderRadius =
        overlayBorderRadius != null ? overlayBorderRadius.bottomRight : Radius.circular(2);

    if (state.response == null) {
      return Container();
    }

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: headerTopLeftBorderRadius,
              topRight: headerTopRightBorderRadius,
              bottomLeft: headerBottomLeftBorderRadius,
              bottomRight: headerBottomRightBorderRadius),
        ),
        child: ListBody(
          children: state.response.map((p) => SearchResultItem(p, onSearchResultTap)).toList(),
        ),
      ),
    );
  }
}

class SearchResultItem extends StatelessWidget {
  final String prediction;
  final Function onSearchResultTap;

  SearchResultItem(this.prediction, this.onSearchResultTap);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AutocompleteSearchBarState>(context, listen: false);

    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(prediction),
      onTap: () {
        state.queryText = prediction;
        state.response = null;
        state._prevQuery = prediction;
        if (onSearchResultTap != null) {
          onSearchResultTap(prediction);
        }
      },
    );
  }
}
