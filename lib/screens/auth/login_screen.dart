import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_shell.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form      = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure       = true;
  bool _loading       = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final err = await context.read<FitnessProvider>()
          .signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());

      if (!mounted) return;

      if (err != null) {
        setState(() { _loading = false; _error = err; });
      } else {
        // Success — go to main app
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; _error = 'Something went wrong. Try again.'; });
      }
    }
  }

  Future<void> _google() async {
    setState(() { _googleLoading = true; _error = null; });

    try {
      final err = await context.read<FitnessProvider>().signInGoogle();
      if (!mounted) return;

      if (err == null) {
        // Success
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MainShell()));
      } else if (err == 'Cancelled') {
        // User cancelled — no error
        setState(() => _googleLoading = false);
      } else {
        // Real error
        setState(() { _googleLoading = false; _error = err; });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _googleLoading = false;
          _error = 'Google sign-in failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _form,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Logo
                  Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark]),
                          borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.fitness_center,
                          color: Colors.white, size: 30)),

                  const SizedBox(height: 24),

                  Text('Welcome back!',
                      style: Theme.of(context).textTheme.displayLarge
                          ?.copyWith(fontSize: 28)),

                  const SizedBox(height: 6),

                  Text('Sign in to continue your journey',
                      style: Theme.of(context).textTheme.bodyMedium),

                  const SizedBox(height: 36),

                  // Google Sign In
                  _GoogleBtn(loading: _googleLoading, onTap: _google),

                  const SizedBox(height: 20),

                  // Divider
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with email',
                            style: Theme.of(context).textTheme.bodyMedium)),
                    const Expanded(child: Divider()),
                  ]),

                  const SizedBox(height: 20),

                  // Email field
                  AppInput(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email required';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      }),

                  const SizedBox(height: 14),

                  // Password field
                  AppInput(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                      suffix: IconButton(
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20, color: const Color(0xFFAAAAAA)),
                          onPressed: () => setState(() => _obscure = !_obscure))),

                  // Forgot password
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen())),
                          child: const Text('Forgot password?',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontFamily: 'Poppins')))),

                  // Error message
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontFamily: 'Poppins'))),
                        ])),
                  ],

                  const SizedBox(height: 24),

                  // Sign In button
                  GradientButton(
                      text: 'Sign In',
                      onTap: _login,
                      loading: _loading),

                  const SizedBox(height: 24),

                  // Sign up link
                  Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const SignUpScreen())),
                            child: const Text('Sign Up',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    fontSize: 13))),
                      ])),

                  const SizedBox(height: 32),
                ]),
          ),
        ),
      ),
    );
  }
}

class _GoogleBtn extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _GoogleBtn({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52, width: double.infinity,
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))]),
        child: loading
            ? const Center(child: SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary)))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Google G icon
          Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.g_mobiledata,
                  color: Color(0xFF4285F4), size: 28)),
          const SizedBox(width: 10),
          Text('Continue with Google',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        ]),
      ),
    );
  }
}