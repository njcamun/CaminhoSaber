// lib/ui/screens/resultados_screen.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/ui/screens/quiz_screen.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/screens/flash_card_screen.dart';
import 'package:caminho_do_saber/ui/widgets/achievement_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultadosScreen extends StatefulWidget {
  final int pontuacaoFinal;
  final int totalPontosPossiveis;
  final int estrelas;
  final bool desbloqueadoProximoNivel;
  final List<Map<String, dynamic>> respostasUtilizador;
  final String disciplinaId;
  final int capituloIndex;
  final List<FlashCard> flashCards;
  final int penalidadeAjudas;
  final int penalidadeTempo;
  final int pontosBase;
  final int bonusTempo;

  const ResultadosScreen({
    super.key,
    required this.pontuacaoFinal,
    required this.totalPontosPossiveis,
    required this.estrelas,
    required this.desbloqueadoProximoNivel,
    required this.respostasUtilizador,
    required this.disciplinaId,
    required this.capituloIndex,
    required this.flashCards,
    required this.penalidadeAjudas,
    required this.penalidadeTempo,
    required this.pontosBase,
    required this.bonusTempo,
  });

  @override
  _ResultadosScreenState createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  bool _showPontosBase = false;
  bool _showPenalidadeAjudas = false;
  bool _showPenalidadeTempo = false;
  bool _showBonusTempo = false;
  bool _showTotalFinal = false;
  bool _isDisposed = false;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioHabilitado = true;

  @override
  void initState() {
    super.initState();
    _loadAudioSettings();
    _iniciarAnimacao();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudioSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _audioHabilitado = prefs.getBool('audioHabilitado') ?? true;
      });
    }
  }

  void _playSound(String fileName) async {
    if (_audioHabilitado) {
      try {
        final player = AudioPlayer();
        await player.play(AssetSource('sounds/$fileName'));
        player.onPlayerComplete.listen((_) {
          player.dispose();
        });
      } catch (_) {}
    }
  }

  void _iniciarAnimacao() async {
    // Sequência de revelação dos pontos um a um com efeito sonoro
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || _isDisposed) return;
    setState(() => _showPontosBase = true);
    _playSound('hint.mp3');
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _isDisposed) return;
    setState(() => _showBonusTempo = true);
    _playSound('hint.mp3');
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _isDisposed) return;
    setState(() => _showPenalidadeAjudas = true);
    _playSound('hint.mp3');
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _isDisposed) return;
    setState(() => _showPenalidadeTempo = true);
    _playSound('hint.mp3');
    
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || _isDisposed) return;
    setState(() => _showTotalFinal = true);
    _playSound('hint.mp3');
    
    // Mostrar animação de conquista se ganhou pontos (XP)
    if (widget.pontuacaoFinal > 0) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && !_isDisposed) {
        AchievementOverlay.show(
          context, 
          title: 'Pontos Ganhos!', 
          message: 'Concluíste o desafio e ganhaste ${widget.pontuacaoFinal} XP!', 
          icon: Icons.trending_up_rounded, 
          color: Colors.orangeAccent
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool sucesso = widget.desbloqueadoProximoNivel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teu Desempenho', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: BackgroundContainer(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              children: [
                // 1. CARD PRINCIPAL DE CELEBRAÇÃO
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.95),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (sucesso && !kIsWeb)
                        Positioned.fill(
                          child: Lottie.asset(
                            'assets/animations/festejo.json',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        child: Column(
                          children: [
                            if (!kIsWeb)
                              Lottie.asset(
                                sucesso ? 'assets/animations/sucesso.json' : 'assets/animations/falha.json',
                                width: 140,
                                height: 140,
                                repeat: true,
                                errorBuilder: (context, error, stackTrace) => Icon(sucesso ? Icons.check_circle : Icons.error, size: 100, color: sucesso ? Colors.green : Colors.orange),
                              )
                            else
                              Icon(sucesso ? Icons.check_circle : Icons.error, size: 100, color: sucesso ? Colors.green : Colors.orange),
                            const SizedBox(height: 10),
                            Text(
                              sucesso ? 'PARABÉNS!' : 'QUASE LÁ!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: sucesso ? Colors.green.shade700 : Colors.orange.shade800,
                              ),
                            ),
                            Text(
                              sucesso ? 'Nível desbloqueado com sucesso!' : 'Faltou um pouco para avançar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.stars_rounded,
                                  color: index < widget.estrelas ? Colors.amber : Colors.grey.withOpacity(0.3),
                                  size: 40,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. RESUMO DA PONTUAÇÃO (COM ANIMAÇÃO UM A UM)
                _buildSectionTitle(context, 'Resumo de Pontos'),
                Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildScoreRow('Acertos Base', '+${widget.pontosBase}', Colors.green, Icons.check_circle_outline, _showPontosBase),
                        _buildScoreRow('Bónus Velocidade', '+${widget.bonusTempo}', Colors.blue, Icons.timer_outlined, _showBonusTempo),
                        _buildScoreRow('Penalidade Ajudas', '-${widget.penalidadeAjudas}', Colors.red, Icons.help_outline, _showPenalidadeAjudas),
                        _buildScoreRow('Penalidade Tempo', '-${widget.penalidadeTempo}', Colors.redAccent, Icons.hourglass_empty, _showPenalidadeTempo),
                        
                        AnimatedOpacity(
                          opacity: _showTotalFinal ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              const Divider(height: 30, thickness: 1.5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('TOTAL FINAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  Text('${widget.pontuacaoFinal} pts', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blue)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. REVISÃO RÁPIDA (HORIZONTAL)
                _buildSectionTitle(context, 'Revisão das Respostas'),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.respostasUtilizador.length,
                    itemBuilder: (context, index) {
                      final resp = widget.respostasUtilizador[index];
                      final bool correta = resp['correta'] as bool;
                      return GestureDetector(
                        onTap: () => _showReviewDialog(context, resp, index + 1),
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: correta ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Q${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 4),
                              Icon(correta ? Icons.check_circle_outline : Icons.highlight_off_rounded, color: Colors.white, size: 28),
                              const SizedBox(height: 8),
                              const Text('DETALHES', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // 4. BOTÕES DE AÇÃO
                Column(
                  children: [
                    if (sucesso)
                      _buildActionButton(
                        context,
                        'PRÓXIMO NÍVEL',
                        Icons.arrow_forward_rounded,
                        Colors.green.shade600,
                        () => Navigator.of(context).pop(),
                      ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      context,
                      'REFAZER O QUIZ',
                      Icons.refresh_rounded,
                      Colors.blue.shade700,
                      () => _refazerQuiz(context),
                    ),
                    const SizedBox(height: 12),
                    if (!sucesso)
                      _buildActionButton(
                        context,
                        'ESTUDAR CARTÕES',
                        Icons.style_rounded,
                        Colors.purple.shade600,
                        () => _irParaFlashcards(context),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        ),
                        icon: Icon(Icons.home_rounded, color: Colors.blue.shade900),
                        label: Text(
                          'VOLTAR AO INÍCIO',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade900, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.white.withOpacity(0.8),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: textColor,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: Colors.white24, thickness: 1.5)),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color, IconData icon, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color.withOpacity(0.7)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 15, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> data, int num) {
    final PerguntaQuiz p = data['pergunta'] as PerguntaQuiz;
    final bool correta = data['correta'] as bool;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(correta ? Icons.check_circle_rounded : Icons.cancel_rounded, color: correta ? Colors.green : Colors.red),
              const SizedBox(width: 10),
              Text('Revisão Q$num'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pergunta:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 4),
                Text(p.pergunta),
                const SizedBox(height: 16),
                const Text('Tua Resposta:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data['respostaDada'] ?? 'Sem resposta', style: TextStyle(color: correta ? Colors.green : Colors.red)),
                if (!correta) ...[
                  const SizedBox(height: 16),
                  const Text('Resposta Correta:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(p.respostaCorreta),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _refazerQuiz(BuildContext context) {
    final List<PerguntaQuiz> perguntas = widget.respostasUtilizador.map((e) => e['pergunta'] as PerguntaQuiz).toList();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          perguntas: perguntas,
          disciplinaId: widget.disciplinaId,
          capituloIndex: widget.capituloIndex,
          flashCards: widget.flashCards,
        ),
      ),
    );
  }

  void _irParaFlashcards(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashCardScreen(
          titulo: 'Reforço',
          flashCards: widget.flashCards,
        ),
      ),
    );
  }
}
