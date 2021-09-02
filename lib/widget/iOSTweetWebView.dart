/*
 * Copyright (c) 2018 Larry Aasen. All rights reserved.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dublin_rail_map/services/DataService.dart';

class iOSTweetWebView extends StatefulWidget {
  final String tweetID;

  iOSTweetWebView({this.tweetID});

  iOSTweetWebView.tweetID(String tweetID) : this.tweetID = tweetID;

  @override
  _iOSTweetWebViewState createState() => new _iOSTweetWebViewState();
}

class _iOSTweetWebViewState extends State<iOSTweetWebView> {
  @override
  void initState() {
    super.initState();

    // _requestTweet();
  }

  Future<String> _getData(String tweetId) async {
    // final body = '''<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Passengers travelling on Northside Dart services will experience delays due to a trespasser at near Raheny Station. -AB</p>&mdash; Iarnród Éireann #StaySafe (@IrishRail) <a href="https://twitter.com/IrishRail/status/1433397149841117185?ref_src=twsrc%5Etfw">September 2, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>''';
    final body = await DataService.getTweetContent(tweetId);
    final dataUrl = Uri.dataFromString(
      '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
</head>
<body>$body</body>
</html>''',
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();
    return dataUrl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(widget.tweetID),
      builder: (cxt, snapshot) {
        if (snapshot.hasData) {
          final webView = WebView(
            initialUrl: snapshot.data,
            javascriptMode: JavascriptMode.unrestricted,
          );
          Widget box = Container();

          box = LimitedBox(
            maxHeight: MediaQuery
                .of(context)
                .size
                .height * 0.60,
            child: webView,
          );
          return Container(alignment: Alignment.center, child: box);
        } else {
          return Container(child: Text('Loading...'));
        }
      },
    );
  }
}
