import 'package:flutter/material.dart';

class CircleWidget extends StatelessWidget {
  final double radius;
  final Color color;
  final Widget? child;
  final Function()? onTap;
  const CircleWidget({
    super.key,
    this.radius = 50,
    this.color = Colors.white,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: CircleAvatar(radius: radius, backgroundColor: color, child: child),
    );
  }
}
