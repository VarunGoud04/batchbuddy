import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/vts_footer.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= PASSWORD STRENGTH =================
  int _passwordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    return strength;
  }

  Color _strengthColor(int strength) {
    if (strength <= 1) return Colors.red;
    if (strength == 2) return Colors.orange;
    if (strength == 3) return Colors.amber;
    return Colors.green;
  }

  String _strengthLabel(int strength) {
    if (strength <= 1) return 'Weak';
    if (strength == 2) return 'Fair';
    if (strength == 3) return 'Good';
    return 'Strong';
  }

  // ================= SIGNUP =================
  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    if (_passwordStrength(password) < 3) {
      setState(() =>
          _error = 'Please choose a stronger password.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'groupId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          _error = 'Please enter a valid email address.';
          break;
        default:
          _error = 'Signup failed. Please try again.';
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength(_passwordController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join BatchBuddy',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create an account to start managing shared expenses.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),

                const SizedBox(height: 6),
                const Text(
                  'This name cannot be changed later.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: strength / 4,
                        color: _strengthColor(strength),
                        backgroundColor: Colors.grey.shade300,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _strengthLabel(strength),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _strengthColor(strength),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 28),

                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signup,
                          child: const Text('Create Account'),
                        ),
                      ),

                const SizedBox(height: 40),
                const VTSFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
