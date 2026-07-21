import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackify/provider/auth_provider.dart';
import 'package:trackify/screens/auth/widgets/bg_glow.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
    _currentCtrl.dispose();
    _newCtrl.dispose();
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
      _currentError = _newError = _confirmError = null;

      if (_currentCtrl.text.isEmpty) {
        _currentError = 'Current password is required';
        valid = false;
      }
      if (_newCtrl.text.isEmpty) {
        _newError = 'New password is required';
        valid = false;
      } else if (_newCtrl.text.length < 6) {
        _newError = 'Password must be at least 6 characters';
        valid = false;
      } else if (_newCtrl.text == _currentCtrl.text) {
        _newError = 'New password must be different from current';
        valid = false;
      }
      if (_confirmCtrl.text != _newCtrl.text) {
        _confirmError = 'Passwords do not match';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      Navigator.pop(context);
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
                      const SizedBox(height: 20),

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

                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cream,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your current password and choose a new one.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      TrackifyTextField(
                        hint: 'Current password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _currentCtrl,
                        errorText: _currentError,
                        onChanged: (_) {
                          setState(() => _currentError = null);
                          auth.clearError();
                        },
                      ),

                      const SizedBox(height: 16),

                      TrackifyTextField(
                        hint: 'New password',
                        prefixIcon: Icons.lock_reset_rounded,
                        obscure: true,
                        controller: _newCtrl,
                        errorText: _newError,
                        onChanged: (v) {
                          setState(() => _newError = null);
                          auth.clearError();
                          _checkStrength(v);
                        },
                      ),

                      if (_newCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passStrength,
                                  backgroundColor: AppColors.inputBorder,
                                  valueColor:
                                  AlwaysStoppedAnimation(_passStrengthColor),
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

                      TrackifyTextField(
                        hint: 'Confirm new password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _confirmCtrl,
                        errorText: _confirmError,
                        onChanged: (_) => setState(() => _confirmError = null),
                        suffixWidget: _confirmCtrl.text.isNotEmpty
                            ? Icon(
                          _confirmCtrl.text == _newCtrl.text
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 18,
                          color: _confirmCtrl.text == _newCtrl.text
                              ? AppColors.accent
                              : AppColors.coral,
                        )
                            : null,
                      ),

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

                      const SizedBox(height: 28),

                      TrackifyButton(
                        label: 'Update Password',
                        isLoading: auth.isLoading,
                        onPressed: _submit,
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