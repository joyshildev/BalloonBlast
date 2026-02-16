import 'package:flutter/material.dart';

class Box3DPainter extends CustomPainter {
  final Color color;
  Box3DPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double gap = 6;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, gap),
      Offset(size.width, gap),
      paint,
    );

    canvas.drawLine(
      Offset(gap, 0),
      Offset(gap, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(gap, 0),
      Offset(0, gap),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant Box3DPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
