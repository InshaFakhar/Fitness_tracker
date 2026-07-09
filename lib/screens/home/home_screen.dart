import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../history/history_screen.dart';
import '../main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final p       = context.watch<FitnessProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final profile = p.profile;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 110,
          pinned: true,
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          leading: IconButton(
              icon: Icon(Icons.menu,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
              onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
          flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${_greeting()}, ${profile?.name.split(' ').first ?? 'Athlete'} 👋',
                        style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    Text(
                        DateFormat('EEEE, dd MMMM').format(DateTime.now()),
                        style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black38)),
                  ])),
          actions: [
            if (p.sync != null)
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text(p.sync!,
                      style: const TextStyle(fontSize: 10,
                          color: AppColors.secondary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)))),
            const SizedBox(width: 8),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Stat Cards
            Row(children: [
              Expanded(child: StatCard(
                  icon: Icons.directions_walk, label: 'Steps',
                  value: '${p.todaySteps}', color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                  icon: Icons.local_fire_department, label: 'Calories',
                  value: '${p.todayCals}', unit: 'kcal', color: AppColors.accent)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                  icon: Icons.timer_outlined, label: 'Minutes',
                  value: '${p.todayMins}', color: AppColors.secondary)),
            ]),

            const SizedBox(height: 16),
            _GoalCard(p: p),
            const SizedBox(height: 16),

            if (profile != null) ...[
              _BMICard(profile: profile),
              const SizedBox(height: 16),
            ],

            _WaterCard(p: p),
            const SizedBox(height: 16),
            _WeeklyChart(p: p),
            const SizedBox(height: 16),

            SectionHeader(
                title: 'Recent Activities',
                action: 'See All',
                onAction: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()))),
            const SizedBox(height: 10),

            if (p.today.isEmpty)
              const EmptyState(
                  icon: Icons.fitness_center,
                  title: 'No workouts today',
                  subtitle: 'Tap + to log your first workout')
            else
              ...p.today.take(3).map((e) => WorkoutTile(
                  entry: e, onDelete: () => p.deleteWorkout(e.id))),

            const SizedBox(height: 100),
          ])),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final FitnessProvider p;
  const _GoalCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Daily Goals', style: TextStyle(
            fontFamily: 'Poppins', fontSize: 15,
            fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          CircularGoal(progress: p.calProgress, label: 'Calories',
              center: '${(p.calProgress * 100).toInt()}%',
              color: Colors.white, size: 72),
          CircularGoal(progress: p.stepProgress, label: 'Steps',
              center: '${(p.stepProgress * 100).toInt()}%',
              color: const Color(0xFF00D4AA), size: 72),
          CircularGoal(progress: p.waterProgress, label: 'Water',
              center: '${(p.waterProgress * 100).toInt()}%',
              color: const Color(0xFFFFCC44), size: 72),
        ]),
        if (p.calProgress >= 1.0) ...[
          const SizedBox(height: 12),
          const Center(child: Text('🎉 All goals achieved today!',
              style: TextStyle(color: Colors.white,
                  fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w500))),
        ],
      ]),
    );
  }
}

class _BMICard extends StatelessWidget {
  final dynamic profile;
  const _BMICard({required this.profile});

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25)   return AppColors.success;
    if (bmi < 30)   return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bmi    = profile.bmi;
    final color  = _bmiColor(bmi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.monitor_weight_outlined, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('BMI', style: TextStyle(fontSize: 11,
              color: Color(0xFF888888), fontFamily: 'Poppins')),
          Row(children: [
            Text(bmi.toStringAsFixed(1), style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: color, fontFamily: 'Poppins')),
            const SizedBox(width: 8),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(profile.bmiCategory, style: TextStyle(
                    fontSize: 11, color: color,
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${profile.weight} kg', style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          Text('${profile.height} cm', style: const TextStyle(
              fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
        ]),
      ]),
    );
  }
}

class _WaterCard extends StatelessWidget {
  final FitnessProvider p;
  const _WaterCard({required this.p});

  @override
  Widget build(BuildContext context) {
    const goal = 8;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💧 Water Intake',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${p.water} / $goal glasses',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00B4D8),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(goal, (i) {
              final filled = i < p.water;
              return Expanded(
                child: GestureDetector(
                  onTap: () => p.setWater(i + 1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    height: 32,
                    decoration: BoxDecoration(
                      color: filled
                          ? const Color(0xFF00B4D8)
                          : const Color(0xFF00B4D8).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      size: 14,
                      color: filled
                          ? Colors.white
                          : const Color(0xFF00B4D8).withOpacity(0.4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final FitnessProvider p;
  const _WeeklyChart({required this.p});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days   = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today  = DateTime.now().weekday - 1;
    final maxY   = p.weekCals.isEmpty ? 100.0
        : (p.weekCals.reduce((a, b) => a > b ? a : b) * 1.4)
        .clamp(100.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Weekly Activity',
              style: Theme.of(context).textTheme.titleMedium),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${p.weekCalsTotal} kcal', style: const TextStyle(
                  fontSize: 11, color: AppColors.primary,
                  fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
        ]),
        const SizedBox(height: 18),
        SizedBox(height: 130, child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true,
              touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                  isDark ? AppColors.darkSurface : Colors.white,
                  getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                      '${rod.toY.toInt()} kcal',
                      const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          fontWeight: FontWeight.w600, color: AppColors.primary)))),
          titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= days.length) return const SizedBox();
                    return Text(days[i], style: TextStyle(
                        fontSize: 11, fontFamily: 'Poppins',
                        color: i == today
                            ? AppColors.primary : const Color(0xFFAAAAAA)));
                  })),
              leftTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
          gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(
                toY: p.weekCals[i],
                color: i == today
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
                width: 18, borderRadius: BorderRadius.circular(6)),
          ])),
        ))),
      ]),
    );
  }
}