import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    // ⏱ Premium-feel animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scale = Tween<double>(begin: 0.9, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _bgOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _controller.forward();

    // ⏳ Total splash duration ≈ 4.5s
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 🌌 Background glow
              Opacity(
                opacity: _bgOpacity.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.4),
                      radius: 1.1,
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF020617),
                      ],
                    ),
                  ),
                ),
              ),

              // 🏷 Brand
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'BatchBuddy',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'by VarunTechServices',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔖 Version label (bottom)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'Version 1.3 • Early Access',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
