import 'dart:convert';

import 'package:dart_twitter_api/twitter_api.dart';
import 'package:dublin_rail_map/services/Const.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

//Length 19, anything, 26, 21, 16
enum StationType { origin, message, transfer, intermediate, destination }

class DataService {
  static Future<String> getTweetContent(String id) async {
    var url = 'https://publish.twitter.com/oembed?url=https%3A%2F%2Ftwitter.com%2FIrishRail%2Fstatus%2F${id}';
    print(url);

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var content = json.decode(response.body)['html'];
      return content;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      return null;
    }
  }
  static Future<List<String>> getTweetId() async {
    final twitterApi = TwitterApi(
      client: TwitterClient(
        consumerKey: twitterApiKey,
        consumerSecret: twitterKeySecret,
        token: accessToken,
        secret: accessTokenSecret,
      ),
    );

// Wait for the future to finish
    var res = await twitterApi.timelineService
        .userTimeline(screenName: "IrishRail", count: 30, excludeReplies: true, includeRts: false);
    List<String> ans = [];
    res.forEach((tweet) => ans.add(tweet.idStr));

    return ans;
  }

  static Future<List<OneSchedule>> getRailTime(
      @required String origin, @required String destination) async {
    print("Downloading");
    var now = new DateTime.now();
    now = now.subtract(Duration(minutes: 10));
    var formatter = new DateFormat('dd/MM/yyyy');

    String base =
        'https://journeyplanner.irishrail.ie/bin/query.exe/en?queryPageDisplayed=yes&start=Later&outwardSooner=yes&REQ1HafasSearchForw=1&HWAI=JS!js=yes&HWAI=JS!ajax=yes&outwardConDetails=&REQ0JourneyStopsS0A=255&REQ0JourneyStopsZ0A=255&journey_mode=single&REQ0HafasPeriodToSearch=1440&REQ0HafasPeriodSearch=2&REQ0HafasSearchForw=1&REQ1HafasPeriodSearch=2&REQ0JourneyDate=';
    String todayDate = formatter.format(now);
    String start = '&REQ0JourneyStopsS0G=';
    String startStation = origin.replaceAll(" ", "%20");
    String stop = '&REQ0JourneyStopsZ0G=';
    String stopStation = destination.replaceAll(" ", "%20");
    String startT = '&REQ0JourneyTime=';
    String startTime = DateFormat('HH:mm').format(now);

    String fullUrl =
        base + todayDate + start + startStation + stop + stopStation + startT + startTime;
    print(fullUrl);
    var response = await http.get(fullUrl);

    if (response.statusCode == 200) {
      print("<200>");
      var document = parse(response.body);
      var table = document.getElementsByClassName('connectionTable')[0];
      return getFullInfo(table);
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      return null;
    }
    ;
  }

  static List<OneSchedule> getFullInfo(var table) {
    print("***********HIDDEN****************");
    var hiddenTables = table.getElementsByClassName("detailsTable");
    List<OneSchedule> allSchedule = [];

    for (var table in hiddenTables) {
      OneSchedule oneSchedule = OneSchedule();
      try {
        var rows = table.getElementsByTagName('tr');
        for (var r in rows) {
          List<String> data = r.text.split("\n");
          RowInfo rowData;
          if (hasDep(data) && !hasArr(data)) {
            rowData = processOrigin(data);
          } else if (!hasArr(data) && !hasDep(data)) {
            rowData = processMessage(data);
          } else if (hasDep(data) && hasArr(data) && data.length < 25) {
            rowData = processIntermediateStop(data);
          } else if (hasArr(data) && !hasDep(data)) {
            rowData = processDestination(data);
          } else {
            rowData = processTransfer(data);
          }
          rowData.removeArrAndDep();
          oneSchedule.addRow(rowData);
        }
      } catch (e) {
        print('Error at reading hidden table');
      }

      allSchedule.add(oneSchedule);
    }

    return allSchedule;
  }

  static RowInfo processOrigin(List<String> data) {
    removeNullOrEmpty(data);

    String arrivalTime = null;
    String departureTime = data[0].trim();
    String stationName = data[2].trim();
    String platformName = data.length == 4 ? data[3].trim() : null;
    String message = null;
    var row = RowInfo(
        type: StationType.origin,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        stationName: stationName,
        departurePlatform: platformName,
        message: message);

    // Check delay time
    if (data[1].contains("(")) {
      row.setDelayTime(data[1].replaceAll("Dep", '').trim());
    }
    return row;
  }

  static RowInfo processMessage(List<String> data) {
    removeNullOrEmpty(data);
    String arrivalTime = null;
    String departureTime = null;
    String stationName = null;
    String platformName = null;
    String message = data.join(" | ").toString().replaceAll(RegExp(r'\s+'), ' ');
    var row = RowInfo(
        type: StationType.message,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        stationName: stationName,
        departurePlatform: platformName,
        message: message);
    return row;
  }

  static RowInfo processIntermediateStop(List<String> data) {
    removeNullOrEmpty(data);

    String arrivalTime = data[0].trim();
    String departureTime = data[1].trim();
    String stationName = data[data.length - 1].trim();
    String platformName = null;
    String message = null;
    var row = RowInfo(
        type: StationType.intermediate,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        stationName: stationName,
        departurePlatform: platformName,
        message: message);
    return row;
  }

  static RowInfo processDestination(List<String> data) {
    removeNullOrEmpty(data);

    String arrivalTime = data[0].split(' ')[0];
    String departureTime = null;
    String stationName = data[1].trim();
    String platformName = data.length == 3 ? data[2].trim() : null;
    String message = null;
    var row = RowInfo(
        type: StationType.destination,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        stationName: stationName,
        arrivalPlatform: platformName,
        message: message);
    return row;
  }

  static RowInfo processTransfer(List<String> data) {
    removeNullOrEmpty(data);
    String stationName;
    String arrivalPlatform;
    String departurePlatform;
    String message;
    var time = [];
    bool hasDepAppear = false;
    //After this loop, time and platform should only have 2 elements each.

    for (String s in data) {
      if (s.contains(':')) {
        time.add(s);
        //  16 is 2 duplicated "Platform 7 Platform 6"
      } else if (s.contains('Platform') && s.length < 16 && !hasDepAppear) {
        arrivalPlatform = s;
      } else if (s.contains('Platform') && s.length < 16 && hasDepAppear) {
        departurePlatform = s;
      } else if (s.contains('Platform') && s.length >= 16) {
        //do nothing
      } else if (s.contains('Dep')) {
        hasDepAppear = true;
      } else {
        stationName = s;
      }
    }

    var row = RowInfo(
        type: StationType.transfer,
        arrivalTime: time[0],
        departureTime: time.length == 2 ? time[1] : null,
        stationName: stationName,
        arrivalPlatform: arrivalPlatform,
        departurePlatform: departurePlatform,
        message: message);
    return row;
  }

  static void removeNullOrEmpty(List<String> data) {
    data.removeWhere((value) => value == null || value.trim().isEmpty);
  }

  static bool hasDep(List<String> data) => data.any((String value) => value.contains('Dep'));

  static bool hasArr(List<String> data) => data.any((String value) => value.contains('Arr'));

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}

class OneSchedule {
  List<RowInfo> rows;

  OneSchedule() {
    this.rows = [];
  }

  void addRow(RowInfo row) {
    rows.add(row);
  }

  List<RowInfo> getRows() {
    return this.rows;
  }
}

class RowInfo {
  StationType type;
  String arrivalTime;
  String departureTime;
  String stationName;
  String arrivalPlatform;
  String departurePlatform;
  String message;

  RowInfo(
      {this.type,
      this.arrivalTime,
      this.departureTime,
      this.stationName,
      this.arrivalPlatform,
      this.departurePlatform,
      this.message});

  void removeArrAndDep() {
    if (this.arrivalTime != null) {
      this.arrivalTime = this.arrivalTime.replaceAll('Arr', '').trim();
    }
    if (this.departureTime != null) {
      this.departureTime = this.departureTime.replaceAll('Dep', ''.trim());
    }
  }

  void setDelayTime(String delayTime) {
    this.departureTime += ' ' + delayTime.trim();
  }

  @override
  String toString() {
    return [
      type,
      arrivalTime,
      departureTime,
      stationName,
      arrivalPlatform,
      departurePlatform,
      message
    ].toString();
  }

  bool hasArrivalTime() => this.arrivalTime != null && this.arrivalTime.isNotEmpty;
  bool hasDepartureTime() => this.departureTime != null && this.departureTime.isNotEmpty;
}
