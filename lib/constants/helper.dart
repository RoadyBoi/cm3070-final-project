import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/settings.dart';

// ignore_for_file: avoid_print

class Helper {
  // error printing function
  static void debugErrorPrint(dynamic error,
      {dynamic trace, List<dynamic>? additionalOutputs}) {
    // if debug build is running
    if (kDebugMode && !Platform.environment.containsKey('FLUTTER_TEST')) {
      // print error and trace
      print(error);
      print("\n$trace");
      // print any additional outputs passed to this function
      if (additionalOutputs != null)
        for (Object? output in additionalOutputs) {
          print(output);
        }
    }
  }

  static void debugPrint(Object? message) {
    // if debug build is running, print message
    if (kDebugMode && !Platform.environment.containsKey('FLUTTER_TEST'))
      print(message);
  }

  static void showSnackBar(String? content,
      {String? actionLabel, void Function()? actionOnPressed}) {
    // if there is no scaffold messenger key active
    if (Settings.scaffoldMessengerKey.currentState == null)
      Helper.debugErrorPrint("[ScaffoldMessengerKey] - currentState = null");
    // if there is no content provided for the snackbar
    if (content == null)
      debugErrorPrint("[Helper] - showSnackBar: content = null");
    else
      // hide any snackbars appearing currenlty and
      // use the scaffold messenger key to show a snackbar
      Settings.scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(content),
            action: actionLabel != null && actionOnPressed != null
                ? SnackBarAction(label: actionLabel, onPressed: actionOnPressed)
                : null));
  }
}
