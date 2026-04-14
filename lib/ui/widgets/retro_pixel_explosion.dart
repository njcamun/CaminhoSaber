import 'dart:math';
import 'package:flutter/material.dart';

class PixelExplosion extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onComplete;

  const PixelExplosion({
    required this.position,
    required this.color,
    required this.onComplete,
    super.key,
  });

  @override
  State<PixelExplosion> createState() => _PixelExplosionState();
}

class _PixelExplosionState extends State<PixelExplosion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<PixelParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Criar 15-20 "blocos" de pixels
    for (int i = 0; i < 20; i++) {
      _particles.add(PixelParticle(
        angle: _random.nextDouble() * pi * 2,
        speed: _random.nextDouble() * 4 + 2,
        size: _random.nextDouble() * 6 + 4,
      ));
    }

    _controller.forward().then((_) {
      if (mounted) widget.onComplete();
    }).catchError((_) {
      // Ignorar TickerCanceled
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _particles.map((p) {
            final double progress = _controller.value;
            final double distance = p.speed * progress * 100;
            
            return Positioned(
              left: widget.position.dx + cos(p.angle) * distance,
              top: widget.position.dy + sin(p.angle) * distance,
              child: Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class PixelParticle {
  final double angle;
  final double speed;
  final double size;

  PixelParticle({required this.angle, required this.speed, required this.size});
}

void showPixelExplosion(BuildContext context, Offset position, Color color) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => PixelExplosion(
      position: position,
      color: color,
      onComplete: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}
