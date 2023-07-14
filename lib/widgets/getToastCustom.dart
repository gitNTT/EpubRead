import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin getCustomToast {
  static void show(
      String message,
      BuildContext context, {
        bool longDuration = false,
      }) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? Colors.white70 : Colors.black54;
    final textColor = isDarkMode ? Colors.black : Colors.white;
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      toastLength:longDuration? Toast.LENGTH_LONG: Toast.LENGTH_SHORT,
    );
  }
}
