import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;
  const RipplePainter(this.center, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      center,
      progress * 140,
      Paint()..color = Colors.white.withOpacity((1 - progress) * 0.28),
    );
  }

  @override
  bool shouldRepaint(RipplePainter o) => o.progress != progress;
}

class RippleData {
  final Offset offset;
  final int id;
  const RippleData({required this.offset, required this.id});
}
