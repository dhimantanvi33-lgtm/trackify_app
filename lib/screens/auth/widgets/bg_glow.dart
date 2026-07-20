import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class BgGlow extends StatelessWidget {
  const BgGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100, left: -80,
          child: _GlowCircle(color: AppColors.accent.withOpacity(0.06), size: 340),
        ),
        Positioned(
          bottom: -80, right: -60,
          child: _GlowCircle(color: AppColors.coral.withOpacity(0.05), size: 280),
        ),
        Positioned(
          top: 200, right: -40,
          child: _GlowCircle(color: AppColors.gold.withOpacity(0.04), size: 180),
        ),
      ],
    );
  }
}


class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}