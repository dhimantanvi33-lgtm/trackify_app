import 'package:flutter/material.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/features/auth/widgets/logo_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import 'otp_verify.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _emailSent = false;
  String? _emailError;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final Animation<double> _successFadeAnim;

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
    _successFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _enterAnim,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _enterAnim.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _emailError = null;
      if (_emailCtrl.text.trim().isEmpty) {
        _emailError = 'Email is required';
        valid = false;
      } else if (!_emailCtrl.text.contains('@')) {
        _emailError = 'Enter a valid email address';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _sendResetLink() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _loading = false);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) =>
              OtpVerifyScreen(destination: _emailCtrl.text.trim()),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 380),
        ),
      );
    }
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Logo
                      const Center(child: LogoBar()),

                      const SizedBox(height: 44),

                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Back to Login',
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
                          _emailSent
                              ? Icons.mark_email_read_outlined
                              : Icons.lock_reset_rounded,
                          color: AppColors.accent,
                          size: 26,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        _emailSent ? 'Check your inbox' : 'Forgot password?',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cream,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _emailSent
                            ? 'We\'ve sent a reset link to ${_emailCtrl.text.trim()}. Check your spam folder if you don\'t see it.'
                            : 'No worries — enter your email and we\'ll send you a link to reset your password.',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 36),

                      if (!_emailSent) ...[
                        // Email field
                        TrackifyTextField(
                          hint: AppStrings.emailHint,
                          prefixIcon: Icons.email_outlined,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) =>
                              setState(() => _emailError = null),
                        ),

                        const SizedBox(height: 28),

                        // Send button
                        TrackifyButton(
                          label: 'Send Reset Link',
                          isLoading: _loading,
                          onPressed: _sendResetLink,
                        ),
                      ] else ...[
                        // Success card
                        FadeTransition(
                          opacity: _successFadeAnim,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                    AppColors.accent.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reset link sent!',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.cream,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'The link expires in 15 minutes.',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: AppColors.muted,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend option
                        TrackifyButton(
                          label: 'Resend Email',
                          outlined: true,
                          prefixIcon: Icons.refresh_rounded,
                          onPressed: () {
                            setState(() {
                              _emailSent = false;
                              _emailCtrl.clear();
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Help text
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Need help? ',
                                style:
                                TextStyle(color: AppColors.muted),
                              ),
                              TextSpan(
                                text: 'Contact support',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}