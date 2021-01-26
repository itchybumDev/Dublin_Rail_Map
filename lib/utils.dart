import 'package:flutter/material.dart';

Widget buildBottomNavigationBar() {
  return Container(
      height: 50,
      child: Row(
        children: [],
      )
  );
}

Widget buildButton(function, icon, text) {
  return Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        function();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 18,
            width: 30,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: icon,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: text,
          ),
        ],
      ),
    ),
  );
}