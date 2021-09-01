import 'dart:io' show Platform;

import 'package:dublin_rail_map/services/DataService.dart';
import 'package:dublin_rail_map/widget/iOSTweetWebView.dart';
import 'package:flutter/material.dart';
import 'package:tweet_webview/tweet_webview.dart';

class TweetsPage extends StatelessWidget {
  const TweetsPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: DataService.getTweetId(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          List<Widget> children;

          if (snapshot.hasData) {
            final list = ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  var tweetID = snapshot.data[index];
                  return Card(
                    child: Platform.isAndroid
                        ? TweetWebView.tweetID(tweetID)
                        : iOSTweetWebView.tweetID(tweetID),
                  );
                });
            final container = Container(color: Colors.black26, child: Center(child: list));

            return container;
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Loading tweets...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        });
  }
}
