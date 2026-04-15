// lib/ui/screens/definicoes_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/dependentes_screen.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/providers/pomodoro_provider.dart';
import 'package:caminho_do_saber/providers/theme_provider.dart';

class DefinicoesScreen extends StatefulWidget {
  const DefinicoesScreen({super.key});

  @override
  State<DefinicoesScreen> createState() => _DefinicoesScreenState();
}

class _DefinicoesScreenState extends State<DefinicoesScreen> {
  final AuthService _authService = AuthService();
  bool _audioHabilitado = true;
  double _volumeGeral = 1.0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _audioHabilitado = prefs.getBool('audioHabilitado') ?? true;
        _volumeGeral = prefs.getDouble('volumeGeral') ?? 1.0;
      });
    }
    await _audioPlayer.setVolume(_audioHabilitado ? _volumeGeral : 0.0);
  }

  Future<void> _handleAudioToggle(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _audioHabilitado = newValue;
    });
    await prefs.setBool('audioHabilitado', newValue);
    await _audioPlayer.setVolume(newValue ? _volumeGeral : 0.0);
  }

  Future<void> _setVolumeGeral(double newVolume) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volumeGeral = newVolume;
    });
    await prefs.setDouble('volumeGeral', newVolume);
    if (_audioHabilitado) {
      await _audioPlayer.setVolume(newVolume);
    }
  }

  Future<void> _handleAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminar Sessão?'),
        content: const Text('Queres mesmo sair da tua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim', style: TextStyle(color: Colors.red))),
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
            Icon(Icons.timer_rounded, color: currentVal ? Colors.grey : Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            const Text('Método Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O que é?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                SizedBox(height: 4),
                Text('É uma técnica de gestão de tempo que usa um temporizador para dividir o estudo em intervalos de 25 minutos, separados por breves pausas.'),
                SizedBox(height: 16),
                Text('✅ Vantagens:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('• Aumenta o foco e a agilidade mental.\n• Evita a fadiga em sessões longas.\n• Cria um ritmo saudável de recompensas (pausas).'),
                SizedBox(height: 16),
                Text('⚠️ Desvantagens:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text('• Pode interromper o "fluxo" se estiveres muito concentrado.\n• Exige disciplina para respeitar os tempos.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentVal ? Colors.grey : Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              onToggle(!currentVal);
              Navigator.pop(context);
            },
            child: Text(currentVal ? 'Desativar Agora' : 'Ativar Agora!', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 4,
        foregroundColor: Colors.white,
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle(context, 'Conta'),
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white.withValues(alpha: 0.95),
                        child: InkWell(
                          onTap: _handleAuth,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue.shade100,
                                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                                  child: user?.photoURL == null ? const Icon(Icons.person, size: 30, color: Colors.blue) : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(fit: BoxFit.scaleDown, child: Text(user?.isAnonymous == true ? 'Visitante' : (user?.displayName ?? user?.email ?? 'Anónimo'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent))),
                                      FittedBox(fit: BoxFit.scaleDown, child: Text(user?.isAnonymous == true ? 'Toque para sair' : (user?.email ?? 'Terminar sessão'), style: TextStyle(fontSize: 14, color: Colors.grey.shade700))),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.logout, color: Colors.redAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (user != null && !user.isAnonymous) ...[
                        _buildSectionTitle(context, 'Dependentes'),
                        Card(
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.white.withValues(alpha: 0.95),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DependentesScreen()));
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.group_add_rounded, size: 30, color: Colors.blueAccent),
                                  SizedBox(width: 16),
                                  Expanded(child: Text('Gerir Perfis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      _buildSectionTitle(context, 'Personalização'),
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white.withValues(alpha: 0.95),
                        child: Column(
                          children: [
                            Consumer<ThemeProvider>(
                              builder: (context, theme, child) {
                                return SwitchListTile(
                                  title: const Text('Filtro de Luz Azul', style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: const Text('Protege os teus olhos durante a noite.', style: TextStyle(fontSize: 12)),
                                  secondary: const Icon(Icons.remove_red_eye_rounded, color: Colors.orangeAccent),
                                  value: theme.isBlueLightFilterEnabled,
                                  onChanged: (val) => theme.toggleBlueLightFilter(),
                                );
                              },
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            SwitchListTile(
                              title: const Text('Áudio Global', style: TextStyle(fontWeight: FontWeight.bold)),
                              secondary: const Icon(Icons.volume_up, color: Colors.teal),
                              activeThumbColor: Colors.blue,
                              value: _audioHabilitado,
                              onChanged: _handleAudioToggle,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(children: [Icon(Icons.music_note, size: 20, color: Colors.grey), SizedBox(width: 8), Text('Volume Geral', style: TextStyle(fontSize: 14))]),
                                  Slider(
                                    value: _volumeGeral,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: _audioHabilitado ? _setVolumeGeral : null,
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.blue.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle(context, 'Foco e Estudo'),
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white.withValues(alpha: 0.95),
                        child: Consumer<PomodoroProvider>(
                          builder: (context, pomodoro, child) {
                            return SwitchListTile(
                              title: const Text('Modo Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Ciclos de 25 min de estudo e 5 min de pausa.', style: TextStyle(fontSize: 12)),
                              secondary: Icon(Icons.timer_rounded, color: pomodoro.isHabilitado ? Colors.redAccent : Colors.grey),
                              activeThumbColor: Colors.redAccent,
                              value: pomodoro.isHabilitado,
                              onChanged: (val) => _showPomodoroInfo(context, pomodoro.isHabilitado, (newVal) => pomodoro.togglePomodoro(newVal)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle(context, 'Informações'),
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white.withValues(alpha: 0.95),
                        child: Column(
                          children: [
                            ListTile(leading: const Icon(Icons.info_outline, color: Colors.blue), title: const Text('Sobre a Aplicação', style: TextStyle(fontWeight: FontWeight.bold)), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () {}),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(leading: const Icon(Icons.person_outline, color: Colors.blue), title: const Text('Sobre o Programador', style: TextStyle(fontWeight: FontWeight.bold)), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () {}),
                          ],
                        ),
                      ),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(children: [
        Text(title.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3))),
      ]),
    );
  }
}
