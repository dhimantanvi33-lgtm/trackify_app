import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackify/features/auth/forgot_password.dart';
import 'package:trackify/features/auth/sign_up_screen.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/features/auth/widgets/divider.dart';
import 'package:trackify/features/auth/widgets/logo_bar.dart';
import 'package:trackify/features/dashboard/dash_board.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _emailError;
  String? _passError;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _enterAnim.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _emailError = null;
      _passError = null;

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
    });
    return valid;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const DashboardScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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

                      // Title
                      const Text(
                        AppStrings.loginTitle,
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
                        AppStrings.loginSubtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Email field
                      TrackifyTextField(
                        hint: AppStrings.emailHint,
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      TrackifyTextField(
                        hint: AppStrings.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _passCtrl,
                        errorText: _passError,
                        onChanged: (_) => setState(() => _passError = null),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Login button
                      TrackifyButton(
                        label: AppStrings.loginBtn,
                        isLoading: _loading,
                        onPressed: _login,
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      const OrDivider(),

                      const SizedBox(height: 20),

                      // Google button
                      TrackifyButton(
                        label: AppStrings.googleBtn,
                        outlined: true,
                        prefixIcon: Icons.g_mobiledata_rounded,
                        onPressed: () {},
                      ),

                      const SizedBox(height: 36),

                      // Sign up link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, anim, __) => const SignupScreen(),
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
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                              children: [
                                TextSpan(text: AppStrings.noAccount, style: TextStyle(color: AppColors.muted)),
                                TextSpan(
                                  text: AppStrings.signupLink,
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

