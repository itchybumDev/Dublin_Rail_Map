import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapPage extends StatelessWidget {
  const MapPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: PhotoView(
          backgroundDecoration: new BoxDecoration(
            color: Colors.white,
          ),
          minScale: 0.3,
          maxScale: 3.0,
          initialScale: 0.5,
          enableRotation: true,
          imageProvider: AssetImage("assets/rail_map.jpg"),
        ));
  }
}