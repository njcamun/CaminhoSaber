// lib/ui/screens/daily_challenge_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/screens/arcade_quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/services/content_provider_service.dart';
import 'package:caminho_do_saber/ui/widgets/edu_loading_widget.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _isLoading = false;
  DateTime? _lastChallengeTime;
  Timer? _countdownTimer;
  String _timeRemaining = "";

  bool _mysteryUsedToday = false;
  bool _mixUsedToday = false;

  @override
  void initState() {
    super.initState();
    _loadState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeStr = prefs.getString('last_daily_challenge_time');
    final lastMysteryStr = prefs.getString('last_mystery_challenge_date');
    final lastMixStr = prefs.getString('last_mix_challenge_date');
    
    final today = DateTime.now().toIso8601String().split('T')[0];

    setState(() {
      if (lastTimeStr != null) _lastChallengeTime = DateTime.parse(lastTimeStr);
      _mysteryUsedToday = lastMysteryStr == today;
      _mixUsedToday = lastMixStr == today;
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastChallengeTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastChallengeTime!);
        if (difference.inHours < 24) {
          final remaining = const Duration(hours: 24) - difference;
          setState(() {
            _timeRemaining = _formatDuration(remaining);
          });
        } else {
          setState(() {
            _timeRemaining = "";
          });
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _handleChallengeAccess(String type) async {
    final progressoService = Provider.of<ProgressoService>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    int cost = 0;
    bool alreadyUsed = false;

    if (type == '24h') {
      if (_timeRemaining.isNotEmpty) return;
    } else if (type == 'disciplina') {
      if (_mysteryUsedToday) {
        cost = 4;
        alreadyUsed = true;
      }
    } else if (type == 'mix') {
      if (_mixUsedToday) {
        cost = 8;
        alreadyUsed = true;
      }
    }

    if (alreadyUsed) {
      if (progressoService.totalDiamantes < cost) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                  const SizedBox(width: 10),
                  Expanded(child: Text('DIAMANTES INSUFICIENTES!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.error))),
                ],
              ),
              content: Text('Não tens diamantes suficientes para desbloquear este desafio novamente.\n\nConquiste-os através dos Quizzes e das Leituras Diárias!'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('ENTENDIDO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)))
              ],
            ),
          );
        }
        return;
      }

      final confirm = await _showPaymentDialog(cost);
      if (!confirm) return;

      await progressoService.saveProgresso('payment_challenge_${DateTime.now().millisecondsSinceEpoch}', -cost, tipo: 'payment');
    }

    if (type == 'disciplina') {
      await prefs.setString('last_mystery_challenge_date', today);
    } else if (type == 'mix') {
      await prefs.setString('last_mix_challenge_date', today);
    }

    _startChallenge(type);
  }

  Future<bool> _showPaymentDialog(int cost) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.lock_open_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('DESAFIO JÁ REALIZADO!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
          ],
        ),
        content: Text('Já completaste este desafio hoje. Queres desbloquear novamente por $cost diamantes azuis?'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('AGORA NÃO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('DESBLOQUEAR'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _startChallenge(String type) async {
    setState(() => _isLoading = true);
    
    try {
      final String response = await rootBundle.loadString('assets/data/disciplinas.json');
      final List<dynamic> discData = json.decode(response);
      final List<Disciplina> disciplinas = discData.map((j) => Disciplina.fromJson(j)).toList();

      List<PerguntaQuiz> allQuestionsPool = [];
      String challengeTitle = "Desafio";
      String challengeId = "daily_challenge";
      bool isUnlimited = false;

      if (type == '24h') {
        challengeTitle = "Desafio 24 Horas";
        for (var d in disciplinas) {
          final questions = await _loadQuestionsFromDisciplina(d.id);
          allQuestionsPool.addAll(questions);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_daily_challenge_time', DateTime.now().toIso8601String());
        _loadState();
      } else if (type == 'disciplina') {
        final randomDisc = disciplinas[Random().nextInt(disciplinas.length)];
        challengeTitle = "Disciplina Mistério";
        challengeId = randomDisc.id;
        allQuestionsPool = await _loadQuestionsFromDisciplina(randomDisc.id);
      } else if (type == 'mix') {
        challengeTitle = "Mega Mix";
        for (var d in disciplinas) {
          final questions = await _loadQuestionsFromDisciplina(d.id);
          allQuestionsPool.addAll(questions);
        }
        isUnlimited = true;
      }

      allQuestionsPool.shuffle();
      final List<PerguntaQuiz> finalQuestions = isUnlimited ? allQuestionsPool : allQuestionsPool.take(30).toList();

      if (finalQuestions.isEmpty) throw Exception("Sem perguntas disponíveis.");

      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ArcadeQuizScreen(
            perguntas: finalQuestions,
            disciplinaNome: challengeTitle,
            disciplinaId: challengeId,
          ),
        ),
      );

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<PerguntaQuiz>> _loadQuestionsFromDisciplina(String id) async {
    try {
      final String response = await rootBundle.loadString('assets/data/$id.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> quizzes = data['quizzes'] ?? [];
      List<PerguntaQuiz> questions = [];
      for (var q in quizzes) {
        final List<dynamic> perguntasJson = q['perguntas'] ?? [];
        questions.addAll(perguntasJson.map((p) => PerguntaQuiz.fromJson(p)).toList());
      }
      return questions;
    } catch (_) { return []; }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('DESAFIOS DIÁRIOS'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        elevation: 4,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: BackgroundContainer(
        child: _isLoading
        ? EduLoadingWidget(message: 'A PREPARAR O TEU DESAFIO...')
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('ESCOLHE A TUA MISSÃO'),
                    
                    _buildChallengeCard(
                      title: 'DESAFIO 24H',
                      subtitle: _timeRemaining.isEmpty ? '30 PERGUNTAS NOVAS TODOS OS DIAS!' : 'DISPONÍVEL EM: $_timeRemaining',
                      icon: Icons.history_toggle_off_rounded,
                      color: AppColors.primary,
                      onTap: () => _handleChallengeAccess('24h'),
                      isDisabled: _timeRemaining.isNotEmpty,
                      isTablet: isTablet
                    ),
                    
                    _buildChallengeCard(
                      title: 'DISCIPLINA MISTÉRIO',
                      subtitle: _mysteryUsedToday ? 'GASTA 4 DIAMANTES PARA REPETIR!' : 'FOCA NUMA MATÉRIA ALEATÓRIA.',
                      icon: Icons.psychology_rounded,
                      color: AppColors.tertiary,
                      onTap: () => _handleChallengeAccess('disciplina'),
                      costLabel: _mysteryUsedToday ? '4 💎' : 'GRÁTIS',
                      isTablet: isTablet
                    ),
                    
                    _buildChallengeCard(
                      title: 'MEGA MIX',
                      subtitle: _mixUsedToday ? 'GASTA 8 DIAMANTES PARA REPETIR!' : 'TODAS AS PERGUNTAS SEM LIMITES!',
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.accent,
                      onTap: () => _handleChallengeAccess('mix'),
                      costLabel: _mixUsedToday ? '8 💎' : 'GRÁTIS',
                      isTablet: isTablet
                    ),

                    const SizedBox(height: 30),
                    
                    NeumorphicWrapper(
                      baseColor: Colors.white,
                      borderRadius: 25,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 28),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'REGRAS ARCADE: 60 SEGUNDOS, 3 VIDAS, BÓNUS DE TEMPO E COMBOS ATIVOS!'.toUpperCase(), 
                                style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
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

  Widget _buildChallengeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
    String? costLabel,
    required bool isTablet,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ScalePressWrapper(
        onTap: isDisabled ? () {
          HapticFeedback.vibrate();
        } : onTap,
        child: NeumorphicWrapper(
          baseColor: Colors.white,
          borderRadius: 25,
          child: Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isDisabled ? Colors.grey.withValues(alpha: 0.2) : color.withValues(alpha: 0.1), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12), 
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), 
                    child: Icon(icon, color: color, size: isTablet ? 40 : 32)
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      FittedBox(fit: BoxFit.scaleDown, child: Text(title.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16))),
                      if (costLabel != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)), child: Text(costLabel.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10))),
                    ]),
                    const SizedBox(height: 4),
                    Text(subtitle.toUpperCase(), style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(width: 10),
                  Icon(isDisabled ? Icons.lock_clock_rounded : Icons.play_arrow_rounded, color: isDisabled ? Colors.grey : color, size: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
