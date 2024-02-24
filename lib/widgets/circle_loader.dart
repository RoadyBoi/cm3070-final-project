import 'package:flutter/material.dart';

class CircleLoader extends StatelessWidget {
  final Color? color;
  CircleLoader({super.key, this.color});
  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        color: color ?? const Color.fromARGB(255, 66, 71, 86),
      );
}
