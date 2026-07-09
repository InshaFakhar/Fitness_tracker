import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_shell.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form     = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final err = await context.read<FitnessProvider>().signUp(
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
          _nameCtrl.text.trim());

      if (!mounted) return;

      if (err != null) {
        setState(() { _loading = false; _error = err; });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; _error = 'Something went wrong.'; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Create Account')),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(key: _form, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Text('Join FitPro', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Start your fitness journey today',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),

          AppInput(controller: _nameCtrl, label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) => v?.isEmpty == true ? 'Name required' : null),
          const SizedBox(height: 14),
          AppInput(controller: _emailCtrl, label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty == true) return 'Email required';
                if (!v!.contains('@')) return 'Enter valid email';
                return null;
              }),
          const SizedBox(height: 14),
          AppInput(controller: _passCtrl, label: 'Password',
              icon: Icons.lock_outline, obscure: _obscure,
              suffix: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                      size: 20, color: const Color(0xFFAAAAAA)),
                  onPressed: () => setState(() => _obscure = !_obscure)),
              validator: (v) {
                if (v?.isEmpty == true) return 'Password required';
                if (v!.length < 6) return 'Minimum 6 characters';
                return null;
              }),
          const SizedBox(height: 14),
          AppInput(controller: _confCtrl, label: 'Confirm Password',
              icon: Icons.lock_outline, obscure: _obscure,
              validator: (v) =>
              v != _passCtrl.text ? 'Passwords do not match' : null),

          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: const TextStyle(color: AppColors.error,
                          fontSize: 13, fontFamily: 'Poppins'))),
                ])),
          ],

          const SizedBox(height: 28),
          GradientButton(
              text: 'Create Account', onTap: _submit, loading: _loading),
          const SizedBox(height: 20),
          Center(child: Text(
              'By signing up you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11))),
          const SizedBox(height: 24),
        ])),
      )),
    );
  }
}

// ── FORGOT PASSWORD ────────────────────────────────────────
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_ctrl.text.isEmpty) {
      setState(() => _error = 'Email required'); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final err = await context.read<FitnessProvider>()
          .forgotPassword(_ctrl.text.trim());
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (err != null) { _error = err; } else { _sent = true; }
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Something went wrong.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Reset Password')),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _SentView() : Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 28)),
          const SizedBox(height: 20),
          Text('Forgot Password?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Enter your registered email and we will send you a reset link.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: 32),
          AppInput(controller: _ctrl, label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(
                color: AppColors.error, fontSize: 13, fontFamily: 'Poppins')),
          ],
          const SizedBox(height: 28),
          GradientButton(text: 'Send Reset Link', onTap: _send, loading: _loading),
        ]),
      )),
    );
  }
}

class _SentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined,
              color: AppColors.success, size: 40)),
      const SizedBox(height: 20),
      Text('Email Sent!', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('Check your inbox for the reset link.\nIt may take a minute.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
      const SizedBox(height: 32),
      TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login',
              style: TextStyle(color: AppColors.primary,
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
    ]));
  }
}