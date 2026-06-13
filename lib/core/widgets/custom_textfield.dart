import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class TrackifyTextField extends StatefulWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;

  const TrackifyTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.suffixWidget,
  });

  @override
  State<TrackifyTextField> createState() => _TrackifyTextFieldState();
}

class _TrackifyTextFieldState extends State<TrackifyTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusAnim;
  late final Animation<double> _borderGlow;
  late final Animation<double> _labelSlide;
  bool _focused = false;
  bool _obscured = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    _focusNode = FocusNode();
    _focusAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _borderGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusAnim, curve: Curves.easeOut),
    );
    _labelSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusAnim, curve: Curves.easeOut),
    );
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _focusAnim.forward();
      } else {
        _focusAnim.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusAnim.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return AnimatedBuilder(
      animation: _focusAnim,
      builder: (context, _) {
        final borderColor = hasError
            ? AppColors.error
            : Color.lerp(AppColors.inputBorder, AppColors.inputBorderFocus, _borderGlow.value)!;

        final glowColor = hasError
            ? AppColors.error.withOpacity(0.15 * _borderGlow.value)
            : AppColors.accent.withOpacity(0.12 * _borderGlow.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: _focused ? 1.5 : 1),
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Prefix icon with animated color
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: Color.lerp(AppColors.muted, AppColors.accent, _borderGlow.value),
                    ),
                  ),

                  // Text field
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      obscureText: widget.obscure ? _obscured : false,
                      keyboardType: widget.keyboardType,
                      onChanged: widget.onChanged,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.cream,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: AppColors.accent,
                      cursorWidth: 1.5,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 17),
                      ),
                    ),
                  ),

                  // Suffix: toggle visibility or custom widget
                  if (widget.obscure)
                    GestureDetector(
                      onTap: () => setState(() => _obscured = !_obscured),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            key: ValueKey(_obscured),
                            size: 20,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    )
                  else if (widget.suffixWidget != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: widget.suffixWidget,
                    ),
                ],
              ),
            ),

            // Error text
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      widget.errorText!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}