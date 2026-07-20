import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trackify/provider/auth_provider.dart';
import 'package:trackify/screens/auth/forgot_password.dart';
import 'package:trackify/screens/auth/sign_up_screen.dart';
import 'package:trackify/screens/auth/widgets/bg_glow.dart';
import 'package:trackify/screens/auth/widgets/logo_bar.dart';
import 'package:trackify/screens/dashboard/dash_board.dart';

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
      CurvedAnimation(
        parent: _enterAnim,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
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

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
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
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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

                      const Center(child: LogoBar()),

                      const SizedBox(height: 44),

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

                      TrackifyTextField(
                        hint: AppStrings.emailHint,
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) {
                          setState(() => _emailError = null);
                          auth.clearError();
                        },
                      ),

                      const SizedBox(height: 16),

                      TrackifyTextField(
                        hint: AppStrings.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _passCtrl,
                        errorText: _passError,
                        onChanged: (_) {
                          setState(() => _passError = null);
                          auth.clearError();
                        },
                      ),

                      // General Firebase auth error (wrong password, user not found, etc.)
                      if (auth.status == AuthStatus.error &&
                          auth.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 14, color: Colors.redAccent.shade200),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.redAccent.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgotPasswordScreen(),
                              ),
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

                      TrackifyButton(
                        label: AppStrings.loginBtn,
                        isLoading: auth.isLoading,
                        onPressed: _login,
                      ),

                      const SizedBox(height: 36),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, anim, __) =>
                              const SignupScreen(),
                              transitionsBuilder: (_, anim, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOutCubic)),
                                  child: child,
                                );
                              },
                              transitionDuration:
                              const Duration(milliseconds: 380),
                            ),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style:
                              TextStyle(fontFamily: 'Inter', fontSize: 14),
                              children: [
                                TextSpan(
                                  text: AppStrings.noAccount,
                                  style: TextStyle(color: AppColors.muted),
                                ),
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