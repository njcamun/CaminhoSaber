// lib/ui/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/widgets/custom_text_field.dart';
import 'package:caminho_do_saber/ui/widgets/custom_gradient_button.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/auth_form_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  // SUGESTÃO 1: Adicionar estado para controle de carregamento
  bool _isLoading = false;

  // SUGESTÃO 3: Dispor os controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Verifica se o formulário é válido
    if (_formKey.currentState?.validate() ?? false) {
      // SUGESTÃO 1: Atualizar UI para mostrar carregamento
      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential = await _authService.registerWithEmail(
          _emailController.text.trim(), // Adicionar .trim() para remover espaços
          _passwordController.text,
        );

        if (!mounted) return; // Verificar se o widget ainda está montado

        if (userCredential != null) {
          // SUGESTÃO (Opcional - Navegação): Considerar pushAndRemoveUntil se quiser limpar a pilha
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Este 'else' pode não ser alcançado se registerWithEmail lançar exceções para erros
          // A lógica de erro é melhor tratada no bloco catch
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no registo. Tente novamente.'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
          );
        }
        // SUGESTÃO 2: Melhorar o tratamento de erros
      } catch (e) {
        if (!mounted) return;
        // Mostrar uma mensagem de erro mais específica
        String errorMessage = 'Ocorreu um erro desconhecido.';
        if (e is FormatException) { // Exemplo, personalize para os erros do seu AuthService
          errorMessage = e.message;
        } else if (e.toString().contains('email-already-in-use')) { // Exemplo de tratamento de erro do Firebase Auth
          errorMessage = 'Este e-mail já está em uso.';
        } else if (e.toString().contains('weak-password')) { // Exemplo
          errorMessage = 'A palavra-passe é muito fraca.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no registo: $errorMessage'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
        );
      } finally {
        // SUGESTÃO 1: Garantir que o estado de carregamento seja redefinido
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'assets/icons/logo_B.png',
                  height: 520,
                  width: 520,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 120, color: AppColors.primary),
                ),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: AuthFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'BEM-VINDO AO CAMINHO DO SABER!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 16),
                          CustomTextField(
                            labelText: 'Palavra-passe',
                            icon: Icons.lock,
                            isPassword: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a palavra-passe';
                              }
                              if (value.length < 6) {
                                return 'A palavra-passe deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            labelText: 'Confirmar Palavra-passe',
                            icon: Icons.lock,
                            isPassword: true,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, confirme a palavra-passe';
                              }
                              if (value != _passwordController.text) {
                                return 'As palavras-passe não correspondem';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                  ),
                                )
                              : CustomGradientButton(
                                  key: const ValueKey('register_submit_btn'),
                                  text: 'CRIAR CONTA',
                                  onPressed: _submitForm,
                                ),
                        ],
                      ),
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
