import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/workout_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../main_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl     = TextEditingController();
  final _heightCtrl   = TextEditingController();
  final _weightCtrl   = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _calGoalCtrl  = TextEditingController();
  final _stepGoalCtrl = TextEditingController();
  String _gender  = 'Female';
  bool _editing   = false;
  bool _saving    = false;
  bool _loaded    = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _load(); _loaded = true; }
  }

  void _load() {
    final profile = context.read<FitnessProvider>().profile;
    if (profile != null) {
      _nameCtrl.text     = profile.name;
      _heightCtrl.text   = profile.height.toString();
      _weightCtrl.text   = profile.weight.toString();
      _ageCtrl.text      = profile.age.toString();
      _calGoalCtrl.text  = profile.dailyCalorieGoal.toString();
      _stepGoalCtrl.text = profile.dailyStepGoal.toString();
      _gender = profile.gender;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _heightCtrl.dispose(); _weightCtrl.dispose();
    _ageCtrl.dispose(); _calGoalCtrl.dispose(); _stepGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final p = context.read<FitnessProvider>();
    final existing = p.profile;
    if (existing != null) {
      await p.saveProfile(existing.copyWith(
        name:             _nameCtrl.text.trim(),
        height:           double.tryParse(_heightCtrl.text) ?? existing.height,
        weight:           double.tryParse(_weightCtrl.text) ?? existing.weight,
        age:              int.tryParse(_ageCtrl.text) ?? existing.age,
        gender:           _gender,
        dailyCalorieGoal: int.tryParse(_calGoalCtrl.text) ?? existing.dailyCalorieGoal,
        dailyStepGoal:    int.tryParse(_stepGoalCtrl.text) ?? existing.dailyStepGoal,
      ));
    }
    messenger.showSnackBar(const SnackBar(
        content: Text('✅ Profile saved!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating));
    if (mounted) setState(() { _saving = false; _editing = false; });
  }

  @override
  Widget build(BuildContext context) {
    final p       = context.watch<FitnessProvider>();
    final tp      = context.watch<ThemeProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final profile = p.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        actions: [
          if (_editing)
            TextButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                    : const Text('Save', style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15)))
          else
            IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () => setState(() { _editing = true; _load(); })),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          _AvatarCard(p: p, isDark: isDark),
          const SizedBox(height: 16),

          if (!p.isLoggedIn) ...[
            _LoginPrompt(),
          ] else ...[

            // Personal Info
            _SectionCard(title: 'Personal Info', isDark: isDark, children: [
              if (_editing)
                AppInput(controller: _nameCtrl, label: 'Full Name',
                    icon: Icons.person_outline)
              else
                _InfoRow(icon: Icons.person_outline, label: 'Name',
                    value: profile?.name ?? '-'),

              const SizedBox(height: 12),

              // Age + Gender row
              if (_editing) ...[
                Row(children: [
                  Expanded(child: AppInput(
                      controller: _ageCtrl, label: 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: DropdownButtonFormField<String>(
                      value: _gender,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_outlined,
                              color: AppColors.primary, size: 20)),
                      items: ['Male', 'Female', 'Other'].map((g) =>
                          DropdownMenuItem(value: g,
                              child: Text(g, style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() => _gender = v!))),
                ]),
              ] else ...[
                Row(children: [
                  Expanded(child: _InfoRow(icon: Icons.cake_outlined,
                      label: 'Age', value: '${profile?.age ?? '-'} yrs')),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoRow(icon: Icons.wc_outlined,
                      label: 'Gender', value: profile?.gender ?? '-')),
                ]),
              ],

              const SizedBox(height: 12),

              // Height + Weight row
              if (_editing) ...[
                Row(children: [
                  Expanded(child: AppInput(
                      controller: _heightCtrl, label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 10),
                  Expanded(child: AppInput(
                      controller: _weightCtrl, label: 'Weight (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ]),
              ] else ...[
                Row(children: [
                  Expanded(child: _InfoRow(icon: Icons.height,
                      label: 'Height', value: '${profile?.height ?? '-'} cm')),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoRow(icon: Icons.monitor_weight_outlined,
                      label: 'Weight', value: '${profile?.weight ?? '-'} kg')),
                ]),
              ],
            ]),

            const SizedBox(height: 14),

            // BMI
            if (profile != null) _BMISummary(profile: profile, isDark: isDark),
            const SizedBox(height: 14),

            // Daily Goals
            _SectionCard(title: 'Daily Goals', isDark: isDark, children: [
              if (_editing) ...[
                Row(children: [
                  Expanded(child: AppInput(
                      controller: _calGoalCtrl, label: 'Calorie Goal',
                      icon: Icons.local_fire_department_outlined,
                      keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: AppInput(
                      controller: _stepGoalCtrl, label: 'Step Goal',
                      icon: Icons.directions_walk_outlined,
                      keyboardType: TextInputType.number)),
                ]),
              ] else ...[
                Row(children: [
                  Expanded(child: _InfoRow(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Calories',
                      value: '${profile?.dailyCalorieGoal ?? 500} kcal')),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoRow(
                      icon: Icons.directions_walk_outlined,
                      label: 'Steps',
                      value: '${profile?.dailyStepGoal ?? 8000}')),
                ]),
              ],
            ]),

            const SizedBox(height: 14),

            // Account
            _SectionCard(title: 'Account', isDark: isDark, children: [
              _InfoRow(icon: Icons.email_outlined, label: 'Email',
                  value: p.email),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.cloud_done_outlined,
                    color: AppColors.secondary, size: 18),
                const SizedBox(width: 8),
                const Text('Firebase Connected', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500)),
              ]),
            ]),

            const SizedBox(height: 14),

            // Appearance
            _SectionCard(title: 'Appearance', isDark: isDark, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Icon(isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(isDark ? 'Dark Mode' : 'Light Mode',
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ]),
                Switch(value: tp.isDark, onChanged: (_) => tp.toggle(),
                    activeColor: AppColors.primary),
              ]),
            ]),

            const SizedBox(height: 20),

            // Logout
            SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await p.signOut();
                      navigator.pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                    label: const Text('Logout', style: TextStyle(
                        color: AppColors.error, fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600, fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))))),
          ],

          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final FitnessProvider p;
  final bool isDark;
  const _AvatarCard({required this.p, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final name = p.profile?.name ?? p.displayName;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins'))),
        const SizedBox(width: 16),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name.isNotEmpty ? name : 'Athlete',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 18,
                  fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 3),
          Text(p.email,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: Colors.white.withOpacity(0.8)),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${p.all.length} total workouts',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: Colors.white, fontWeight: FontWeight.w500))),
        ])),
      ]),
    );
  }
}

class _BMISummary extends StatelessWidget {
  final UserProfile profile;
  final bool isDark;
  const _BMISummary({required this.profile, required this.isDark});

  Color _color(double bmi) {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25)   return AppColors.success;
    if (bmi < 30)   return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final bmi = profile.bmi;
    final c   = _color(bmi);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(
                color: c.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(bmi.toStringAsFixed(1),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.w700, color: c)))),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Body Mass Index', style: TextStyle(
              fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(profile.bmiCategory, style: TextStyle(
                  fontSize: 12, color: c,
                  fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
        ])),
        Text('${profile.weight}kg / ${profile.height}cm',
            style: const TextStyle(fontSize: 11,
                color: Color(0xFF888888), fontFamily: 'Poppins')),
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;
  const _SectionCard({
    required this.title, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          ...children,
        ]));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            fontSize: 10, color: Color(0xFF888888), fontFamily: 'Poppins')),
        Text(value, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
      ])),
    ]);
  }
}

class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2))),
        child: Column(children: [
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          const Text('Sign in to view your profile',
              style: TextStyle(fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Sync your data across devices with Firebase',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins',
                  fontSize: 12, color: Color(0xFF888888))),
          const SizedBox(height: 16),
          GradientButton(text: 'Sign In', height: 44,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()))),
        ]));
  }
}
