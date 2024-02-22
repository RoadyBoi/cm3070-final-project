import 'package:flutter/material.dart';

class CircleLoader extends StatelessWidget {
  const CircleLoader({super.key});
  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        color: const Color.fromARGB(255, 66, 71, 86),
      );
}
