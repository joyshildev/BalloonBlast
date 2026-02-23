// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class Ball3D extends StatelessWidget {
  final Color color;
  final double size;

  const Ball3D({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BallPainter(color),
      ),
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
        center: const Alignment(-0.1, -0.1),
        radius: 0.5,
        colors: [
          color.withOpacity(0.9),
          color,
          color.withOpacity(0.7),
          color.withOpacity(0.5),
        ],
        stops: const [0.0, 0.2, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2.6,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BallPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
