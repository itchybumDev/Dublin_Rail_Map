import 'package:dublin_rail_map/services/StationNameConst.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapPage extends StatelessWidget {
  const MapPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
          backgroundDecoration: new BoxDecoration(
            color: backgroundColor,
          ),
          minScale: 0.3,
          maxScale: 3.0,
          initialScale: 0.5,
          enableRotation: true,
          imageProvider: AssetImage("assets/rail_map.jpg"),
        ));
  }
}