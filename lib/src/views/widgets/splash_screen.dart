// IGNORE_FOR_FILE: DEPRECATED_MEMBER_USE
import 'dart:async';
import 'package:flutter/material.dart';
import '../snake_game_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // NAVIGATE TO GAME SCREEN AFTER DELAY
    Timer(const Duration(milliseconds: 2800), _navigateToGame);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToGame() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SnakeGameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const monoStyle = TextStyle(
      fontFamily: 'Courier',
      fontFamilyFallback: ['monospace'],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1912),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GLOWING LOGO IMAGE WRAPPER
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF86E0C4).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'NEON SNAKE',
                      style: monoStyle.copyWith(
                        color: const Color(0xFFFF8A6B),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: const [
                          Shadow(color: Color(0x99FF785A), blurRadius: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'RETRO ARCADE',
                      style: monoStyle.copyWith(
                        color: const Color(0xFF8FC99A),
                        fontSize: 12,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // SMALL LOADING BAR
                    SizedBox(
                      width: 120,
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: const Color(0xFF173324),
                        color: const Color(0xFF86E0C4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
