import 'package:flutter/material.dart';

enum ShapeUtilsCorners { all, top, bottom, left, right, none }

enum ShapeUtilsBorder { all, vertical, horizontal, none }

class ShapeUtils {
  static BorderRadius getBorderRadius(
      ShapeUtilsCorners corners, double radius) {
    switch (corners) {
      case ShapeUtilsCorners.all:
        return BorderRadius.all(Radius.circular(radius));
      case ShapeUtilsCorners.top:
        return BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        );
      case ShapeUtilsCorners.bottom:
        return BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      case ShapeUtilsCorners.none:
        return BorderRadius.zero;
      case ShapeUtilsCorners.left:
        return BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        );
      case ShapeUtilsCorners.right:
        return BorderRadius.only(
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
    }
  }

  static Border getBorder(ShapeUtilsBorder border, Color color,
      [double width = 1.0]) {
    switch (border) {
      case ShapeUtilsBorder.all:
        return Border.all(color: color, width: width);
      case ShapeUtilsBorder.horizontal:
        return Border.symmetric(
          vertical: BorderSide(color: color, width: width),
        );
      case ShapeUtilsBorder.vertical:
        return Border.symmetric(
          horizontal: BorderSide(color: color, width: width),
        );
      case ShapeUtilsBorder.none:
        return const Border.symmetric();
    }
  }
}
