import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/features/auth/widgets/logo_bar.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String destination;

  const OtpVerifyScreen({super.key, required this.destination});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendCooldown = 30; // seconds

  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());

  bool _loading = false;
  bool _verified = false;
  String? _errorMsg;

  int _resendTimer = _resendCooldown;
  Timer? _timer;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _successScaleAnim;

  @override
  void initState() {
    super.initState();

    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _enterAnim,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut),
        );
    _successScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterAnim,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _enterAnim.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer <= 1) {
        t.cancel();
        setState(() => _resendTimer = 0);
      } else {
        setState(() => _resendTimer--);
      }
    });
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpValue.length == _otpLength;

  void _onOtpChanged(int index, String value) {
    setState(() => _errorMsg = null);

    if (value.length > 1) {
      // Handle paste: distribute across boxes
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[index + i < _otpLength ? index + i : _otpLength - 1]
            .text = digits[i];
      }
      final nextIndex = (index + digits.length).clamp(0, _otpLength - 1);
      _focusNodes[nextIndex].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _verify() async {
    if (!_isComplete) {
      setState(() => _errorMsg = 'Please enter all 6 digits');
      return;
    }
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Simulate: treat "000000" as wrong for demo
    if (_otpValue == '000000') {
      setState(() {
        _loading = false;
        _errorMsg = 'Invalid code. Please try again.';
      });
      _shakeBoxes();
      return;
    }

    setState(() {
      _loading = false;
      _verified = true;
    });
    _enterAnim.reset();
    _enterAnim.forward();
  }

  void _shakeBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resend() async {
    _startResendTimer();
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _errorMsg = null);
    _focusNodes[0].requestFocus();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const BgGlow(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: _verified ? _buildSuccess() : _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        const Center(child: LogoBar()),

        const SizedBox(height: 44),

        // Back
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Go back',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Icon badge
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.verified_outlined,
            color: AppColors.accent,
            size: 26,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Verify your email',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.cream,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.muted,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(
                text: widget.destination,
                style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '. Enter it below.'),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_otpLength, (i) => _buildOtpBox(i)),
        ),

        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _errorMsg != null
              ? Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 14, color: Colors.redAccent.shade200),
                const SizedBox(width: 6),
                Text(
                  _errorMsg!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.redAccent.shade200,
                  ),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 32),

        // Verify button
        TrackifyButton(
          label: 'Verify Code',
          isLoading: _loading,
          onPressed: _isComplete ? _verify : () {},
        ),

        const SizedBox(height: 28),

        // Resend
        Center(
          child: _resendTimer > 0
              ? RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13),
              children: [
                TextSpan(
                  text: 'Resend code in ',
                  style: TextStyle(color: AppColors.muted),
                ),
                TextSpan(
                  text: '${_resendTimer}s',
                  style: TextStyle(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
              : GestureDetector(
            onTap: _resend,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Didn\'t receive it? ',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  TextSpan(
                    text: 'Resend',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final isFilled = _controllers[index].text.isNotEmpty;
    final hasError = _errorMsg != null;

    return SizedBox(
      width: 48,
      height: 58,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: hasError
                ? Colors.redAccent.shade200
                : AppColors.cream,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isFilled
                    ? AppColors.accent.withOpacity(0.6)
                    : AppColors.muted.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.redAccent.shade200
                    : AppColors.accent,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isFocused
                ? AppColors.accent.withOpacity(0.07)
                : AppColors.muted.withOpacity(0.06),
          ),
          onChanged: (val) => _onOtpChanged(index, val),
          onTap: () => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),

        const Center(child: LogoBar()),

        const SizedBox(height: 80),

        // Animated checkmark badge
        ScaleTransition(
          scale: _successScaleAnim,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          'Email verified!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.cream,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Your identity has been confirmed.\nYou\'re all set to continue.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.muted,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 48),

        TrackifyButton(
          label: 'Continue',
          onPressed: () {
            // Navigate to reset password or home
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}