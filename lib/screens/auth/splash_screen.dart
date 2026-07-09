import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import '../main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset>  _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _logoScale   = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textCtrl);
    _textSlide   = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs     = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    final user      = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (!onboarded) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else if (user != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainShell()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _textCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4E46E5), Color(0xFF1A1A2E)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: Column(children: [
          const Spacer(flex: 2),

          // Logo
          AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, __) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                          width: 110, height: 110,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3), width: 2)),
                          child: const Icon(Icons.fitness_center,
                              color: Colors.white, size: 56))))),

          const SizedBox(height: 32),

          // Text
          AnimatedBuilder(
              animation: _textCtrl,
              builder: (_, __) => FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                      position: _textSlide,
                      child: Column(children: [
                        const Text('FitPro', style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text('Your Fitness Journey Starts Here',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                                color: Colors.white.withOpacity(0.75), letterSpacing: 0.3)),
                      ])))),

          const Spacer(flex: 2),

          // Dots
          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == 1 ? 24 : 8, height: 8,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(i == 1 ? 0.9 : 0.35),
                          borderRadius: BorderRadius.circular(4)))))),

          const SizedBox(height: 52),
        ])),
      ),
    );
  }
}
