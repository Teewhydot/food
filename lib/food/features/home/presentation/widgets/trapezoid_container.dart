import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.1038141, size.height * 0.2161979);
    path_0.cubicTo(
      size.width * 0.1061408,
      size.height * 0.1483747,
      size.width * 0.1558624,
      size.height * 0.09473684,
      size.width * 0.2164070,
      size.height * 0.09473684,
    );
    path_0.lineTo(size.width * 0.6709155, size.height * 0.09473684);
    path_0.cubicTo(
      size.width * 0.7314601,
      size.height * 0.09473684,
      size.width * 0.7811831,
      size.height * 0.1483747,
      size.width * 0.7835117,
      size.height * 0.2161979,
    );
    path_0.lineTo(size.width * 0.7983146, size.height * 0.6477789);
    path_0.cubicTo(
      size.width * 0.8007746,
      size.height * 0.7193895,
      size.width * 0.7496526,
      size.height * 0.7789474,
      size.width * 0.6857230,
      size.height * 0.7789474,
    );
    path_0.lineTo(size.width * 0.2016000, size.height * 0.7789474);
    path_0.cubicTo(
      size.width * 0.1376723,
      size.height * 0.7789474,
      size.width * 0.08655023,
      size.height * 0.7193895,
      size.width * 0.08900751,
      size.height * 0.6477789,
    );
    path_0.lineTo(size.width * 0.1038141, size.height * 0.2161979);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Colors.pink.withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
