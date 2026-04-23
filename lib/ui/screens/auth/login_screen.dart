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
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                const SizedBox(height: 15),
                Text(
                  'ATENÇÃO'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.error),
                ),
                const SizedBox(height: 10),
                Text(
                  message.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'ENTENDI',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        final userCredential = await _authService.signInWithEmail(email, password);
        
        if (!mounted) return;

        if (userCredential != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          _showErrorDialog('Credenciais incorretas. Verifique os dados e tente novamente.');
        }
      } catch (e) {
        _showErrorDialog('Ocorreu um erro ao entrar. Verifique a sua ligação.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _signInAnonymously() async {
    final userCredential = await _authService.signInAnonymously();
    if (!mounted) return; 
    if (userCredential != null) {
      // Mostrar aviso de visitante
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, color: AppColors.primary, size: 40),
                  const SizedBox(height: 15),
                  Text(
                    'MODO VISITANTE'.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fizeste login como visitante. Lembra-te que os teus dados não serão guardados para o ranking global.'.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                        child: Text(
                        'CONTINUAR',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      _showErrorDialog('Erro no login anónimo. Tente novamente mais tarde.');
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
      if (kIsWeb && _authService.lastAuthError == null) return;
      _showErrorDialog('Erro no login com Google: ${_authService.lastAuthError ?? 'tente novamente'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: BackgroundContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40.0 : 24.0,
              vertical: 10.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5),
                Image.asset(
                  'assets/icons/logo_B.png',
                  width: size.width * 0.9 > 480 ? 480 : size.width * 0.9,
                  height: size.width * 0.9 > 480 ? 480 : size.width * 0.9,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 100, color: AppColors.primary),
                ),
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Opacity(
                          opacity: 0.95,
                          child: Container(
                            width: isTablet ? 500 : double.infinity,
                            child: AuthFormCard(
                              child: Column(
                                children: <Widget>[
                                  const Text(
                                    'BEM-VINDO!',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    labelText: 'E-mail',
                                    icon: Icons.email,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, insira o seu e-mail';
                                      }
                                      final emailRegex = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                                      if (!emailRegex.hasMatch(value.trim())) {
                                        return 'Por favor, insira um e-mail válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    labelText: 'Senha',
                                    icon: Icons.lock,
                                    isPassword: true,
                                    controller: _passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira a sua senha';
                                      }
                                      if (value.length < 6) {
                                        return 'A senha deve ter pelo menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                                      child: const Text(
                                        'ESQUECEU A SENHA?',
                                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _isLoading 
                                    ? const CircularProgressIndicator(color: AppColors.primary)
                                    : CustomGradientButton(
                                        key: const ValueKey('login_btn'),
                                        text: 'LOGIN',
                                        onPressed: _signIn,
                                      ),
                                  const SizedBox(height: 8),
                                  CustomGradientButton(
                                    key: const ValueKey('anon_btn'),
                                    text: 'ANÔNIMO',
                                    onPressed: _signInAnonymously,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: isTablet ? 500 : double.infinity,
                          child: Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.primary, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Ou'.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                              const Expanded(child: Divider(color: AppColors.primary, thickness: 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: _signInWithGoogle,
                              child: Lottie.asset(
                                'assets/animations/google.json',
                                height: isTablet ? 80 : 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Image.asset('assets/icons/google_icon.png', height: 35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('É NOVO AQUI?'.toUpperCase(), style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 30)),
                              child: Text(
                                'CRIE A SUA CONTA NOVA'.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
