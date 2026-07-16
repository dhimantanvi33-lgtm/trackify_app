import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackify/features/auth/auth_gate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import 'category_data_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _segmentControllers;
  late final List<Animation<double>> _segmentScales;
  late final List<Animation<double>> _segmentOpacities;

  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _buttonController;
  late final AnimationController _floatController;
  late final AnimationController _shimmerController;

  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    // Segment animations
    _segmentControllers = List.generate(
      kCategories.length,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );

    _segmentScales = _segmentControllers.map((c) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticOut),
      );
    }).toList();

    _segmentOpacities = _segmentControllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
      );
    }).toList();

    // Logo
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Text block
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    // Button
    _buttonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: const Interval(0, 0.4, curve: Curves.easeIn)),
    );

    // Float loop
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Shimmer loop
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _startSequence();
  }
  Future<void> _startSequence() async {
    for (int i = 0; i < kCategories.length; i++) {
      await Future.delayed(const Duration(milliseconds: 130));
      _segmentControllers[i].forward();
    }

    await Future.delayed(const Duration(milliseconds: 250));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _buttonController.forward();
  }

  @override
  void dispose() {
    for (final c in _segmentControllers) c.dispose();
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background radial glow
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating particles
          const _ParticlesLayer(),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 28),

                  // Logo row
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: const _LogoRow(),
                  ),

                  const SizedBox(height: 12),

                  // Animated pie chart + float
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pie segments
                          ...List.generate(kCategories.length, (i) {
                            return AnimatedBuilder(
                              animation: _segmentControllers[i],
                              builder: (context, _) {
                                return Opacity(
                                  opacity: _segmentOpacities[i].value,
                                  child: Transform.scale(
                                    scale: _segmentScales[i].value,
                                    child: CustomPaint(
                                      size: const Size(260, 260),
                                      painter: _SegmentPainter(
                                        category: kCategories[i],
                                        progress: _segmentControllers[i].value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // Center circle
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.bg,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.25),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'TRACK',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentLight,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'ify',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.cream,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Icon overlays on segments
                          ...List.generate(kCategories.length, (i) {
                            return AnimatedBuilder(
                              animation: _segmentControllers[i],
                              builder: (context, _) {
                                final cat = kCategories[i];
                                final midAngle = (cat.startAngle + cat.sweepAngle / 2) * pi / 180;
                                const dist = 88.0;
                                final dx = dist * cos(midAngle - pi / 2);
                                final dy = dist * sin(midAngle - pi / 2);
                                return Positioned(
                                  left: 130 + dx - 14,
                                  top: 130 + dy - 14,
                                  child: Opacity(
                                    opacity: _segmentControllers[i].value.clamp(0, 1),
                                    child: Icon(cat.icon, color: Colors.white, size: 16),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Category pills
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(kCategories.length, (i) {
                        return _CategoryPill(
                          label: AppStrings.categories[i],
                          color: AppColors.segments[i],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Headline + subtitle
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                color: AppColors.cream,
                              ),
                              children: [
                                const TextSpan(text: 'Master Your '),
                                TextSpan(
                                  text: 'Money,',
                                  style: TextStyle(color: AppColors.accent),
                                ),
                                const TextSpan(text: '\n${AppStrings.taglineEnd}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              height: 1.6,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // CTA Button
                  SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _buttonOpacity,
                      child: Column(
                        children: [
                          TrackifyButton(
                            label: AppStrings.getStarted,
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, anim, __) => const AuthGate(),
                                  transitionsBuilder: (_, anim, __, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 380),
                                ),
                              );
                               },
                          ),
                          const SizedBox(height: 10),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  final CategoryData category;
  final double progress;

  const _SegmentPainter({required this.category, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 - 4;
    const innerR = 44.0;
    const gapDeg = 3.0;

    final paint = Paint()
      ..color = category.color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = category.color.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final startRad = (category.startAngle + gapDeg - 90) * pi / 180;
    final sweepRad = (category.sweepAngle - gapDeg * 2) * pi / 180;

    final path = Path()
      ..moveTo(
        cx + innerR * cos(startRad),
        cy + innerR * sin(startRad),
      )
      ..lineTo(
        cx + outerR * cos(startRad),
        cy + outerR * sin(startRad),
      )
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
        startRad,
        sweepRad,
        false,
      )
      ..lineTo(
        cx + innerR * cos(startRad + sweepRad),
        cy + innerR * sin(startRad + sweepRad),
      )
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
        startRad + sweepRad,
        -sweepRad,
        false,
      )
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.progress != progress || old.category != category;
}

class _LogoRow extends StatelessWidget {
  const _LogoRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.accentLight],
            ),
          ),
          child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ParticlesLayer extends StatefulWidget {
  const _ParticlesLayer();

  @override
  State<_ParticlesLayer> createState() => _ParticlesLayerState();
}

class _ParticlesLayerState extends State<_ParticlesLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random(42);
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(20, (i) {
      return _Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 3 + 1,
        color: AppColors.segments[i % AppColors.segments.length],
        phase: _rng.nextDouble() * 2 * pi,
        speed: _rng.nextDouble() * 0.5 + 0.5,
        driftX: (_rng.nextDouble() - 0.5) * 0.04,
        driftY: (_rng.nextDouble() - 0.5) * 0.06,
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlesPainter(_particles, _ctrl.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, size, phase, speed, driftX, driftY;
  final Color color;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.phase,
    required this.speed,
    required this.driftX,
    required this.driftY,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  const _ParticlesPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final animT = t * p.speed;
      final ox = sin(animT * 2 * pi + p.phase) * p.driftX * size.width;
      final oy = sin(animT * 2 * pi + p.phase + 1) * p.driftY * size.height;
      final opacity = 0.2 + 0.2 * sin(animT * 2 * pi + p.phase);

      canvas.drawCircle(
        Offset(p.x * size.width + ox, p.y * size.height + oy),
        p.size,
        Paint()..color = p.color.withOpacity(opacity.clamp(0.1, 0.45)),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.t != t;
}