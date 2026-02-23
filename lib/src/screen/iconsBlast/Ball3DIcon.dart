import 'package:flutter/material.dart';

class BlastIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color color;

  const BlastIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
