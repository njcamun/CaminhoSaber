// lib/ui/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/widgets/custom_text_field.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';

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
            const SnackBar(content: Text('Erro no registo. Tente novamente.')),
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
          SnackBar(content: Text('Erro no registo: $errorMessage')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar uma Conta'),
      ),
      body: BackgroundContainer(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26.0), // SUGESTÃO 5: const
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 8.0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(75.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // SUGESTÃO 5: const
                Card(
                  color: Colors.white.withOpacity(0.8),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0), // SUGESTÃO 5: const
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text( // SUGESTÃO 5: const (se TextStyle também for)
                            'Bem-vindo ao Caminho do Saber!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24), // SUGESTÃO 5: const
                          CustomTextField(
                            labelText: 'E-mail',
                            icon: Icons.email,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, insira o seu e-mail';
                              }
                              // SUGESTÃO 4: Validação de email melhorada
                              final emailRegex = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Por favor, insira um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16), // SUGESTÃO 5: const
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
                          const SizedBox(height: 16), // SUGESTÃO 5: const
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
                          const SizedBox(height: 24), // SUGESTÃO 5: const
                          ElevatedButton(
                            // SUGESTÃO 1: Desabilitar botão e mostrar indicador de carregamento
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16), // SUGESTÃO 5: const
                              textStyle: const TextStyle(fontSize: 18), // SUGESTÃO 5: const
                            ),
                            child: _isLoading
                                ? const SizedBox( // SUGESTÃO 5: const
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text('Criar Conta'), // SUGESTÃO 5: const
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
