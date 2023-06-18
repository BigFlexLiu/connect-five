import 'dart:math';

import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        min(size.width, size.height) / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
