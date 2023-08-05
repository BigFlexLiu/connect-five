
import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Color color;
  final double radius;

  CirclePainter({required this.color, required this.radius});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
