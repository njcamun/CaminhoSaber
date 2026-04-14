import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AchievementOverlay extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isDiamond;

  const AchievementOverlay({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.isDiamond = false,
  });

  static void show(BuildContext context, {required String title, required String message, required IconData icon, required Color color, bool isDiamond = false}) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AchievementWidget(
        title: title,
        message: message,
        icon: icon,
        color: color,
        isDiamond: isDiamond,
        onDismiss: () {
          if (overlayEntry?.mounted ?? false) {
            overlayEntry?.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _AchievementWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isDiamond;
  final VoidCallback onDismiss;

  const _AchievementWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.isDiamond,
    required this.onDismiss,
  });

  @override
  State<_AchievementWidget> createState() => _AchievementWidgetState();
}

class _AchievementWidgetState extends State<_AchievementWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        }).catchError((_) {
          // Ignora erro de TickerCanceled
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                border: Border.all(color: widget.color.withOpacity(0.3), width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        widget.isDiamond ? 'assets/animations/diamante_brilho.json' : 'assets/animations/estrela_brilho.json',
                        width: 150,
                        height: 150,
                        repeat: true,
                        errorBuilder: (context, error, stackTrace) => Icon(widget.icon, size: 80, color: widget.color),
                      ),
                      Icon(widget.icon, size: 60, color: widget.color),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: widget.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    style: const TextStyle(fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
