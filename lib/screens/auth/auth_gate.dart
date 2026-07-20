import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trackify/provider/auth_provider.dart';
import 'package:trackify/screens/auth/login_screen.dart';
import 'package:trackify/screens/dashboard/dash_board.dart';

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