// lib/ui/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/screens/resultados_screen.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/widgets/quiz_option_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_crt_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_typewriter_text.dart';
import 'package:caminho_do_saber/ui/widgets/retro_pixel_explosion.dart';
import 'package:caminho_do_saber/ui/widgets/points_flyer.dart';
import 'package:caminho_do_saber/services/audio_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final List<PerguntaQuiz> perguntas;
  final String disciplinaId;
  final Disciplina disciplina;
  final int capituloIndex;
  final List<FlashCard> flashCards;

  const QuizScreen({
    super.key,
    required this.perguntas,
    required this.disciplinaId,
    required this.disciplina,
    required this.capituloIndex,
    required this.flashCards,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  late AudioService _audioService;
  late ProgressoService _progressoService;

  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  int _perguntaAtualIndex = 0;
  bool _respostaSelecionada = false;
  String? _respostaSelecionadaTexto;

  bool _isMusicPlaying = false;

  Timer? _timer;
  int _segundosRestantes = 15;
  static const int _tempoMaximoPergunta = 15;

  Timer? _timerGlobal;
  int _segundosRestantesGlobal = 120;
  final int _tempoMaximoGlobal = 120;

  bool _ajuda5050Usada = false;
  bool _ajudaDicaUsada = false;
  bool _ajudaPulaUsada = false;
  List<String> _opcoesRemovidas = [];

  late List<PerguntaQuiz> _perguntasBaralhadas;
  List<String> _opcoesAtuaisBaralhadas = [];

  final List<Map<String, dynamic>> _respostasUtilizador = [];
  int _penalidadeAjudas = 0;
  int _pontosBase = 0;
  int _penalidadeTempo = 0;
  int _bonusTempo = 0;

  @override
  void initState() {
    super.initState();
    _audioService = context.read<AudioService>();
    _progressoService = context.read<ProgressoService>();
    _playQuizMusic();
    _perguntasBaralhadas = List.from(widget.perguntas)..shuffle();
    _prepararPerguntaAtual();
    _iniciarTemporizadorPergunta();
    _iniciarTemporizadorGlobal();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timerGlobal?.cancel();
    _audioService.stopMusic();
    super.dispose();
  }

  void _prepararPerguntaAtual() {
    final pergunta = _perguntasBaralhadas[_perguntaAtualIndex];
    _opcoesAtuaisBaralhadas = List.from(pergunta.opcoes)..shuffle();
    _opcoesRemovidas.clear();
    _respostaSelecionada = false;
    _respostaSelecionadaTexto = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      if (_isMusicPlaying) _audioService.stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      if (_isMusicPlaying) _playQuizMusic();
    }
  }

  void _iniciarTemporizadorPergunta() {
    _segundosRestantes = _tempoMaximoPergunta;
    _timer?.cancel();
    final currentSession = _sessionId;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSession != _sessionId || !mounted || _quizFinalizado) {
        timer.cancel();
        return;
      }
      if (_segundosRestantes > 0) {
        setState(() => _segundosRestantes--);
      } else {
        _timer?.cancel();
        _verificarResposta('', Offset.zero);
      }
    });
  }

  void _resetarTemporizadorPergunta() {
    _timer?.cancel();
    _iniciarTemporizadorPergunta();
  }

  void _iniciarTemporizadorGlobal() {
    final currentSession = _sessionId;
    _timerGlobal = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSession != _sessionId || !mounted || _quizFinalizado) {
        timer.cancel();
        return;
      }
      if (_segundosRestantesGlobal > 0) {
        setState(() => _segundosRestantesGlobal--);
      } else {
        _timerGlobal?.cancel();
        _mostrarResultadoFinal();
      }
    });
  }

  void _passarParaProximaPergunta() {
    _timer?.cancel();
    if (_perguntaAtualIndex < _perguntasBaralhadas.length - 1) {
      if(mounted) {
        setState(() {
          _perguntaAtualIndex++;
          _prepararPerguntaAtual();
        });
      }
      _resetarTemporizadorPergunta();
    } else {
      _mostrarResultadoFinal();
    }
  }

  Future<void> _playQuizMusic() async {
    await _audioService.playMusic('desafio.mp3');
    _isMusicPlaying = true;
  }

  void _use5050() {
    if (_ajuda5050Usada || _respostaSelecionada) return;
    setState(() {
      _ajuda5050Usada = true;
      _penalidadeAjudas += 3;
      final perguntaAtual = _perguntasBaralhadas[_perguntaAtualIndex];
      final List<String> opcoesIncorretas = _opcoesAtuaisBaralhadas
          .where((opcao) => opcao != perguntaAtual.respostaCorreta)
          .toList();
      opcoesIncorretas.shuffle();
      _opcoesRemovidas = opcoesIncorretas.take(2).toList();
    });
  }

  void _useHint() {
    if (_ajudaDicaUsada || _respostaSelecionada) return;
    
    final perguntaAtual = _perguntasBaralhadas[_perguntaAtualIndex];
    final String dicaTexto = (perguntaAtual.dica != null && perguntaAtual.dica!.isNotEmpty) 
        ? perguntaAtual.dica!.toUpperCase() 
        : "HUM... ESTA PERGUNTA É UM DESAFIO! TENTA ELIMINAR AS OPÇÕES QUE PARECEM ERRADAS!";

    setState(() {
      _ajudaDicaUsada = true;
      _penalidadeAjudas += 2;
    });

    _showHelpDialog('Dica de Estudo', dicaTexto, Icons.lightbulb_rounded, AppColors.accent);
  }

  void _showHelpDialog(String title, String content, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87)),
          ],
        ),
        content: Text(content.toUpperCase(), style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color, 
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ENTENDI!'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white))
          )
        ],
      ),
    );
  }

  void _skipQuestion() {
    if (_ajudaPulaUsada || _respostaSelecionada) return;
    setState(() {
      _ajudaPulaUsada = true;
      _penalidadeAjudas += 3;
    });
    _verificarResposta(null, Offset.zero);
  }

  void _verificarResposta(String? resposta, Offset tapPosition) {
    if (_respostaSelecionada) return;
    _timer?.cancel();
    bool estaCorreta = (resposta != null && resposta == _perguntasBaralhadas[_perguntaAtualIndex].respostaCorreta);
    
    if (estaCorreta) {
      _pontosBase += 5;
      HapticFeedback.mediumImpact();
      _audioService.playSfx('correct.mp3');
      if (tapPosition != Offset.zero) {
        showPointsFlyer(context, tapPosition);
        showPixelExplosion(context, tapPosition, AppColors.success);
      }
    } else {
      HapticFeedback.vibrate();
      _audioService.playSfx('incorrect.mp3');
      if (tapPosition != Offset.zero) {
        showPixelExplosion(context, tapPosition, AppColors.error);
      }
    }

    _respostasUtilizador.add({
      'pergunta': _perguntasBaralhadas[_perguntaAtualIndex],
      'respostaDada': resposta,
      'correta': estaCorreta,
    });
    if(mounted) {
      setState(() {
        _respostaSelecionada = true;
        _respostaSelecionadaTexto = resposta;
      });
    }
    
    final currentSession = _sessionId;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && currentSession == _sessionId && !_quizFinalizado) {
        _passarParaProximaPergunta();
      }
    });
  }

  bool _quizFinalizado = false;

  Future<void> _mostrarResultadoFinal() async {
    if (_quizFinalizado) return;
    _quizFinalizado = true;

    _audioService.stopMusic();

    _isMusicPlaying = false;
    _timer?.cancel();
    _timerGlobal?.cancel();

    int pontuacaoFinal = _pontosBase - _penalidadeAjudas;
    if (_segundosRestantesGlobal > (_tempoMaximoGlobal - 60)) {
      _bonusTempo = 2;
    } else if (_segundosRestantesGlobal <= 0) {
      _penalidadeTempo = 1;
    }
    pontuacaoFinal += _bonusTempo;
    pontuacaoFinal -= _penalidadeTempo;

    final totalPontosPossiveis = _perguntasBaralhadas.length * 5;
    pontuacaoFinal = pontuacaoFinal.clamp(0, totalPontosPossiveis);

    int estrelas = 0;
    bool desbloqueado = false;
    if (totalPontosPossiveis > 0) {
      double percentagem = (pontuacaoFinal / totalPontosPossiveis) * 100;
      if (percentagem >= 80) {
        desbloqueado = true;
        estrelas = (percentagem / 20).floor();
      }
    }

    final String capituloId = '${widget.disciplinaId}_capitulo_${widget.capituloIndex}';
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultadosScreen(
            pontuacaoFinal: pontuacaoFinal,
            totalPontosPossiveis: totalPontosPossiveis,
            estrelas: estrelas,
            respostasUtilizador: _respostasUtilizador,
            desbloqueadoProximoNivel: desbloqueado,
            disciplinaId: widget.disciplinaId,
            disciplina: widget.disciplina,
            capituloIndex: widget.capituloIndex,
            flashCards: widget.flashCards,
            penalidadeAjudas: _penalidadeAjudas,
            penalidadeTempo: _penalidadeTempo,
            pontosBase: _pontosBase,
            bonusTempo: _bonusTempo,
          ),
        ),
      );
    }

    unawaited(
      _progressoService.saveProgresso(capituloId, pontuacaoFinal)
        .timeout(const Duration(seconds: 8))
        .catchError((e) => debugPrint('Sync background error: $e'))
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.perguntas.isEmpty) return Scaffold(body: Center(child: Text("NENHUMA PERGUNTA ENCONTRADA.".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))));
    
    final perguntaAtual = _perguntasBaralhadas[_perguntaAtualIndex];
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    String formatTime(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
      return '$minutes:$remainingSeconds';
    }

    Color getTimerColor(int seconds) {
      if (seconds <= 3) return AppColors.error;
      if (seconds <= 7) return AppColors.accent;
      return AppColors.success;
    }

    return RetroCRTWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(fit: BoxFit.scaleDown, child: const Text('DESAFIO DO SABER', style: TextStyle(fontWeight: FontWeight.w600))),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 4,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              alignment: Alignment.center,
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(formatTime(_segundosRestantesGlobal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        body: BackgroundContainer(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, isTablet ? 80 : 60),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  color: Colors.white.withValues(alpha: 0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PERGUNTA ${_perguntaAtualIndex + 1}/${_perguntasBaralhadas.length}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                            Text('$_segundosRestantes S', style: TextStyle(fontWeight: FontWeight.w600, color: getTimerColor(_segundosRestantes))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: LinearProgressIndicator(
                            value: _segundosRestantes / _tempoMaximoPergunta,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _segundosRestantes <= 5
                                ? (_segundosRestantes % 2 == 0 ? AppColors.error : AppColors.accent)
                                : getTimerColor(_segundosRestantes)
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: size.height * 0.2),
                          child: SingleChildScrollView(
                            child: RetroTypewriterText(
                              text: perguntaAtual.pergunta,
                              style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._opcoesAtuaisBaralhadas.map((opcao) {
                          if (_opcoesRemovidas.contains(opcao)) return const SizedBox.shrink();

                          bool isSelected = _respostaSelecionada && opcao == _respostaSelecionadaTexto;
                          bool isCorrect = opcao == perguntaAtual.respostaCorreta;

                          Color targetBgColor = isSelected
                              ? (isCorrect ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1))
                              : Colors.white.withValues(alpha: 0.9);

                          Color targetBorderColor = isSelected
                              ? (isCorrect ? AppColors.success : AppColors.error)
                              : Colors.blue.shade100;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Listener(
                              onPointerDown: (details) {
                                if (!_respostaSelecionada) {
                                  _verificarResposta(opcao, details.position);
                                }
                              },
                              child: QuizOptionWrapper(
                                isSelected: isSelected,
                                isCorrect: isCorrect,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: targetBgColor,
                                    foregroundColor: Colors.black87,
                                    disabledBackgroundColor: targetBgColor,
                                    disabledForegroundColor: Colors.black87,
                                    padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 16, horizontal: 20),
                                    elevation: isSelected ? 0 : 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side: BorderSide(color: targetBorderColor, width: 2),
                                    ),
                                  ),
                                  onPressed: null,
                                  child: Text(opcao.toUpperCase(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          );
                        }),

                        if (_segundosRestantesGlobal <= 10)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                FittedBox(fit: BoxFit.scaleDown, child: Text('A T E N Ç Ã O ! !'.toUpperCase(), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 70))),
                                const SizedBox(height: 4),
                                Text(
                                  '$_segundosRestantesGlobal',
                                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w600, color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAjudaButton(
                        onTap: _ajuda5050Usada || _respostaSelecionada ? null : _use5050,
                        icon: Icons.star_half,
                        label: '50/50',
                        isUsed: _ajuda5050Usada,
                      ),
                      _buildAjudaButton(
                        onTap: _ajudaDicaUsada || _respostaSelecionada ? null : _useHint,
                        icon: Icons.lightbulb_outline,
                        label: 'DICA',
                        isUsed: _ajudaDicaUsada,
                      ),
                      _buildAjudaButton(
                        onTap: _ajudaPulaUsada || _respostaSelecionada ? null : _skipQuestion,
                        icon: Icons.skip_next,
                        label: 'PULAR',
                        isUsed: _ajudaPulaUsada,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAjudaButton({required VoidCallback? onTap, required IconData icon, required String label, required bool isUsed}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isUsed ? AppColors.accent : Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(color: isUsed ? AppColors.accent : Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
