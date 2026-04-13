// lib/ui/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}
