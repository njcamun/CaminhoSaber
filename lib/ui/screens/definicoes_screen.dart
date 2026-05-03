// lib/ui/screens/definicoes_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/dependentes_screen.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/providers/pomodoro_provider.dart';
import 'package:caminho_do_saber/providers/theme_provider.dart';
import 'package:caminho_do_saber/services/audio_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';

class DefinicoesScreen extends StatefulWidget {
  const DefinicoesScreen({super.key});

  @override
  State<DefinicoesScreen> createState() => _DefinicoesScreenState();
}

class _DefinicoesScreenState extends State<DefinicoesScreen> {
  final AuthService _authService = AuthService();
  bool _audioHabilitado = true;
  double _volumeGeral = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _audioHabilitado = prefs.getBool('audioHabilitado') ?? true;
        _volumeGeral = prefs.getDouble('volumeGeral') ?? 1.0;
      });
    }
  }

  Future<void> _handleAudioToggle(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _audioHabilitado = newValue);
    await prefs.setBool('audioHabilitado', newValue);
    context.read<AudioService>().updateSettings(newValue, _volumeGeral);
  }

  Future<void> _setVolumeGeral(double newVolume) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _volumeGeral = newVolume);
    await prefs.setDouble('volumeGeral', newVolume);
    context.read<AudioService>().updateSettings(_audioHabilitado, newVolume);
  }

  Future<void> _handleAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 10),
            Text('SAIR DA CONTA?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text('QUERES MESMO TERMINAR A TUA SESSÃO NESTE DISPOSITIVO?'.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('NÃO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('SIM, SAIR'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showPomodoroInfo(BuildContext context, bool currentVal, Function(bool) onToggle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(Icons.timer_rounded, color: AppColors.accent, size: 28),
            const SizedBox(width: 10),
            Text('MÉTODO POMODORO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FOCO TOTAL'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13)),
              const SizedBox(height: 6),
              Text('ESTUDA DURANTE 25 MINUTOS SEM DISTRAÇÕES E FAZ UMA PAUSA DE 5 MINUTOS PARA RECUPERAR ENERGIAS!'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCELAR'.toUpperCase(), style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            onPressed: () {
              onToggle(!currentVal);
              Navigator.pop(context);
            },
            child: Text((currentVal ? 'DESATIVAR' : 'ATIVAR AGORA!').toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) async {
    try {
      // Caminho corrigido para a pasta de assets registada no pubspec.yaml
      final String response = await rootBundle.loadString('assets/data/sobreNos.json');
      final data = json.decode(response)['welcomeInfo'];
      
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              const Icon(Icons.info_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data['title'].toString().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['description'].toString().toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, height: 1.5),
                ),
                const SizedBox(height: 20),
                _buildAboutSection(data['whoAreWe']['title'], data['whoAreWe']['text'], Icons.groups_rounded, AppColors.secondary),
                const SizedBox(height: 15),
                _buildAboutSection(data['location']['title'], (data['location']['text'] as List).join(", "), Icons.location_on_rounded, AppColors.accent),
                const SizedBox(height: 15),
                _buildAboutSection('CONTACTOS', "EMAIL: ${data['contacts']['email']}\nTEL: ${data['contacts']['phone']}", Icons.contact_mail_rounded, AppColors.tertiary),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('FECHAR'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Erro ao carregar sobreNos.json: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERRO AO CARREGAR INFORMAÇÕES: $e'.toUpperCase())),
        );
      }
    }
  }

  Widget _buildAboutSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        Text(content.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('AJUSTES'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        elevation: 4,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: BackgroundContainer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: StreamBuilder<User?>(
              stream: _authService.authStateChanges,
              builder: (context, snapshot) {
                final user = snapshot.data;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 25, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('CONTA E PERFIL'),
                      _buildNeumorphicSection(
                        child: InkWell(
                          onTap: _handleAuth,
                          borderRadius: BorderRadius.circular(25),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: ClipOval(
                                      child: SafeAssetImage(
                                        path: user?.photoURL ?? 'assets/images/foto.png',
                                        fit: BoxFit.cover,
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.isAnonymous == true ? 'VISITANTE' : (user?.displayName?.toUpperCase() ?? user?.email?.toUpperCase() ?? 'EXPLORADOR'),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (user?.isAnonymous == true ? 'TOQUE PARA SAIR' : (user?.email?.toUpperCase() ?? 'SESSÃO ATIVA')).toUpperCase(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.logout_rounded, color: AppColors.error),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (user != null && !user.isAnonymous) ...[
                        _buildSectionTitle('FAMÍLIA'),
                        _buildNeumorphicSection(
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DependentesScreen())),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            leading: const Icon(Icons.group_add_rounded, size: 28, color: AppColors.primary),
                            title: Text('GERIR PERFIS'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            subtitle: Text('ADICIONA OU EDITA PERFIS DE ESTUDO'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],

                      _buildSectionTitle('AMBIENTE'),
                      _buildNeumorphicSection(
                        child: Column(
                          children: [
                            Consumer<ThemeProvider>(
                              builder: (context, theme, _) => SwitchListTile(
                                activeColor: AppColors.accent,
                                title: Text('FILTRO DE LUZ AZUL'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                subtitle: Text('PROTEGE OS TEUS OLHOS DURANTE A NOITE'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                secondary: const Icon(Icons.nights_stay_rounded, color: AppColors.accent),
                                value: theme.isBlueLightFilterEnabled,
                                onChanged: (val) => theme.toggleBlueLightFilter(),
                              ),
                            ),
                            const Divider(indent: 70, endIndent: 20, height: 1),
                            SwitchListTile(
                              activeColor: AppColors.secondary,
                              title: Text('EFEITOS SONOROS'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              subtitle: Text('AUDIO FEEDBACK EM TODAS AS AÇÕES'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              secondary: const Icon(Icons.volume_up_rounded, color: AppColors.secondary),
                              value: _audioHabilitado,
                              onChanged: _handleAudioToggle,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(70, 0, 20, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('INTENSIDADE DO VOLUME'.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                                  Slider(
                                    value: _volumeGeral,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: _audioHabilitado ? _setVolumeGeral : null,
                                    activeColor: AppColors.primary,
                                    inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      _buildSectionTitle('FOCO'),
                      _buildNeumorphicSection(
                        child: Consumer<PomodoroProvider>(
                          builder: (context, pomodoro, _) => SwitchListTile(
                            activeColor: AppColors.accent,
                            title: Text('MÉTODO POMODORO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            subtitle: Text('CICLOS DE ESTUDO DE 25 MINUTOS'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            secondary: Icon(Icons.timer_rounded, color: pomodoro.isHabilitado ? AppColors.accent : Colors.blueGrey),
                            value: pomodoro.isHabilitado,
                            onChanged: (val) => _showPomodoroInfo(context, pomodoro.isHabilitado, (newVal) => pomodoro.togglePomodoro(newVal)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      _buildSectionTitle('INFORMAÇÕES'),
                      _buildNeumorphicSection(
                        child: Column(
                          children: [
                            _buildInfoTile(Icons.info_outline_rounded, 'SOBRE A APLICAÇÃO', onTap: () => _showAboutAppDialog(context)),
                            const Divider(indent: 70, endIndent: 20, height: 1),
                            _buildInfoTile(Icons.verified_user_rounded, 'POLÍTICA DE PRIVACIDADE'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('VERSÃO 1.0.1 (EDUAURA)'.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.primary)),
    );
  }

  Widget _buildNeumorphicSection({required Widget child}) {
    return NeumorphicWrapper(
      baseColor: Colors.white,
      borderRadius: 25,
      child: child,
    );
  }

  Widget _buildInfoTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }
}
