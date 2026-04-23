import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

enum AppButtonStatus { idle, success, error }

class AppButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final AppButtonStatus status;
  final Color? color;
  final double borderRadius;

  const AppButton({
    required this.child,
    required this.onTap,
    this.status = AppButtonStatus.idle,
    this.color,
    this.borderRadius = 25.0,
    super.key,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _shakeOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (widget.status == AppButtonStatus.error) _triggerErrorEffect();
      if (widget.status == AppButtonStatus.success) _triggerSuccessEffect();
    }
  }

  void _triggerErrorEffect() {
    HapticFeedback.vibrate();
    // Sequência de Shake manual para alta performance
    Future.forEach([10.0, -10.0, 7.0, -7.0, 4.0, 0.0], (double offset) async {
      await Future.delayed(const Duration(milliseconds: 40));
      if (mounted) setState(() => _shakeOffset = offset);
    });
  }

  void _triggerSuccessEffect() {
    HapticFeedback.mediumImpact();
    _controller.forward().then((_) {
      if (mounted) _controller.reverse();
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_shakeOffset, 0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onTap != null) {
              _controller.forward();
              HapticFeedback.lightImpact();
            }
          },
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                if (widget.status == AppButtonStatus.idle)
                  BoxShadow(
                    color: (widget.color ?? AppColors.primary).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
