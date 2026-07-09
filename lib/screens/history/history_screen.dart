import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fitness_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../home/add_workout_screen.dart';
import '../main_shell.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';
  final _filters = [
    'All', 'Running', 'Walking', 'Cycling',
    'Swimming', 'HIIT', 'Gym', 'Yoga', 'Other'
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p    = context.watch<FitnessProvider>();
    final list = p.search;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
      ),
      body: Column(children: [

        // Search bar
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) {
                p.setSearch(q);
                setState(() {});
              },
              decoration: InputDecoration(
                  hintText: 'Search workouts...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.primary, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18, color: Color(0xFFAAAAAA)),
                      onPressed: () {
                        _searchCtrl.clear();
                        p.setSearch('');
                        setState(() {});
                      })
                      : null,
                  hintStyle: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13,
                      color: Color(0xFFAAAAAA))),
            )),

        // Filter chips
        SizedBox(
            height: 44,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (_, i) => WorkoutChip(
                    type: _filters[i],
                    selected: _selectedFilter == _filters[i],
                    onTap: () {
                      setState(() => _selectedFilter = _filters[i]);
                      p.setFilter(_filters[i]);
                    }))),

        const SizedBox(height: 8),

        // Count
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Text('${list.length} workout${list.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12,
                      color: Color(0xFFAAAAAA), fontFamily: 'Poppins')),
            ])),
        const SizedBox(height: 8),

        // List
        Expanded(child: list.isEmpty
            ? const EmptyState(
            icon: Icons.fitness_center,
            title: 'No workouts found',
            subtitle: 'Try a different search\nor add your first workout!')
            : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final e = list[i];
              return Dismissible(
                  key: Key(e.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                            title: const Text('Delete Workout',
                                style: TextStyle(fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600)),
                            content: const Text('Are you sure?',
                                style: TextStyle(fontFamily: 'Poppins')),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: AppColors.error))),
                            ]));
                  },
                  onDismissed: (_) => p.deleteWorkout(e.id),
                  background: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white)),
                  child: WorkoutTile(
                      entry: e,
                      onDelete: () => p.deleteWorkout(e.id),
                      onEdit: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddWorkoutSheet(existing: e))));
            })),
      ]),
    );
  }
}