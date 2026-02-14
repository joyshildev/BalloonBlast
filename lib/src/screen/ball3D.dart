// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class Ball3D extends StatelessWidget {
  final Color color;
  final double size;

  const Ball3D({
    super.key,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BallPainter(color),
    );
  }
}

class BallPainter extends CustomPainter {
  final Color color;

  BallPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.9),
          color,
          color.withOpacity(0.9),
          Colors.black.withOpacity(0.4),
        ],
        stops: const [0.0, 0.2, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
