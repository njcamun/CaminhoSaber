// lib/ui/screens/flash_card_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:caminho_do_saber/services/audio_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class FlashCardScreen extends StatefulWidget {
  final String titulo;
  final List<FlashCard> flashCards;

  const FlashCardScreen({
    super.key,
    required this.titulo,
    required this.flashCards,
  });

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  int _cardAtualIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.90), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playSound(String fileName) {
    context.read<AudioService>().playSfx(fileName);
  }

  void _virarCard() {
    if (_controller.isAnimating) return;
    
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _proximoCard() {
    if (_cardAtualIndex < widget.flashCards.length - 1) {
      setState(() {
        _cardAtualIndex++;
        _controller.reset();
      });
    }
  }

  void _cardAnterior() {
    if (_cardAtualIndex > 0) {
      setState(() {
        _cardAtualIndex--;
        _controller.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (widget.flashCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primary,
        ),
        body: BackgroundContainer(child: Center(child: Text('SEM CARTÕES.'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)))),
      );
    }

    final cardAtual = widget.flashCards[_cardAtualIndex];

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(fit: BoxFit.scaleDown, child: Text(widget.titulo.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_cardAtualIndex + 1) / widget.flashCards.length,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    borderRadius: BorderRadius.circular(25),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_cardAtualIndex + 1} DE ${widget.flashCards.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  double dragEndX = details.primaryVelocity ?? 0;
                  if (dragEndX < -500) {
                    _proximoCard();
                  } else if (dragEndX > 500) {
                    _cardAnterior();
                  }
                },
                onTap: _virarCard,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final isFront = _flipAnimation.value <= pi / 2;
                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(_flipAnimation.value);

                      return Transform(
                        transform: transform,
                        alignment: Alignment.center,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: isFront
                              ? _buildCollectorCard(cardAtual.pergunta, isFront: true, size: size)
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: _buildCollectorCard(cardAtual.resposta, isFront: false, size: size),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'DESLIZA PARA OS LADOS OU TOCA PARA VIRAR'.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 10),
              ),
            ),
            
            const SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 80 : 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScalePressWrapper(
                    onTap: _cardAtualIndex > 0 ? _cardAnterior : () {},
                    child: _buildNavButton(Icons.skip_previous_rounded, _cardAtualIndex > 0),
                  ),
                  const SizedBox(width: 40),
                  ScalePressWrapper(
                    onTap: _cardAtualIndex < widget.flashCards.length - 1 ? _proximoCard : () {},
                    child: _buildNavButton(Icons.skip_next_rounded, _cardAtualIndex < widget.flashCards.length - 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool enabled) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.white10,
        shape: BoxShape.circle,
        boxShadow: enabled ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 7, offset: const Offset(0, 4))] : [],
      ),
      child: Icon(icon, color: enabled ? AppColors.primary : Colors.white24, size: 32),
    );
  }

  Widget _buildCollectorCard(String texto, {required bool isFront, required Size size}) {
    final double cardWidth = size.width * 0.8 > 350 ? 350 : size.width * 0.8;
    final double cardHeight = size.height * 0.5 > 500 ? 500 : size.height * 0.5;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isFront ? AppColors.primary : AppColors.secondary,
          width: 8,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: GridPainter(color: isFront ? AppColors.primary : AppColors.secondary)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(isFront ? Icons.help_outline_rounded : Icons.auto_awesome_rounded,
                      color: isFront ? AppColors.primary : AppColors.secondary, size: 24),
                    Text(
                      isFront ? 'PERGUNTA' : 'RESPOSTA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: isFront ? AppColors.primary : AppColors.secondary
                      ),
                    ),
                    Icon(Icons.school_rounded, color: Colors.grey.shade300, size: 24),
                  ],
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: cardHeight * 0.6),
                  child: SingleChildScrollView(
                    child: Text(
                      texto,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: texto.length > 50 ? 20 : 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade900,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (!isFront)
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
                if (isFront)
                  Icon(Icons.visibility_off_rounded, color: AppColors.primary.withValues(alpha: 0.1), size: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
