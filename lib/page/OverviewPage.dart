import 'dart:math';

import 'package:dublin_rail_map/page/ResultPage.dart';
import 'package:dublin_rail_map/services/AdsService.dart';
import 'package:dublin_rail_map/services/DataService.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timelines/timelines.dart';

import '../main.dart';

const kTileHeight = 50.0;

const completeColor = Color(0xff5e6172);
const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xff5ec792);
const destinationColor = Color(0xff5e6172);
const transferColor = Color(0xFFFFB95B);

class OverviewPage extends StatefulWidget {
  final String origin;
  final String destination;

  OverviewPage({this.origin, this.destination});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      _showInterstitialAd();
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyApp(index: index)));
  }

  Future<List<OneSchedule>> getRailTime() {
    if (widget.origin != '' && widget.destination != '') {
      return DataService.getRailTime(widget.origin, widget.destination);
    }
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<OneSchedule>>(
        future: getRailTime(),
        builder: (BuildContext context, AsyncSnapshot<List<OneSchedule>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            return Stack(
              children: [
                ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      OneSchedule _oneSchedule = snapshot.data[index];
                      List<String> _processes = [];
                      List<String> _time = [];
                      for (RowInfo rowInfo in _oneSchedule.getRows()) {
                        if (rowInfo.type == StationType.origin ||
                            rowInfo.type == StationType.transfer) {
                          _processes.add(rowInfo.stationName);
                          _time.add(rowInfo.departureTime);
                        } else if (rowInfo.type == StationType.destination) {
                          _processes.add(rowInfo.stationName);
                          _time.add(rowInfo.arrivalTime);
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ResultPage(schedule: _oneSchedule)));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: SummaryTimelineWidget(processes: _processes, time: _time),
                        ),
                      );
                    }),
                if (_isBannerAdReady)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd),
                    ),
                  ),
              ],
            );
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
                child: Text('Awaiting result...'),
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
        },
      ),
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
            icon: Icon(FontAwesomeIcons.twitter),
            label: 'Tweets',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class SummaryTimelineWidget extends StatefulWidget {
  final List<String> processes;
  final List<String> time;

  const SummaryTimelineWidget({this.processes, this.time});

  @override
  _SummaryTimelineWidgetState createState() => _SummaryTimelineWidgetState();
}

class _SummaryTimelineWidgetState extends State<SummaryTimelineWidget> {
  List<String> _processes;

  var _time;

  int _processIndex = 0;

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else if (index == _processes.length - 1) {
      return destinationColor;
    } else {
      return transferColor;
    }
  }

  @override
  initState() {
    super.initState();
    _processes = widget.processes;
    if (widget.processes.length == widget.time.length) {
      _time = widget.time;
    } else {
      _time = List<String>.generate(widget.processes.length, (var e) => '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 5,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: ConnectorThemeData(
            space: 30.0,
            thickness: 5.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) => MediaQuery.of(context).size.width / _processes.length,
          oppositeContentsBuilder: (context, index) {
            return Padding(padding: const EdgeInsets.only(bottom: 5.0), child: Text(_time[index]));
          },
          contentsBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                _processes[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getColor(index),
                ),
              ),
            );
          },
          indicatorBuilder: (_, index) {
            var color;
            var child;
            if (index == _processIndex) {
              color = inProgressColor;
              child = Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: inProgressColor,
                ),
              );
            } else if (index < _processIndex) {
              color = completeColor;
              child = Icon(
                Icons.check,
                color: transferColor,
                size: 15.0,
              );
            } else if (index == _processes.length - 1) {
              color = const Color(0xffd1d2d7);
            } else {
              color = transferColor;
            }

            if (index <= _processIndex) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(16.0, 16.0),
                    painter: _BezierPainter(
                      color: todoColor,
                      drawStart: index > 0,
                      drawEnd: index < _processIndex,
                    ),
                  ),
                  DotIndicator(
                    size: 15.0,
                    color: color,
                    child: child,
                  ),
                ],
              );
            } else {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(15.0, 15.0),
                    painter: _BezierPainter(
                      color: todoColor,
                      drawEnd: index < _processes.length - 1,
                    ),
                  ),
                  OutlinedDotIndicator(
                    borderWidth: 4.0,
                    color: color,
                  ),
                ],
              );
            }
          },
          connectorBuilder: (_, index, type) {
            if (index > 0) {
              if (index == _processIndex) {
                final prevColor = getColor(index - 1);
                final color = getColor(index);
                var gradientColors;
                if (type == ConnectorType.start) {
                  gradientColors = [Color.lerp(prevColor, color, 0.5), color];
                } else {
                  gradientColors = [prevColor, Color.lerp(prevColor, color, 0.5)];
                }
                return DecoratedLineConnector(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                );
              } else {
                return SolidLineConnector(
                  color: todoColor,
                );
              }
            } else {
              return null;
            }
          },
          itemCount: _processes.length,
        ),
      ),
    );
  }
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    @required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(
            0.0, size.height / 2, -radius, radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
