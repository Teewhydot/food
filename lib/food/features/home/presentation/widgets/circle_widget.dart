import 'package:flutter/material.dart';

class CircleWidget extends StatelessWidget {
  final double radius;
  final Color color;
  final Widget? child;
  const CircleWidget({
    super.key,
    this.radius = 50,
    this.color = Colors.white,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: radius, backgroundColor: color, child: child);
  }
}
