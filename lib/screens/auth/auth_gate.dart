import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackify/features/auth/login_screen.dart';
import 'package:trackify/features/dashboard/dash_board.dart';
import 'package:trackify/provider/auth_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}