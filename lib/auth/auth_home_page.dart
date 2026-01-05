import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/animated_route.dart';
import '../core/vts_footer.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({super.key});

  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _redirecting = false;

  @override
  void initState() {
    super.initState();

    // 🎬 Animation setup (always initialize)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);

    // 🔐 Session check
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _redirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
      return;
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⛔ Prevent UI flash during redirect
    if (_redirecting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                children: [
                  const Spacer(),

                  // ===== BRAND ICON =====
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 48,
                      color: Color(0xFF0F766E),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== BRAND NAME =====
                  const Text(
                    'BatchBuddy',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'by VarunTechServices',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== TAGLINE =====
                  const Text(
                    'Split, track, and settle shared expenses\nwithout friction.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ===== PRIMARY CTA =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadeSlideRoute(page: const LoginPage()),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===== SECONDARY CTA =====
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadeSlideRoute(page: const SignupPage()),
                        );
                      },
                      child: const Text('Create an account'),
                    ),
                  ),

                  const Spacer(),

                  // ===== VERSION LABEL =====
                  FadeTransition(
                    opacity: _fade,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Version 1.3 • Early Access',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                  // ===== FOOTER =====
                  const VTSFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
