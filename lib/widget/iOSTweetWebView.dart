/*
 * Copyright (c) 2018 Larry Aasen. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    var child;
    if (widget.tweetID != null) {
      // final downloadUrl = Uri.file(_filename).toString();

      // Create the WebView to contian the tweet HTML
      final webView = WebView(
          initialUrl: 'https://twitter.com/IrishRail/status/${widget.tweetID}',
          javascriptMode: JavascriptMode.unrestricted);

      // The WebView creates an exception: RenderAndroidView object was given an infinite size during layout.
      // To avoid that exception a max height constraint will be used. Hopefully soon the WebView will be able
      // to size itself so it will not have an infinite height.
      Widget box = Container();

      if (Platform.isAndroid) {
        box = LimitedBox(
          maxHeight: 500.0,
          child: webView,
        );
      } else {
        box = SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: webView,
        );
      }

      child = box;
    } else {
      child = Text('Loading...');
    }

    return Container(alignment: Alignment.center, child: child);
  }
}
