import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'progress/progress_screen.dart';
import 'home/add_workout_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';
import 'settings/settings_screen.dart';
import 'auth/login_screen.dart';

// Global key — sab screens drawer open kar sakti hain
final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _onTab(int i) {
    if (i == 2) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddWorkoutSheet());
      return;
    }
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: mainScaffoldKey,
      drawer: const _AppDrawer(),
      body: IndexedStack(
        index: _tab > 2 ? _tab - 1 : _tab,
        children: const [
          HomeScreen(),
          ProgressScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  selected: _tab == 0,
                  onTap: () => _onTab(0)),
              _NavItem(
                  icon: Icons.show_chart_outlined,
                  activeIcon: Icons.show_chart,
                  label: 'Progress',
                  selected: _tab == 1,
                  onTap: () => _onTab(1)),
              // Center add button
              Expanded(child: GestureDetector(
                  onTap: () => _onTab(2),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 52, height: 52,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark]),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 28)),
                  ]))),
              _NavItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'History',
                  selected: _tab == 3,
                  onTap: () => _onTab(3)),
              _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  selected: _tab == 4,
                  onTap: () => _onTab(4)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(selected ? activeIcon : icon,
            color: selected ? AppColors.primary : const Color(0xFFAAAAAA),
            size: 24),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary : const Color(0xFFAAAAAA))),
      ]),
    ));
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final p      = context.watch<FitnessProvider>();
    final tp     = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      child: SafeArea(child: Column(children: [

        // Header
        Container(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                      p.displayName.isNotEmpty
                          ? p.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Poppins'))),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.displayName.isNotEmpty ? p.displayName : 'Athlete',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis),
                    Text(p.email,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ])),
            ])),

        const Divider(),

        _DrawerItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SettingsScreen()));
            }),
        _DrawerItem(
            icon: Icons.info_outline,
            label: 'About FitPro',
            onTap: () => Navigator.pop(context)),
        _DrawerItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => Navigator.pop(context)),
        _DrawerItem(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () => Navigator.pop(context)),

        // Dark mode toggle
        ListTile(
            leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                color: const Color(0xFF888888)),
            title: const Text('Dark Mode',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            trailing: Switch(
                value: tp.isDark,
                onChanged: (_) => tp.toggle(),
                activeColor: AppColors.primary)),

        const Spacer(),
        const Divider(),

        // Logout
        ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout',
                style: TextStyle(fontFamily: 'Poppins',
                    fontSize: 14, color: AppColors.error)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<FitnessProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            }),
        const SizedBox(height: 12),
      ])),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF888888), size: 22),
      title: Text(label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}