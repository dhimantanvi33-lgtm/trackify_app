import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class LogoBar extends StatelessWidget {
  const LogoBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.accentLight],
            ),
          ),
          child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 9),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}