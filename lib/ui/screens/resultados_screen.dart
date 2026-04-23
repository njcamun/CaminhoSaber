// lib/ui/screens/resultados_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/ui/screens/quiz_screen.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/screens/flash_card_screen.dart';
import 'package:caminho_do_saber/ui/widgets/achievement_overlay.dart';
import 'package:caminho_do_saber/ui/screens/conteudo_screen.dart';
import 'package:caminho_do_saber/ui/screens/capitulos_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/services/audio_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';

class ResultadosScreen extends StatefulWidget {
  final int pontuacaoFinal;
  final int totalPontosPossiveis;
  final int estrelas;
  final bool desbloqueadoProximoNivel;
  final List<Map<String, dynamic>> respostasUtilizador;
  final String disciplinaId;
  final Disciplina disciplina;
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
    required this.disciplina,
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

  @override
  void initState() {
    super.initState();
    _iniciarAnimacao();
  }

  void _playSound(String fileName) {
    context.read<AudioService>().playSfx(fileName);
  }

  void _iniciarAnimacao() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showPontosBase = true);
      _playSound('hint.mp3');
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _showBonusTempo = true);
      _playSound('hint.mp3');
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _showPenalidadeAjudas = true);
      _playSound('hint.mp3');
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _showPenalidadeTempo = true);
      _playSound('hint.mp3');
    }
    
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showTotalFinal = true);
      _playSound('hint.mp3');

      if (widget.pontuacaoFinal > 0) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            AchievementOverlay.show(
              context,
              title: 'PONTOS GANHOS!'.toUpperCase(),
              message: 'CONCLUÍSTE O DESAFIO E GANHASTE ${widget.pontuacaoFinal} PONTOS!'.toUpperCase(),
              icon: Icons.trending_up_rounded,
              color: AppColors.accent
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool sucesso = widget.desbloqueadoProximoNivel;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('TEU DESEMPENHO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 120),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // CARD DE RESULTADO PRINCIPAL
                  NeumorphicWrapper(
                    baseColor: Colors.white,
                    borderRadius: 30,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
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
                          Column(
                            children: [
                              if (!kIsWeb)
                                Lottie.asset(
                                  sucesso ? 'assets/animations/sucesso.json' : 'assets/animations/falha.json',
                                  width: 140,
                                  height: 140,
                                  repeat: true,
                                )
                              else
                                Icon(sucesso ? Icons.check_circle_rounded : Icons.error_outline_rounded, 
                                  size: 100, color: sucesso ? AppColors.success : AppColors.error),
                              const SizedBox(height: 15),
                              Text(
                                sucesso ? 'PARABÉNS!' : 'QUASE LÁ!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: sucesso ? AppColors.success : AppColors.error,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (sucesso ? 'Nível desbloqueado com sucesso!' : 'Faltou um pouco para avançar.').toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      Icons.stars_rounded,
                                      color: index < widget.estrelas ? AppColors.accent : Colors.grey.withValues(alpha: 0.2),
                                      size: isTablet ? 55 : 45,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('RESUMO DE PONTOS'),
                  NeumorphicWrapper(
                    baseColor: Colors.white,
                    borderRadius: 25,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildScoreRow('ACERTOS BASE', '+${widget.pontosBase}', AppColors.success, Icons.check_circle_outline, _showPontosBase),
                          _buildScoreRow('BÓNUS VELOCIDADE', '+${widget.bonusTempo}', AppColors.primary, Icons.timer_outlined, _showBonusTempo),
                          _buildScoreRow('PENALIDADE AJUDAS', '-${widget.penalidadeAjudas}', AppColors.error, Icons.help_outline, _showPenalidadeAjudas),
                          _buildScoreRow('PENALIDADE TEMPO', '-${widget.penalidadeTempo}', AppColors.error, Icons.hourglass_empty, _showPenalidadeTempo),

                          AnimatedOpacity(
                            opacity: _showTotalFinal ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 600),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Divider(thickness: 2, color: Colors.black12),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TOTAL FINAL'.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                                    Text('${widget.pontuacaoFinal} PTS', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('REVISÃO DAS RESPOSTAS'),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      itemCount: widget.respostasUtilizador.length,
                      itemBuilder: (context, index) {
                        final resp = widget.respostasUtilizador[index];
                        final bool correta = resp['correta'] as bool;
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ScalePressWrapper(
                            onTap: () => _showReviewDialog(context, resp, index + 1),
                            child: NeumorphicWrapper(
                              baseColor: correta ? AppColors.success : AppColors.error,
                              borderRadius: 25,
                              child: Container(
                                width: 110,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Q${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                                    const SizedBox(height: 5),
                                    Icon(correta ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded, color: Colors.white, size: 32),
                                    const SizedBox(height: 8),
                                    Text('VER'.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTÕES DE AÇÃO
                  Column(
                    children: [
                      if (sucesso)
                        _buildActionButton(
                          context,
                          'PRÓXIMO NÍVEL',
                          Icons.arrow_forward_rounded,
                          AppColors.success,
                          () => Navigator.of(context).pop(),
                        ),
                      const SizedBox(height: 15),
                      _buildActionButton(
                        context,
                        'REFAZER O QUIZ',
                        Icons.refresh_rounded,
                        AppColors.primary,
                        () => _refazerQuiz(context),
                      ),
                      const SizedBox(height: 15),
                      _buildActionButton(
                        context,
                        'ESTUDAR LIÇÃO (+15 PTS)',
                        Icons.menu_book_rounded,
                        AppColors.accent,
                        () => _lerConteudo(context),
                      ),
                      const SizedBox(height: 15),
                      if (!sucesso)
                        _buildActionButton(
                          context,
                          'REFORÇO CARTÃO DE ESTUDO',
                          Icons.style_rounded,
                          AppColors.tertiary,
                          () => _irParaFlashcards(context),
                        ),
                      const SizedBox(height: 10),
                      ScalePressWrapper(
                        onTap: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.home_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'VOLTAR AO INÍCIO'.toUpperCase(),
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color, IconData icon, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w900)),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ScalePressWrapper(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
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
              Icon(correta ? Icons.check_circle_rounded : Icons.cancel_rounded, 
                color: correta ? AppColors.success : AppColors.error, size: 28),
              const SizedBox(width: 10),
              Text('REVISÃO Q$num'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PERGUNTA:'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 11)),
                const SizedBox(height: 6),
                Text(p.pergunta.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                const SizedBox(height: 20),
                Text('TUA RESPOSTA:'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                const SizedBox(height: 6),
                Text((data['respostaDada'] ?? 'Sem resposta').toString().toUpperCase(), 
                  style: TextStyle(color: correta ? AppColors.success : AppColors.error, fontWeight: FontWeight.w900, fontSize: 14)),
                if (!correta) ...[
                  const SizedBox(height: 20),
                  Text('RESPOSTA CORRETA:'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(p.respostaCorreta.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 14)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ENTENDIDO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
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
          disciplina: widget.disciplina,
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
          titulo: 'REFORÇO',
          flashCards: widget.flashCards,
        ),
      ),
    );
  }

  void _lerConteudo(BuildContext context) {
    // Redireciona para a tela de listagem de capítulos da disciplina
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CapitulosScreen(
          disciplina: widget.disciplina,
        ),
      ),
    );
  }
}
