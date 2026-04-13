// lib/ui/screens/splash_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  
  final double _randomRotation = (Random().nextBool() ? 1 : -1) * (0.1 + Random().nextDouble() * 0.2);

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500), // Ligeiramente mais longo para suavidade
    );

    // Fade Animation: In (0-30%), Stay (30-70%), Out (70-100%)
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(_controller);

    // Scale Animation: Zoom In (0-30%), Stay (30-70%), Zoom Out (70-100%)
    // Aumentado o tamanho máximo para 3.5 para impacto visual maior
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.5).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
      TweenSequenceItem(tween: ConstantTween(3.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 3.5, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)), weight: 30),
    ]).animate(_controller);

    // Rotation Animation: Slight Tilt (0-30%), Stay (30-70%), Fast Spin Out (70-100%)
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: _randomRotation).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: ConstantTween(_randomRotation), weight: 40),
      TweenSequenceItem(tween: Tween(begin: _randomRotation, end: _randomRotation + (6 * pi)).chain(CurveTween(curve: Curves.easeInOutBack)), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => _navigateToNext());
  }

  void _navigateToNext() {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            user != null ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Efeito de Fade In para a tela seguinte
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1500), // Fade In mais suave
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation, // Fade out da tela splash
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            'assets/images/logo.png',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
