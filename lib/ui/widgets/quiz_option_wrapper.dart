import 'package:flutter/material.dart';

class QuizOptionWrapper extends StatefulWidget {
  final Widget child;
  final bool isCorrect;
  final bool isSelected;

  const QuizOptionWrapper({
    required this.child,
    required this.isCorrect,
    required this.isSelected,
    super.key,
  });

  @override
  State<QuizOptionWrapper> createState() => _QuizOptionWrapperState();
}

class _QuizOptionWrapperState extends State<QuizOptionWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(QuizOptionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      if (widget.isCorrect) {
        _controller.forward(from: 0.0);
      } else {
        _shake();
      }
    }
  }

  void _shake() {
    // Sequência de pequenos movimentos laterais
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offset = 0.0;
        double scale = 1.0;

        if (widget.isSelected) {
          if (widget.isCorrect) {
            scale = 1.0 + (_controller.value * 0.05);
          } else {
            // Shake effect usando o valor da animação
            offset = (0.5 - (Curves.decelerate.transform(_controller.value))).abs() * 15;
          }
        }

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
