import 'dart:math';

import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final int x;
  final int y;
  final Set<Point> touchedSquares;

  LinePainter({
    required this.x,
    required this.y,
    required this.touchedSquares,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (touchedSquares.contains(Point(x, y))) {
      canvas.drawLine(Offset(0, size.height / 2),
          Offset(size.width, size.height / 2), paint);
      canvas.drawLine(Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
