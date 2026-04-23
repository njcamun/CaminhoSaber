// lib/ui/screens/arcade_quiz_screen.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/quiz_option_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_crt_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_typewriter_text.dart';
import 'package:caminho_do_saber/ui/widgets/retro_pixel_explosion.dart';
import 'package:caminho_do_saber/ui/widgets/points_flyer.dart';
import 'package:caminho_do_saber/services/audio_service.dart';

class ArcadeQuizScreen extends StatefulWidget {
  final List<PerguntaQuiz> perguntas;
  final String disciplinaNome;
  final String disciplinaId;

  const ArcadeQuizScreen({
    super.key,
    required this.perguntas,
    required this.disciplinaNome,
    required this.disciplinaId,
  });

  @override
  State<ArcadeQuizScreen> createState() => _ArcadeQuizScreenState();
}

class _ArcadeQuizScreenState extends State<ArcadeQuizScreen> with TickerProviderStateMixin {
  late AudioService _audioService;
  late ProgressoService _progressoService;

  int _pontos = 0;
  int _tempoRestante = 60;
  int _oportunidades = 3; 
  int _comboConsecutivo = 0;
  int _acertosParaTempo = 0;
  int _acertosParaVida = 0;
  int _perguntaAtualIndex = 0;
  
  late List<PerguntaQuiz> _listaPerguntas;
  List<String> _opcoesAtuaisBaralhadas = [];
  String? _opcaoSelecionada; 
  bool _estaProcessando = false; 
  bool _isGameOver = false;

  bool _tempoAdicionalUsado = false;
  bool _ajuda5050Usada = false;
  bool _ajudaDicaUsada = false;
  bool _puloUsado = false;
  
  List<String> _opcoesRemovidas = [];
  Timer? _timer;
  bool _audioHabilitado = true;

  String _feedbackText = "";
  IconData _feedbackIcon = Icons.star;
  Color _feedbackColor = AppColors.accent;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _rotationAnimation;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _audioService = context.read<AudioService>();
    _progressoService = context.read<ProgressoService>();
    _loadSettings();
    _startTimer();
    _playMusic();

    _listaPerguntas = List.from(widget.perguntas);
    _prepararPerguntaAtual();

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.stopMusic();
    _feedbackController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _prepararPerguntaAtual() {
    final pergunta = _listaPerguntas[_perguntaAtualIndex];
    _opcoesAtuaisBaralhadas = List.from(pergunta.opcoes)..shuffle();
    _opcoesRemovidas.clear();
    _opcaoSelecionada = null;
    _estaProcessando = false;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _audioHabilitado = prefs.getBool('audioHabilitado') ?? true;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameOver) {
        timer.cancel();
        return;
      }

      if (_tempoRestante > 0) {
        if(mounted) {
          setState(() {
            _tempoRestante--;
            if (_tempoRestante <= 10 && _tempoRestante > 0) {
              _pulseController.repeat(reverse: true);
            } else {
              _pulseController.stop();
            }
          });
        }
      }
      
      if (_tempoRestante <= 0 && !_isGameOver) {
        _finishGame("TEMPO ESGOTADO!");
      }
    });
  }

  void _showCentralFeedback(String text, IconData icon, Color color) {
    setState(() {
      _feedbackText = text;
      _feedbackIcon = icon;
      _feedbackColor = color;
    });
    _feedbackController.forward(from: 0.0);
    _playSound('hint.mp3'); 
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _feedbackController.reverse();
    });
  }

  int get _multiplicador {
    if (_comboConsecutivo >= 20) return 3;
    if (_comboConsecutivo >= 10) return 2;
    return 1;
  }

  void _verificarResposta(String resposta, Offset tapPosition) async {
    if (_estaProcessando || _isGameOver) return;
    
    setState(() {
      _estaProcessando = true;
      _opcaoSelecionada = resposta;
    });

    final correta = _listaPerguntas[_perguntaAtualIndex].respostaCorreta;
    final bool acertou = (resposta == correta);

    if (acertou) {
      HapticFeedback.mediumImpact();
      if (tapPosition != Offset.zero) {
        showPointsFlyer(context, tapPosition);
        showPixelExplosion(context, tapPosition, AppColors.success);
      }
      setState(() {
        _pontos += 5 * _multiplicador; 
        _comboConsecutivo++;
        _acertosParaTempo++;
        _acertosParaVida++;
        
        if (_acertosParaTempo >= 4) {
          _tempoRestante += 15;
          _acertosParaTempo = 0;
          _showCentralFeedback("+15 SEGUNDOS!", Icons.timer_outlined, AppColors.primary);
        }

        if (_acertosParaVida >= 5) {
          if (_oportunidades < 5) {
            _oportunidades++;
            _showCentralFeedback("+1 VIDA!", Icons.favorite_rounded, AppColors.success);
          }
          _acertosParaVida = 0;
        }

        if (_comboConsecutivo == 10) {
          _pontos += 25;
          _showCentralFeedback("COMBO X2 ATIVO!", Icons.bolt_rounded, AppColors.orange);
        } else if (_comboConsecutivo == 20) {
          _pontos += 100;
          _showCentralFeedback("MEDALHA! X3 ATIVO!", Icons.workspace_premium_rounded, AppColors.gold);
          _progressoService.registerSpecialAchievement('medalha');
        } else if (_comboConsecutivo == 30) {
          _pontos += 250;
          _showCentralFeedback("DIAMANTE!", Icons.diamond_rounded, Colors.cyan);
          _progressoService.registerSpecialAchievement('diamante');
        }

        if (_comboConsecutivo % 15 == 0) {
          _tempoAdicionalUsado = false;
          _ajuda5050Usada = false;
          _ajudaDicaUsada = false;
          _puloUsado = false;
          _showCentralFeedback("AJUDAS RESTAURADAS!", Icons.auto_fix_high_rounded, Colors.tealAccent.shade700);
        }
      });
      _playSound('correct.mp3');
    } else {
      HapticFeedback.heavyImpact();
      if (tapPosition != Offset.zero) {
        showPixelExplosion(context, tapPosition, AppColors.error);
      }
      setState(() {
        _oportunidades--;
        _comboConsecutivo = 0;
        _acertosParaTempo = 0;
        _acertosParaVida = 0;
      });
      _playSound('incorrect.mp3');
      
      if (_oportunidades <= 0) {
        _finishGame("SEM OPORTUNIDADES!");
        return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!_isGameOver) {
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    if (!mounted || _isGameOver) return;
    setState(() {
      _perguntaAtualIndex++;
      if (_perguntaAtualIndex >= _listaPerguntas.length) {
        _perguntaAtualIndex = 0;
      }
      _prepararPerguntaAtual();
    });
  }

  void _use5050() {
    if (_ajuda5050Usada || _estaProcessando || _isGameOver) return;
    final pergunta = _listaPerguntas[_perguntaAtualIndex];
    final incorrectas = _opcoesAtuaisBaralhadas.where((o) => o != pergunta.respostaCorreta).toList();
    incorrectas.shuffle();
    setState(() {
      _opcoesRemovidas = incorrectas.take(2).toList();
      _ajuda5050Usada = true;
    });
    _playSound('hint.mp3');
  }

  void _useHint() {
    if (_ajudaDicaUsada || _estaProcessando || _isGameOver) return;
    final pergunta = _listaPerguntas[_perguntaAtualIndex];
    setState(() => _ajudaDicaUsada = true);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent, size: 28),
            const SizedBox(width: 10),
            Text('DICA MÁGICA'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text(pergunta.dica?.toUpperCase() ?? 'PRESTA ATENÇÃO ÀS OPÇÕES, A RESPOSTA ESTÁ LÁ!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('ENTENDIDO!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.accent)))
        ],
      ),
    );
    _playSound('hint.mp3');
  }

  void _useSkip() {
    if (_puloUsado || _estaProcessando || _isGameOver) return;
    setState(() => _puloUsado = true);
    _showCentralFeedback("PULASTE!", Icons.skip_next_rounded, Colors.grey);
    _nextQuestion();
  }

  Future<void> _finishGame(String titulo) async {
    if (_isGameOver) return;
    setState(() {
      _isGameOver = true;
      _estaProcessando = true;
    });
    
    _timer?.cancel();
    _pulseController.stop();
    _audioService.stopMusic();
    
    final currentScore = _pontos;
    final disciplineId = widget.disciplinaId;

    if (mounted) {
      _showGameOverDialog(context, currentScore, titulo);
    }

    unawaited(
      _progressoService.addArcadePoints(currentScore)
        .timeout(const Duration(seconds: 10))
        .catchError((e) => debugPrint('Erro background arcade points: $e'))
    );
    
    unawaited(
      _progressoService.updateArcadeRecord(disciplineId, currentScore)
        .timeout(const Duration(seconds: 10))
        .catchError((e) => debugPrint('Erro background recorde: $e'))
    );
  }

  void _showGameOverDialog(BuildContext context, int score, String titulo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.videogame_asset_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(titulo.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.error))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              Lottie.asset('assets/animations/GameOver.json', height: 120, repeat: false)
            else
              const Icon(Icons.gamepad, size: 60, color: AppColors.error),
            const SizedBox(height: 20),
            Text('PONTUAÇÃO FINAL:'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
            const SizedBox(height: 5),
            Text('$score', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 10),
            Text('A SINCRONIZAR COM A NUVEM...'.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) Navigator.of(context).pop();
              },
              child: Text('VOLTAR AO MENU'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _playSound(String file) {
    _audioService.playSfx(file);
  }

  Future<void> _playMusic() async {
    _audioService.playMusic('desafioArcade.mp3');
  }

  @override
  Widget build(BuildContext context) {
    final pergunta = _listaPerguntas[_perguntaAtualIndex];
    final Color timerColor = _tempoRestante <= 10 ? Colors.red : Colors.white;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return RetroCRTWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(fit: BoxFit.scaleDown, child: Text('ARCADE: ${widget.disciplinaNome}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
          backgroundColor: AppColors.tertiary,
          foregroundColor: Colors.white,
          actions: [
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(_pulseController),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text('${_tempoRestante}S',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: timerColor)
                  )
                )
              ),
            ),
          ],
        ),
        body: BackgroundContainer(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusChip('PONTOS: $_pontos', Icons.stars_rounded, AppColors.gold, size),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildComboProgress(_acertosParaTempo / 4, AppColors.primary, "Tempo", size),
                                if (_multiplicador > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text('X$_multiplicador', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 16)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStatusChip('VIDAS: $_oportunidades', Icons.favorite_rounded, AppColors.error, size),
                            const SizedBox(height: 4),
                            _buildComboProgress(_acertosParaVida / 5, AppColors.success, "Vida", size),
                          ],
                        ),
                      ],
                    ),

                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                color: Colors.white.withValues(alpha: 0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: size.height * 0.2),
                                    child: SingleChildScrollView(
                                      child: RetroTypewriterText(
                                        text: pergunta.pergunta,
                                        style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                    ),
                                  )
                                )
                              ),
                              const SizedBox(height: 20),
                                ..._opcoesAtuaisBaralhadas.map((opcao) {
                                  if (_opcoesRemovidas.contains(opcao)) return const SizedBox.shrink();

                                  bool isSelected = _opcaoSelecionada == opcao;
                                  bool isCorrect = opcao == pergunta.respostaCorreta;

                                  Color targetBgColor = isSelected
                                      ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                                      : Colors.white.withValues(alpha: 0.9);

                                  Color targetBorderColor = isSelected
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : Colors.blue.shade100;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Listener(
                                      onPointerDown: (details) {
                                        if (!_estaProcessando) {
                                          _verificarResposta(opcao, details.position);
                                        }
                                      },
                                      child: QuizOptionWrapper(
                                        isSelected: isSelected,
                                        isCorrect: isCorrect,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: targetBgColor,
                                              foregroundColor: isSelected ? (isCorrect ? AppColors.success : AppColors.error) : AppColors.primary,
                                              disabledBackgroundColor: targetBgColor,
                                              disabledForegroundColor: isSelected ? (isCorrect ? AppColors.success : AppColors.error) : AppColors.primary,
                                              padding: EdgeInsets.all(isTablet ? 20 : 14),
                                              elevation: isSelected ? 0 : 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25),
                                                side: BorderSide(color: targetBorderColor, width: 2),
                                              )
                                            ),
                                            onPressed: null,
                                            child: Text(opcao.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w600))
                                          )
                                        ),
                                      ),
                                    )
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SafeArea(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white24, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHelpIcon(Icons.add_alarm_rounded, '+30S', _tempoAdicionalUsado, () {
                              if (!_tempoAdicionalUsado && !_estaProcessando && !_isGameOver) {
                                setState(() { _tempoRestante += 30; _tempoAdicionalUsado = true; });
                                _showCentralFeedback("+30 SEGUNDOS!", Icons.add_alarm_rounded, AppColors.secondary);
                              }
                            }),
                            _buildHelpIcon(Icons.star_half_rounded, '50/50', _ajuda5050Usada, _use5050),
                            _buildHelpIcon(Icons.lightbulb_outline_rounded, 'DICA', _ajudaDicaUsada, _useHint),
                            _buildHelpIcon(Icons.skip_next_rounded, 'PULAR', _puloUsado, _useSkip),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              IgnorePointer(
                child: Center(
                  child: ScaleTransition(
                    scale: _feedbackAnimation,
                    child: FadeTransition(
                      opacity: _feedbackController,
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: _feedbackColor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_feedbackIcon, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              Text(_feedbackText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (_feedbackController.isAnimating)
                IgnorePointer(
                  child: Center(
                    child: Lottie.asset('assets/animations/festejo.json', height: 200, repeat: false),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color, Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: size.width * 0.035 > 13 ? 13 : size.width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboProgress(double progress, Color color, String label, Size size) {
    return Container(
      width: size.width * 0.2 > 80 ? 80 : size.width * 0.2,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(25),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpIcon(IconData icon, String label, bool isUsed, VoidCallback onTap) {
    return InkWell(onTap: isUsed ? null : onTap, child: Column(children: [Icon(icon, color: isUsed ? Colors.white24 : Colors.white, size: 24), Text(label.toUpperCase(), style: TextStyle(color: isUsed ? Colors.white24 : Colors.white, fontSize: 10, fontWeight: FontWeight.w600))]));
  }
}
