// lib/ui/screens/arcade_quiz_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/ui/widgets/quiz_option_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_crt_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_typewriter_text.dart';
import 'package:caminho_do_saber/ui/widgets/retro_pixel_explosion.dart';
import 'package:caminho_do_saber/ui/widgets/xp_flyer.dart';

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
  int _sessionId = 0;

  bool _tempoAdicionalUsado = false;
  bool _ajuda5050Usada = false;
  bool _ajudaDicaUsada = false;
  bool _puloUsado = false;
  
  List<String> _opcoesRemovidas = [];
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioHabilitado = true;

  // Feedback Animado Central
  String _feedbackText = "";
  IconData _feedbackIcon = Icons.star;
  Color _feedbackColor = Colors.amber;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _rotationAnimation;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _sessionId++;
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
    _audioPlayer.dispose();
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
    final currentSession = _sessionId;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameOver || currentSession != _sessionId || !mounted) {
        timer.cancel();
        return;
      }

      if (_tempoRestante > 0) {
        setState(() {
          _tempoRestante--;
          if (_tempoRestante <= 10 && _tempoRestante > 0) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
          }
        });
      }
      
      if (_tempoRestante <= 0) {
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
        showXPFlyer(context, tapPosition);
        showPixelExplosion(context, tapPosition, Colors.green);
      }
      setState(() {
        _pontos += 5 * _multiplicador; 
        _comboConsecutivo++;
        _acertosParaTempo++;
        _acertosParaVida++;
        
        if (_acertosParaTempo >= 4) {
          _tempoRestante += 15;
          _acertosParaTempo = 0;
          _showCentralFeedback("+15 SEGUNDOS!", Icons.timer_outlined, Colors.blueAccent);
        }

        if (_acertosParaVida >= 5) {
          if (_oportunidades < 5) {
            _oportunidades++;
            _showCentralFeedback("+1 VIDA!", Icons.favorite_rounded, Colors.greenAccent.shade700);
          }
          _acertosParaVida = 0;
        }

        if (_comboConsecutivo == 10) {
          _pontos += 25;
          _showCentralFeedback("COMBO X2 ATIVO!", Icons.bolt_rounded, Colors.orange);
        } else if (_comboConsecutivo == 20) {
          _pontos += 100;
          _showCentralFeedback("MEDALHA! X3 ATIVO!", Icons.workspace_premium_rounded, Colors.amber);
          context.read<ProgressoService>().registerSpecialAchievement('medalha');
        } else if (_comboConsecutivo == 30) {
          _pontos += 250;
          _showCentralFeedback("DIAMANTE!", Icons.diamond_rounded, Colors.cyan);
          context.read<ProgressoService>().registerSpecialAchievement('diamante');
        }

        if (_comboConsecutivo % 15 == 0) {
          _tempoAdicionalUsado = false;
          _ajuda5050Usada = false;
          _ajudaDicaUsada = false;
          _puloUsado = false;
          _showCentralFeedback("AJUDAS RESTAURADAS!", Icons.auto_fix_high_rounded, Colors.tealAccent.shade700);
        }
      });
      _playSound('acerto.mp3');
    } else {
      HapticFeedback.heavyImpact();
      if (tapPosition != Offset.zero) {
        showPixelExplosion(context, tapPosition, Colors.red);
      }
      setState(() {
        _oportunidades--;
        _comboConsecutivo = 0;
        _acertosParaTempo = 0;
        _acertosParaVida = 0;
      });
      _playSound('erro.mp3');
      
      if (_oportunidades <= 0) {
        _finishGame("SEM OPORTUNIDADES!");
        return;
      }
    }

    final currentSession = _sessionId;
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!_isGameOver && mounted && currentSession == _sessionId) {
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
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 30),
            SizedBox(width: 10),
            Text('Dica Mágica', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(pergunta.dica ?? 'Presta atenção às opções, a resposta está lá!', style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido!', style: TextStyle(fontWeight: FontWeight.bold)))
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
      _sessionId++; // Invalida qualquer callback pendente
    });
    
    _timer?.cancel();
    _pulseController.stop();
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    
    final progressoService = Provider.of<ProgressoService>(context, listen: false);
    
    try {
      await progressoService.addArcadePoints(_pontos).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Erro não crítico salvar arcade: $e');
    }
    
    bool isNewRecord = false;
    try {
      isNewRecord = await progressoService.updateArcadeRecord(widget.disciplinaId, _pontos).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Erro não crítico update recorde arcade: $e');
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              Lottie.asset(
                isNewRecord ? 'assets/animations/sucesso.json' : 'assets/animations/GameOver.json', 
                width: 180, 
                repeat: isNewRecord,
                errorBuilder: (context, error, stackTrace) => Icon(isNewRecord ? Icons.emoji_events : Icons.gamepad, size: 80, color: Colors.grey),
              )
            else
              Icon(isNewRecord ? Icons.emoji_events : Icons.gamepad, size: 80, color: isNewRecord ? Colors.green : Colors.red),
            const SizedBox(height: 10),
            Text(isNewRecord ? "NOVO RECORDE!" : titulo, 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isNewRecord ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            Text('Pontuação Final: $_pontos', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Text('Refletido nas tuas conquistas!', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
              child: const Text('Voltar ao Menu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _playSound(String file) async {
    if (_audioHabilitado) {
      try {
        final player = AudioPlayer();
        await player.play(AssetSource('sounds/$file'));
        player.onPlayerComplete.listen((_) {
          player.dispose();
        });
      } catch (e) {
        // Ignorar falhas de áudio na Web para não travar
      }
    }
  }

  Future<void> _playMusic() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('audioHabilitado') ?? true) {
      final double volumeGeral = prefs.getDouble('volumeGeral') ?? 1.0;
      await _audioPlayer.setVolume(volumeGeral * 0.6); 
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/desafioArcade.mp3'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pergunta = _listaPerguntas[_perguntaAtualIndex];
    final Color timerColor = _tempoRestante <= 10 ? Colors.red : Colors.white;

    return RetroCRTWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Arcade: ${widget.disciplinaNome}', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          actions: [
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(_pulseController),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0), 
                  child: Text('$_tempoRestante s', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: timerColor)
                  )
                )
              ),
            ),
          ],
        ),
        body: BackgroundContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusChip('Pontos: $_pontos', Icons.stars_rounded, Colors.orange.shade800),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildComboProgress(_acertosParaTempo / 4, Colors.blue, "Tempo"),
                            if (_multiplicador > 1) 
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text('x$_multiplicador', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 16)),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusChip('Vidas: $_oportunidades', Icons.favorite_rounded, Colors.red.shade700),
                        const SizedBox(height: 4),
                        _buildComboProgress(_acertosParaVida / 5, Colors.green, "Vida"),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  color: Colors.white.withValues(alpha: 0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0), 
                    child: RetroTypewriterText(
                      text: pergunta.pergunta,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
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
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                              foregroundColor: isSelected ? (isCorrect ? Colors.green : Colors.red) : Colors.blue.shade900, 
                              disabledBackgroundColor: targetBgColor,
                              disabledForegroundColor: isSelected ? (isCorrect ? Colors.green : Colors.red) : Colors.blue.shade900,
                              padding: const EdgeInsets.all(18), 
                              elevation: isSelected ? 0 : 4, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: targetBorderColor, width: 2),
                              )
                            ),
                            onPressed: null, // Controlado pelo Listener
                            child: Text(opcao, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))
                          )
                        ),
                      ),
                    )
                  );
                }),
                
                const Spacer(),
      
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_feedbackController.isAnimating && !kIsWeb)
                          IgnorePointer(
                            child: Lottie.asset(
                              'assets/animations/festejo.json', 
                              height: 100, 
                              repeat: false,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ),
                        ScaleTransition(
                          scale: _feedbackAnimation,
                          child: FadeTransition(
                            opacity: _feedbackController,
                            child: RotationTransition(
                              turns: _rotationAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _feedbackColor,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_feedbackIcon, color: Colors.white, size: 28),
                                    const SizedBox(width: 12),
                                    Text(_feedbackText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      
                const SizedBox(height: 10),
      
                SafeArea(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withValues(alpha: 0.9), 
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHelpIcon(Icons.add_alarm_rounded, '+30s', _tempoAdicionalUsado, () {
                          if (!_tempoAdicionalUsado && !_estaProcessando && !_isGameOver) {
                            setState(() { _tempoRestante += 30; _tempoAdicionalUsado = true; });
                            _showCentralFeedback("+30 SEGUNDOS!", Icons.add_alarm_rounded, Colors.cyan);
                          }
                        }),
                        _buildHelpIcon(Icons.star_half_rounded, '50/50', _ajuda5050Usada, _use5050),
                        _buildHelpIcon(Icons.lightbulb_outline_rounded, 'Dica', _ajudaDicaUsada, _useHint),
                        _buildHelpIcon(Icons.skip_next_rounded, 'Pular', _puloUsado, _useSkip),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
      child: Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]));
  }

  Widget _buildComboProgress(double progress, Color color, String label) {
    return Container(
      width: 100,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpIcon(IconData icon, String label, bool isUsed, VoidCallback onTap) {
    return InkWell(onTap: isUsed ? null : onTap, child: Column(children: [Icon(icon, color: isUsed ? Colors.white24 : Colors.white, size: 32), Text(label, style: TextStyle(color: isUsed ? Colors.white24 : Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]));
  }
}
