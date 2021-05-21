import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SizeConfig {
  double paneWidth = 0;
  double paneHeight = 0;
  double blockSizeHorizontal = 0;
  double blockSizeVertical = 0;
  double sizerPosition = 0;
  double? barHeight;

  Axis orientation = Axis.vertical;
  Alignment? align;

  void init(BuildContext context) {
    final query = MediaQuery.of(context);
    paneWidth = query.size.width;
    paneHeight = query.size.height;
    blockSizeHorizontal =
        (paneWidth / 100) > 10 ? (paneWidth / 100) / 1.5 : (paneWidth / 100);
    blockSizeVertical = paneHeight / 100;
    barHeight = new AppBar().preferredSize.height;
  }

  void updateHeight(double height) {
    paneHeight = height;
    blockSizeVertical = paneHeight / 100;
  }

  void updateWidth(double width) {
    paneWidth = width;
    blockSizeHorizontal = paneWidth / 100;
  }
}
