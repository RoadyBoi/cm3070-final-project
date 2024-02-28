import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastController {
  static Future<void> showToast(
      {required String msg,
      required Toast toastLength,
      required ToastGravity gravity,
      required Color backgroundColor,
      required Color textColor,
      required double fontSize}) async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Fluttertoast.showToast(
          msg: msg,
          toastLength: toastLength,
          gravity: gravity,
          backgroundColor: backgroundColor,
          textColor: textColor,
          fontSize: fontSize);
    }
  }

  static Future<void> cancel() async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Fluttertoast.cancel();
    }
  }
}
