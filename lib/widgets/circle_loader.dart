import 'package:flutter/material.dart';

class CircleLoader extends StatelessWidget {
  const CircleLoader({super.key});
  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      );
}
