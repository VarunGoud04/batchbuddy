import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signup_page.dart';
import '../core/animated_route.dart';
import '../core/vts_footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= USER FRIENDLY ERROR HANDLING =================
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Login failed. Please check your details and try again.';
    }
  }

  // ================= LOGIN =================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapFirebaseAuthError(e));
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Enter your email to reset your password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset link sent. Check your email inbox.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapFirebaseAuthError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back')),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ===== HEADER =====
                Text(
                  'Sign in to BatchBuddy',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Access your groups, expenses, and settlements.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                // ===== EMAIL =====
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== PASSWORD =====
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),

                // ===== ERROR MESSAGE =====
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ===== LOGIN BUTTON =====
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text('Continue'),
                        ),
                      ),

                const SizedBox(height: 18),

                // ===== SIGNUP LINK =====
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeSlideRoute(page: const SignupPage()),
                      );
                    },
                    child: const Text(
                      'New here? Create an account',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ===== VERSION LABEL =====
                Center(
                  child: Text(
                    'Version 1.3 • Early Access',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const VTSFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
