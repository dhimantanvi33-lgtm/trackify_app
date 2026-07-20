
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShimmerPainter extends CustomPainter {
  final double progress;
  const ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.4, 0.5, 0.6],
      ).createShader(Rect.fromLTWH(
        size.width * progress - size.width * 0.3,
        0,
        size.width * 0.6,
        size.height,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ShimmerPainter o) => o.progress != progress;
}