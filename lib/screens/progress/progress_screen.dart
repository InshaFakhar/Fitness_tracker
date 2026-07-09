import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_shell.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p      = context.watch<FitnessProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final week   = p.week;

    final totalCals  = week.fold(0, (s, e) => s + e.calories);
    final totalMins  = week.fold(0, (s, e) => s + e.duration);
    final totalSteps = week.fold(0, (s, e) => s + e.steps);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        bottom: TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFFAAAAAA),
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly')]),
      ),
      body: TabBarView(controller: _tab, children: [
        _ProgressBody(
            p: p, isDark: isDark,
            calories: totalCals, minutes: totalMins, steps: totalSteps,
            chartData: p.weekCals,
            labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            title: 'Weekly Calories'),
        _ProgressBody(
            p: p, isDark: isDark,
            calories: totalCals, minutes: totalMins, steps: totalSteps,
            chartData: p.weekCals,
            labels: const ['W1', 'W2', 'W3', 'W4'],
            title: 'Monthly Calories',
            monthly: true),
      ]),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final FitnessProvider p;
  final bool isDark;
  final int calories, minutes, steps;
  final List<double> chartData;
  final List<String> labels;
  final String title;
  final bool monthly;

  const _ProgressBody({
    required this.p, required this.isDark,
    required this.calories, required this.minutes, required this.steps,
    required this.chartData, required this.labels, required this.title,
    this.monthly = false});

  @override
  Widget build(BuildContext context) {
    final data = monthly
        ? List.generate(4, (i) {
      final start = i * 1;
      final end   = ((i + 1) * 2).clamp(0, chartData.length);
      if (start >= chartData.length) return 0.0;
      return chartData.sublist(start, end)
          .fold(0.0, (a, b) => a + b);
    })
        : chartData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Row(children: [
          _StatMini(label: 'Calories', value: '$calories',
              unit: 'kcal', color: AppColors.accent,
              icon: Icons.local_fire_department),
          const SizedBox(width: 10),
          _StatMini(label: 'Minutes', value: '$minutes',
              unit: 'min', color: AppColors.secondary,
              icon: Icons.timer_outlined),
          const SizedBox(width: 10),
          _StatMini(label: 'Steps', value: '$steps',
              unit: 'steps', color: AppColors.primary,
              icon: Icons.directions_walk),
        ]),
        const SizedBox(height: 16),
        _ChartCard(isDark: isDark, data: data, labels: labels, title: title),
        const SizedBox(height: 16),
        _LineChartCard(isDark: isDark, data: chartData),
        const SizedBox(height: 16),
        _TypeBreakdown(p: p, isDark: isDark),
        const SizedBox(height: 16),
        _BestStats(p: p, isDark: isDark),
        const SizedBox(height: 80),
      ]),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final IconData icon;
  const _StatMini({required this.label, required this.value,
    required this.unit, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
        Text(unit,  style: const TextStyle(fontSize: 9,
            color: Color(0xFF888888), fontFamily: 'Poppins')),
        Text(label, style: const TextStyle(fontSize: 10,
            color: Color(0xFF888888), fontFamily: 'Poppins')),
      ]),
    ));
  }
}

class _ChartCard extends StatelessWidget {
  final bool isDark;
  final List<double> data;
  final List<String> labels;
  final String title;
  const _ChartCard({required this.isDark, required this.data,
    required this.labels, required this.title});

  @override
  Widget build(BuildContext context) {
    final maxY = data.isEmpty ? 100.0
        : (data.reduce((a, b) => a > b ? a : b) * 1.4).clamp(100.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(height: 140, child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true,
              touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.darkSurface : Colors.white,
                  getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          fontWeight: FontWeight.w600, color: AppColors.primary)))),
          titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox();
                    return Text(labels[i],
                        style: const TextStyle(fontSize: 10,
                            fontFamily: 'Poppins', color: Color(0xFFAAAAAA)));
                  })),
              leftTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
          gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(
                toY: data[i],
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.bottomCenter, end: Alignment.topCenter),
                width: 20, borderRadius: BorderRadius.circular(6)),
          ])),
        ))),
      ]),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  final bool isDark;
  final List<double> data;
  const _LineChartCard({required this.isDark, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Calorie Trend', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(height: 120, child: LineChart(LineChartData(
          lineTouchData: LineTouchData(enabled: true,
              touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.darkSurface : Colors.white,
                  getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                      '${s.y.toInt()} kcal',
                      const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          fontWeight: FontWeight.w600, color: AppColors.accent))).toList())),
          gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  strokeWidth: 1)),
          titlesData: FlTitlesData(
              leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
          borderData: FlBorderData(show: false),
          lineBarsData: [LineChartBarData(
              spots: List.generate(data.length,
                      (i) => FlSpot(i.toDouble(), data[i])),
              isCurved: true, curveSmoothness: 0.3,
              color: AppColors.accent, barWidth: 2.5,
              dotData: FlDotData(show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                      radius: 3, color: AppColors.accent,
                      strokeColor: Colors.white, strokeWidth: 1.5)),
              belowBarData: BarAreaData(show: true,
                  gradient: LinearGradient(
                      colors: [AppColors.accent.withOpacity(0.2),
                        AppColors.accent.withOpacity(0)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter)))],
        ))),
      ]),
    );
  }
}

class _TypeBreakdown extends StatelessWidget {
  final FitnessProvider p;
  final bool isDark;
  const _TypeBreakdown({required this.p, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeCounts = <String, int>{};
    for (final w in p.all) {
      typeCounts[w.type] = (typeCounts[w.type] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Workout Breakdown', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        if (typeCounts.isEmpty)
          const Text('No workouts yet',
              style: TextStyle(color: Color(0xFFAAAAAA),
                  fontFamily: 'Poppins', fontSize: 13))
        else
          ...typeCounts.entries.map((e) {
            final total = p.all.length;
            final pct   = total > 0 ? e.value / total : 0.0;
            final c     = WorkoutChip.colorFor(e.key);
            return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Icon(WorkoutChip.iconFor(e.key), color: c, size: 14),
                      const SizedBox(width: 6),
                      Text(e.key, style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 12,
                          fontWeight: FontWeight.w500)),
                    ]),
                    Text('${e.value} sessions',
                        style: const TextStyle(fontSize: 11,
                            color: Color(0xFF888888), fontFamily: 'Poppins')),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: pct, minHeight: 6,
                          backgroundColor: c.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(c))),
                ]));
          }),
      ]),
    );
  }
}

class _BestStats extends StatelessWidget {
  final FitnessProvider p;
  final bool isDark;
  const _BestStats({required this.p, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (p.all.isEmpty) return const SizedBox();
    final bestCal = p.all.reduce((a, b) => a.calories > b.calories ? a : b);
    final bestDur = p.all.reduce((a, b) => a.duration > b.duration ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Personal Bests', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _PBCard(
              icon: Icons.local_fire_department,
              label: 'Best Calories',
              value: '${bestCal.calories} kcal',
              sub: bestCal.type,
              color: AppColors.accent)),
          const SizedBox(width: 10),
          Expanded(child: _PBCard(
              icon: Icons.timer,
              label: 'Longest Session',
              value: '${bestDur.duration} min',
              sub: bestDur.type,
              color: AppColors.primary)),
        ]),
      ]),
    );
  }
}

class _PBCard extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final Color color;
  const _PBCard({required this.icon, required this.label,
    required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
            fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 10,
            color: Color(0xFF888888), fontFamily: 'Poppins')),
        Text(sub,   style: TextStyle(fontSize: 10, color: color,
            fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
      ]),
    );
  }
}