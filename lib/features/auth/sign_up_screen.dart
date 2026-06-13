import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/features/auth/widgets/divider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _agreed = false;

  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Password strength
  double _passStrength = 0;
  String _passStrengthLabel = '';
  Color _passStrengthColor = AppColors.muted;

  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _enterAnim, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _enterAnim.dispose();
    super.dispose();
  }

  void _checkStrength(String pass) {
    double strength = 0;
    if (pass.length >= 8) strength += 0.25;
    if (pass.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (pass.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (pass.contains(RegExp(r'[!@#\$%^&*]'))) strength += 0.25;

    setState(() {
      _passStrength = strength;
      if (strength <= 0.25) {
        _passStrengthLabel = 'Weak';
        _passStrengthColor = AppColors.coral;
      } else if (strength <= 0.5) {
        _passStrengthLabel = 'Fair';
        _passStrengthColor = AppColors.gold;
      } else if (strength <= 0.75) {
        _passStrengthLabel = 'Good';
        _passStrengthColor = AppColors.accentLight;
      } else {
        _passStrengthLabel = 'Strong';
        _passStrengthColor = AppColors.accent;
      }
    });
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = _emailError = _passError = _confirmError = null;

      if (_nameCtrl.text.trim().isEmpty) {
        _nameError = 'Full name is required';
        valid = false;
      }
      if (_emailCtrl.text.trim().isEmpty) {
        _emailError = 'Email is required';
        valid = false;
      } else if (!_emailCtrl.text.contains('@')) {
        _emailError = 'Enter a valid email address';
        valid = false;
      }
      if (_passCtrl.text.isEmpty) {
        _passError = 'Password is required';
        valid = false;
      } else if (_passCtrl.text.length < 6) {
        _passError = 'Password must be at least 6 characters';
        valid = false;
      }
      if (_confirmCtrl.text != _passCtrl.text) {
        _confirmError = 'Passwords do not match';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _signup() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
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
                      const SizedBox(height: 20),

                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.cream,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        AppStrings.signupTitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cream,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        AppStrings.signupSubtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Full name
                      TrackifyTextField(
                        hint: AppStrings.fullNameHint,
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _nameCtrl,
                        errorText: _nameError,
                        onChanged: (_) => setState(() => _nameError = null),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      TrackifyTextField(
                        hint: AppStrings.emailHint,
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),

                      const SizedBox(height: 16),

                      // Password
                      TrackifyTextField(
                        hint: AppStrings.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _passCtrl,
                        errorText: _passError,
                        onChanged: (v) {
                          setState(() => _passError = null);
                          _checkStrength(v);
                        },
                      ),

                      // Password strength bar
                      if (_passCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passStrength,
                                  backgroundColor: AppColors.inputBorder,
                                  valueColor: AlwaysStoppedAnimation(_passStrengthColor),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _passStrengthLabel,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _passStrengthColor,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Confirm password
                      TrackifyTextField(
                        hint: AppStrings.confirmPasswordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _confirmCtrl,
                        errorText: _confirmError,
                        onChanged: (_) => setState(() => _confirmError = null),
                        suffixWidget: _confirmCtrl.text.isNotEmpty
                            ? Icon(
                          _confirmCtrl.text == _passCtrl.text
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 18,
                          color: _confirmCtrl.text == _passCtrl.text
                              ? AppColors.accent
                              : AppColors.coral,
                        )
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // Terms checkbox
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: _agreed ? AppColors.accent : Colors.transparent,
                                border: Border.all(
                                  color: _agreed ? AppColors.accent : AppColors.inputBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: _agreed
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.muted,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Signup button
                      TrackifyButton(
                        label: AppStrings.signupBtn,
                        isLoading: _loading,
                        onPressed: _signup,
                      ),

                      const SizedBox(height: 26),

                      // Divider
                      const OrDivider(),

                      const SizedBox(height: 20),

                      // Google
                      TrackifyButton(
                        label: AppStrings.googleBtn,
                        outlined: true,
                        prefixIcon: Icons.g_mobiledata_rounded,
                        onPressed: () {},
                      ),

                      const SizedBox(height: 32),

                      // Login link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                              children: [
                                TextSpan(text: AppStrings.hasAccount, style: TextStyle(color: AppColors.muted)),
                                TextSpan(
                                  text: AppStrings.loginLink,
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

                      const SizedBox(height: 36),
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