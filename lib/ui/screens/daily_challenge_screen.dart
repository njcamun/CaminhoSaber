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
      // VERIFICAÇÃO DE RECURSOS (DIAMANTES)
      if (progressoService.totalDiamantes < cost) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Diamantes Insuficientes!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              content: const Text('Não tens diamantes suficientes para desbloquear este desafio novamente.\n\nConquiste-os através dos Quizzes e das Leituras Diárias!'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))
              ],
            ),
          );
        }
        return;
      }

      final confirm = await _showPaymentDialog(cost);
      if (!confirm) return;

      // Descontar diamantes (valor negativo usando o tipo payment)
      await progressoService.saveProgresso('payment_challenge_${DateTime.now().millisecondsSinceEpoch}', -cost, tipo: 'payment');
    }

    // Marcar como usado hoje para controlo de custos
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Desafio já realizado!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Já completaste este desafio hoje. Queres desbloquear novamente por $cost diamantes azuis?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Agora não')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desbloquear'),
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
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Crucial para ver a imagem de fundo
        appBar: AppBar(
          title: const Text('Desafios', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue,
          elevation: 4,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.white), SizedBox(height: 20), Text('A preparar o desafio...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]))
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('ESCOLHE O TEU DESAFIO!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5, shadows: [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2))])),
                  const SizedBox(height: 30),
                  
                  _buildChallengeCard(
                    title: 'DESAFIO 24H',
                    subtitle: _timeRemaining.isEmpty ? 'Um conjunto novo de 30 perguntas a cada dia.' : 'Próximo desafio grátis em: $_timeRemaining',
                    icon: Icons.history_toggle_off_rounded,
                    color: Colors.orange.shade800,
                    onTap: () => _handleChallengeAccess('24h'),
                    isDisabled: _timeRemaining.isNotEmpty,
                  ),
                  
                  _buildChallengeCard(
                    title: 'DISCIPLINA MISTÉRIO',
                    subtitle: _mysteryUsedToday ? 'Gasta 4 diamantes para repetir!' : 'Foca numa matéria aleatória.',
                    icon: Icons.question_mark_rounded,
                    color: Colors.purple.shade700,
                    onTap: () => _handleChallengeAccess('disciplina'),
                    costLabel: _mysteryUsedToday ? '4 💎' : 'Grátis',
                  ),
                  
                  _buildChallengeCard(
                    title: 'MEGA MIX',
                    subtitle: _mixUsedToday ? 'Gasta 8 diamantes para repetir!' : 'Todas as perguntas sem limites!',
                    icon: Icons.psychology_rounded,
                    color: Colors.teal.shade700,
                    onTap: () => _handleChallengeAccess('mix'),
                    costLabel: _mixUsedToday ? '8 💎' : 'Grátis',
                  ),

                  const SizedBox(height: 40),
                  const Card(color: Colors.white24, child: Padding(padding: EdgeInsets.all(16.0), child: Row(children: [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 15), Expanded(child: Text('Regras Arcade Ativas: 60 segundos iniciais, 3 vidas, bónus de tempo e combos!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))])))
                ],
              ),
            ),
          ),
      ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 6))],
              border: Border.all(color: isDisabled ? Colors.grey : color, width: 2),
            ),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDisabled ? Colors.grey : color, borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: Colors.white, size: 35)),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(title, style: TextStyle(color: isDisabled ? Colors.grey : color, fontWeight: FontWeight.w900, fontSize: 18)),
                    if (costLabel != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(costLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
                  ]),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                ])),
                Icon(isDisabled ? Icons.lock_clock_rounded : Icons.play_circle_fill_rounded, color: isDisabled ? Colors.grey : color, size: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
