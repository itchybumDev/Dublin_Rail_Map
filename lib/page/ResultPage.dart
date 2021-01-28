import 'package:dublin_rail_map/services/AdsService.dart';
import 'package:dublin_rail_map/services/DataService.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../main.dart';

class ResultPage extends StatefulWidget {
  final OneSchedule schedule;

  ResultPage({this.schedule});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    showAds(index);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MyApp(index: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ActivityTimeline(timeline: widget.schedule),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Direction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.handHoldingUsd),
            label: 'Ads',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class _ActivityTimeline extends StatefulWidget {
  OneSchedule timeline;

  _ActivityTimeline({this.timeline});

  @override
  _ActivityTimelineState createState() => _ActivityTimelineState();
}

class _ActivityTimelineState extends State<_ActivityTimeline> {
  List<Step> _steps;

  List<Step> _generateData() {
    List<Step> tmp = new List();
    List<RowInfo> rows = widget.timeline.getRows();
    for (int i = 0; i < rows.length; i++) {
      RowInfo row = rows[i];
      if (row.type == StationType.origin) {
        tmp.add(Step(
          type: Type.checkpoint,
          rowInfo: row,
          icon: Icons.home,
          message: row.stationName,
          color: const Color(0xFFF2F2F2),
        ));
      } else if (row.type == StationType.message) {
        tmp.add(Step(
          type: Type.line,
          rowInfo: row,
          message: row.message,
          color: const Color(0xFF40C752),
        ));
      } else if (row.type == StationType.intermediate) {
        tmp.add(Step(
          type: Type.line,
          rowInfo: row,
          message: row.stationName,
          color: const Color(0xFF40C752),
        ));
      } else if (row.type == StationType.transfer) {
        tmp.add(Step(
          type: Type.checkpoint,
          rowInfo: row,
          icon: FontAwesomeIcons.exchangeAlt,
          message: row.stationName,
          color: const Color(0xFFFFB95B),
        ));
      } else {
        tmp.add(Step(
          type: Type.checkpoint,
          rowInfo: row,
          icon: Icons.lightbulb,
          message: row.stationName,
          color: const Color(0xFFF2F2F2),
        ));
      }
    }
    return tmp;
  }

  @override
  void initState() {
    _steps = _generateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(
          accentColor: Colors.white.withOpacity(0.2),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: _TimelineActivity(steps: _steps),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineActivity extends StatelessWidget {
  const _TimelineActivity({Key key, this.steps}) : super(key: key);

  final List<Step> steps;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (BuildContext context, int index) {
        final Step step = steps[index];

        IndicatorStyle indicator;

        if (step.rowInfo.type == StationType.intermediate) {
          indicator = _indicatorStyleIntermediate(step);
        } else if (step.rowInfo.type == StationType.origin ||
            step.rowInfo.type == StationType.transfer ||
            step.rowInfo.type == StationType.destination) {
          indicator = _indicatorStyleCheckpoint(step);
        } else {
          indicator = IndicatorStyle(width: 0);
        }
        final righChild = _RightChildTimeline(step: step);

        Widget leftChild;
        if (step.hasArrivalTime || step.hasDepartureTime) {
          leftChild = _LeftChildTimeline(step: step);
        }

        return TimelineTile(
          alignment: TimelineAlign.manual,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
          lineXY: 0.25,
          indicatorStyle: indicator,
          startChild: leftChild,
          endChild: righChild,
          // hasIndicator: step.isCheckpoint,
          beforeLineStyle: LineStyle(
            color: step.color,
            thickness: 8,
          ),
        );
      },
    );
  }

  IndicatorStyle _indicatorStyleIntermediate(Step step) {
    return IndicatorStyle(
      width: 30,
      height: 30,
      indicator: Container(
        decoration: BoxDecoration(
          color: step.color,
          borderRadius: const BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.circle,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  IndicatorStyle _indicatorStyleCheckpoint(Step step) {
    return IndicatorStyle(
      width: 46,
      height: 100,
      indicator: Container(
        decoration: BoxDecoration(
          color: step.color,
          borderRadius: const BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: Center(
          child: Icon(
            step.icon,
            color: const Color(0xFF1D1E20),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _RightChildTimeline extends StatelessWidget {
  const _RightChildTimeline({Key key, this.step}) : super(key: key);

  final Step step;

  @override
  Widget build(BuildContext context) {
    final double minHeight =
        step.isCheckpoint ? 100 : 10.0 * 8;

    List<Widget> children = new List();

    if (step.rowInfo.type != StationType.message) {
      //Arriving Platform
      if (step.rowInfo.arrivalPlatform != null &&
          step.rowInfo.arrivalPlatform.isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(
              left: step.isCheckpoint ? 80 : 99, top: 2, bottom: 2, right: 2),
          child: RichText(
            text: TextSpan(
                style: new TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: step.rowInfo.arrivalPlatform,
                  )
                ]),
          ),
        ));
      }

      //Main Station Name
      children.add(Padding(
        padding: EdgeInsets.only(
            left: step.isCheckpoint ? 20 : 26, top: 8, bottom: 8, right: 8),
        child: RichText(
          text: TextSpan(
              style: new TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: step.rowInfo.stationName,
                )
              ]),
        ),
      ));

      //Arriving Platform
      if (step.rowInfo.departurePlatform != null &&
          step.rowInfo.departurePlatform.isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(
              left: step.isCheckpoint ? 80 : 99, top: 2, bottom: 2, right: 2),
          child: RichText(
            text: TextSpan(
                style: new TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: step.rowInfo.departurePlatform,
                  )
                ]),
          ),
        ));
      }
    } else {
      if (step.rowInfo.message != null && step.rowInfo.message.isNotEmpty) {
        List<String> msgs = step.rowInfo.message.split('|');
        for (String s in msgs) {
          children.add(Padding(
            padding: EdgeInsets.only(
                left: 15),
            child: RichText(
              text: TextSpan(
                  style: new TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: s.trim(),
                    )
                  ]),
            ),
          ));
        }
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _LeftChildTimeline extends StatelessWidget {
  const _LeftChildTimeline({Key key, this.step}) : super(key: key);

  final Step step;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List();
    if (step.rowInfo.type != StationType.intermediate) {
      if (step.hasArrivalTime) {
        children.add(Padding(
          padding: EdgeInsets.only(right: step.isCheckpoint ? 10 : 29),
          child: Text("Arriving", textAlign: TextAlign.center),
        ));
        children.add(Padding(
          padding: EdgeInsets.only(right: step.isCheckpoint ? 10 : 29),
          child: Text(step.rowInfo.arrivalTime, textAlign: TextAlign.center),
        ));
      }
      if (step.hasDepartureTime) {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: 30),
        ));
        children.add(Padding(
          padding: EdgeInsets.only(right: step.isCheckpoint ? 10 : 29),
          child: Text("Departing", textAlign: TextAlign.center),
        ));
        children.add(Padding(
          padding: EdgeInsets.only(right: step.isCheckpoint ? 10 : 29),
          child: Text(step.rowInfo.departureTime, textAlign: TextAlign.center),
        ));
      }
    } else if (step.rowInfo.type == StationType.intermediate) {
      if (step.hasDepartureTime) {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: 40),
        ));
        children.add(Padding(
          padding: EdgeInsets.only(right: 5),
          child: Text('Dep ${step.rowInfo.departureTime}',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }
}

enum Type {
  checkpoint,
  line,
}

class Step {
  Step({
    this.type,
    this.rowInfo,
    this.message,
    this.color,
    this.icon,
  });

  final Type type;
  final RowInfo rowInfo;
  final String message;
  final Color color;
  final IconData icon;

  bool get isCheckpoint => type == Type.checkpoint;

  bool get hasArrivalTime =>
      rowInfo.arrivalTime != null && rowInfo.arrivalTime.isNotEmpty;

  bool get hasDepartureTime =>
      rowInfo.departureTime != null && rowInfo.departureTime.isNotEmpty;
}
