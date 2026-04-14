// lib/ui/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:caminho_do_saber/ui/widgets/auth_form_card.dart';
import 'package:caminho_do_saber/ui/widgets/custom_text_field.dart';
import 'package:caminho_do_saber/ui/widgets/custom_gradient_button.dart';
import 'package:caminho_do_saber/ui/screens/auth/register_screen.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signIn() async {
    final userCredential = await _authService.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return; 
    if (userCredential != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro no login. Verifique as credenciais.')),
      );
    }
  }

  void _signInAnonymously() async {
    final userCredential = await _authService.signInAnonymously();
    if (!mounted) return; 
    if (userCredential != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro no login anónimo.')),
      );
    }
  }

  void _signInWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();
    if (!mounted) return; 
    if (userCredential != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // On web redirect fallback, sign-in continues after page reload.
      if (kIsWeb && _authService.lastAuthError == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login com Google: ${_authService.lastAuthError ?? 'tente novamente'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 80),
                // ÍCONE AUMENTADO
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 180, // Aumentado de 130 para 180
                      height: 180, // Aumentado de 130 para 180
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Opacity(
                  opacity: 0.95,
                  child: AuthFormCard(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Bem-vindo!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          labelText: 'E-mail',
                          icon: Icons.email,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          labelText: 'Senha',
                          icon: Icons.lock,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Esqueceu a senha?'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomGradientButton(
                          text: 'LOGIN',
                          onPressed: _signIn,
                        ),
                        const SizedBox(height: 20),
                        CustomGradientButton(
                          text: 'ANÔNIMO',
                          onPressed: _signInAnonymously,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Ou', style: TextStyle(color: Colors.black, fontSize: 16)),
                    ),
                    Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Lottie.asset(
                        'assets/animations/google.json',
                        height: 100, 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset('assets/icons/google_icon.png', height: 50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('É novo aqui?', style: TextStyle(color: Colors.black, fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Crie a sua conta nova',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
