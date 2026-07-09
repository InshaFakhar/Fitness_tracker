import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp     = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _Section(title: 'APPEARANCE', children: [
            _ToggleTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                label: 'Dark Mode',
                subtitle: isDark ? 'Currently dark' : 'Currently light',
                value: tp.isDark,
                onChanged: (_) => tp.toggle()),
          ]),

          const SizedBox(height: 16),

          _Section(title: 'NOTIFICATIONS', children: [
            _SwitchTile(
                icon: Icons.notifications_outlined,
                label: 'Workout Reminders',
                subtitle: 'Daily reminder to log workout'),
            _SwitchTile(
                icon: Icons.water_drop_outlined,
                label: 'Water Reminders',
                subtitle: 'Remind me to drink water'),
          ]),

          const SizedBox(height: 16),

          _Section(title: 'DATA & SYNC', children: [
            _TapTile(
                icon: Icons.cloud_sync_outlined,
                label: 'Sync to Firebase',
                subtitle: 'Manually sync your data',
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing...'),
                          behavior: SnackBarBehavior.floating));
                }),
          ]),

          const SizedBox(height: 16),

          _Section(title: 'INFORMATION', children: [
            _TapTile(
                icon: Icons.info_outline,
                label: 'About FitPro',
                subtitle: 'Version 2.0.0',
                onTap: () => _showAbout(context)),
            _TapTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _showDialog(context, 'Privacy Policy',
                    'We respect your privacy. All workout data is stored securely in Firebase and on your device. We do not share your personal data with third parties.')),
            _TapTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => _showDialog(context, 'Terms of Service',
                    'By using FitPro, you agree to use the app responsibly. The calorie estimates are approximations and should not replace medical advice.')),
            _TapTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () => _showDialog(context, 'Help & Support',
                    'For support, contact us at support@fitpro.app\n\nTips:\n• Log workouts daily for best results\n• Update your weight in Profile for accurate calorie estimates\n• Tap water glasses to track hydration')),
            _TapTile(
                icon: Icons.star_outline,
                label: 'Rate FitPro',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your support! ⭐'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success))),
          ]),

          const SizedBox(height: 32),

          Center(child: Column(children: [
            Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.fitness_center,
                    color: Colors.white, size: 26)),
            const SizedBox(height: 10),
            const Text('FitPro', style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                fontSize: 18, color: AppColors.primary)),
            const Text('v2.0.0 • Made with Flutter ❤️',
                style: TextStyle(fontFamily: 'Poppins',
                    fontSize: 12, color: Color(0xFFAAAAAA))),
          ])),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 60, height: 60,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 30)),
          const SizedBox(height: 16),
          const Text('FitPro', style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w700,
              fontSize: 22, color: AppColors.primary)),
          const SizedBox(height: 6),
          const Text('Version 2.0.0', style: TextStyle(
              fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 12),
          const Text(
              'A professional fitness tracking app built with Flutter & Firebase.\n\nTrack workouts, monitor progress, and achieve your fitness goals!',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.5)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.primary))),
        ]));
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(context: context, builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: Text(content, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.primary))),
        ]));
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary, letterSpacing: 1))),
      Container(
          decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(children: List.generate(children.length, (i) =>
              Column(children: [
                children[i],
                if (i < children.length - 1)
                  Divider(height: 1, indent: 52,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
              ])))),
    ]);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label,
    this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: Color(0xFFAAAAAA))) : null,
      trailing: Switch(value: value, onChanged: onChanged,
          activeColor: AppColors.primary));
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  const _SwitchTile({required this.icon, required this.label, this.subtitle});

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  bool _val = false;
  @override
  Widget build(BuildContext context) => ListTile(
      leading: Icon(widget.icon, color: AppColors.primary, size: 22),
      title: Text(widget.label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: Color(0xFFAAAAAA))) : null,
      trailing: Switch(value: _val, onChanged: (v) => setState(() => _val = v),
          activeColor: AppColors.primary));
}

class _TapTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  const _TapTile({required this.icon, required this.label,
    this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: Color(0xFFAAAAAA))) : null,
      trailing: const Icon(Icons.chevron_right,
          color: Color(0xFFAAAAAA), size: 20),
      onTap: onTap);
}
