import 'package:flutter/material.dart';

import '../../features/auth/widgets/ripple_painter.dart';
import '../../features/auth/widgets/shimmer_painter.dart';
import '../constants/app_colors.dart';

class TrackifyButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? prefixIcon;

  const TrackifyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.prefixIcon,
  });

  @override
  State<TrackifyButton> createState() => _TrackifyButtonState();
}

class _TrackifyButtonState extends State<TrackifyButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  // ✅ Use public RippleData (from ripple_painter.dart), not _RippleData
  final List<RippleData> _ripples = [];

  late final AnimationController _shimmer;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  void _addRipple(TapDownDetails d) {
    final id = DateTime.now().microsecondsSinceEpoch;

    // ✅ Use public RippleData constructor
    setState(() => _ripples.add(RippleData(offset: d.localPosition, id: id)));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        // ✅ Access .id directly — no null issue since list holds RippleData, not RippleData?
        setState(() => _ripples.removeWhere((r) => r.id == id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.outlined) {
      return GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder, width: 1.5),
            color: AppColors.inputBg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.prefixIcon != null) ...[
                Icon(widget.prefixIcon, color: AppColors.cream, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (d) {
        setState(() => _pressed = true);
        _addRipple(d);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.coral, AppColors.coralLight],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withOpacity(_pressed ? 0.25 : 0.45),
                blurRadius: _pressed ? 10 : 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer
              if (!widget.isLoading)
                AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (_, __) => CustomPaint(
                    painter: ShimmerPainter(_shimmerAnim.value),
                    child: const SizedBox.expand(),
                  ),
                ),

              // Ripples
              ..._ripples.map(
                    (r) => Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (_, val, __) => CustomPaint(
                      // ✅ r.offset and r.id are non-null — RippleData fields are required
                      painter: RipplePainter(r.offset, val),
                    ),
                  ),
                ),
              ),

              // Content
              widget.isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
