import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page   = 0;

  final List<_PageData> _pages = const [
    _PageData(
      gradient: [Color(0xFF6C63FF), Color(0xFF4E46E5)],
      icon: Icons.track_changes_rounded,
      title: 'Track Every Move',
      subtitle: 'Log your workouts, steps, calories and daily activities — all in one place.',
    ),
    _PageData(
      gradient: [Color(0xFF00D4AA), Color(0xFF0099AA)],
      icon: Icons.bar_chart_rounded,
      title: 'Visualize Progress',
      subtitle: 'Beautiful charts and graphs clearly show your weekly and monthly improvements.',
    ),
    _PageData(
      gradient: [Color(0xFFFF6B9D), Color(0xFFCC3366)],
      icon: Icons.emoji_events_rounded,
      title: 'Reach Your Goals',
      subtitle: 'Set personalized goals and get daily insights to become your best self.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Pages
        PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _OnboardPage(data: _pages[i])),

        // Bottom controls
        Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Page indicator
                  SmoothPageIndicator(
                      controller: _ctrl,
                      count: _pages.length,
                      effect: const WormEffect(
                          dotHeight: 8, dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white38,
                          type: WormType.thin)),
                  const SizedBox(height: 32),
                  Row(children: [
                    // Skip button
                    if (_page < _pages.length - 1)
                      TextButton(
                          onPressed: _finish,
                          child: const Text('Skip',
                              style: TextStyle(color: Colors.white70,
                                  fontFamily: 'Poppins', fontSize: 14)))
                    else
                      const SizedBox(width: 70),
                    const Spacer(),
                    // Next / Done button
                    GestureDetector(
                        onTap: _next,
                        child: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)),
                            child: Icon(
                                _page < _pages.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_rounded,
                                color: Colors.white, size: 26))),
                  ]),
                ]),
              ),
            )),
      ]),
    );
  }
}

class _PageData {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  const _PageData({
    required this.gradient, required this.icon,
    required this.title, required this.subtitle});
}

class _OnboardPage extends StatelessWidget {
  final _PageData data;
  const _OnboardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: data.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Icon circle
                Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)),
                    child: Icon(data.icon, color: Colors.white, size: 80)),
                const SizedBox(height: 52),
                // Title
                Text(data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 28,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 16),
                // Subtitle
                Text(data.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 15,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.6)),
                const SizedBox(height: 120),
              ]),
        ),
      ),
    );
  }
}
