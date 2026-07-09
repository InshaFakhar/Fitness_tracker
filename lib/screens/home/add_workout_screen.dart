import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddWorkoutSheet extends StatefulWidget {
  final WorkoutModel? existing;
  const AddWorkoutSheet({super.key, this.existing});
  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _durationCtrl  = TextEditingController();
  final _stepsCtrl     = TextEditingController();
  final _distanceCtrl  = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _notesCtrl     = TextEditingController();

  String   _type           = 'Running';
  String   _difficulty     = 'Medium';
  DateTime _date           = DateTime.now();
  bool     _isSaving       = false;
  int      _estimatedCals  = 0;
  bool     _updatingFields = false;

  static const _types = [
    'Running', 'Walking', 'Cycling', 'Swimming',
    'HIIT', 'Gym', 'Strength Training', 'Yoga',
    'Stretching', 'Other',
  ];

  static const _typeIcons = {
    'Running':           Icons.directions_run,
    'Walking':           Icons.directions_walk,
    'Cycling':           Icons.directions_bike,
    'Swimming':          Icons.pool,
    'HIIT':              Icons.flash_on,
    'Gym':               Icons.fitness_center,
    'Strength Training': Icons.sports_gymnastics,
    'Yoga':              Icons.self_improvement,
    'Stretching':        Icons.accessibility_new,
    'Other':             Icons.sports,
  };

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameCtrl.text     = e.name;
      _durationCtrl.text = '${e.duration}';
      _stepsCtrl.text    = e.steps > 0 ? '${e.steps}' : '';
      _notesCtrl.text    = e.notes;
      if (e.distance != null) _distanceCtrl.text = e.distance!.toStringAsFixed(2);
      if (e.heartRate != null) _heartRateCtrl.text = '${e.heartRate}';
      _type          = e.type;
      _difficulty    = e.difficulty;
      _date          = e.date;
      _estimatedCals = e.calories;
    }
    _durationCtrl.addListener(_recalculate);
    _stepsCtrl.addListener(_onStepsChanged);
    _distanceCtrl.addListener(_onDistanceChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _durationCtrl.dispose();
    _stepsCtrl.dispose(); _distanceCtrl.dispose();
    _heartRateCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  double get _userWeight {
    try {
      return context.read<FitnessProvider>().profile?.weight ?? 65.0;
    } catch (_) { return 65.0; }
  }

  String get _userId {
    try {
      final p = context.read<FitnessProvider>();
      return p.uid.isNotEmpty ? p.uid : p.email;
    } catch (_) { return ''; }
  }

  void _recalculate() {
    final dur  = int.tryParse(_durationCtrl.text) ?? 0;
    final dist = double.tryParse(_distanceCtrl.text);
    setState(() {
      _estimatedCals = dur > 0
          ? WorkoutModel.estimateCalories(
          type: _type, durationMinutes: dur,
          weightKg: _userWeight, distanceKm: dist)
          : 0;
    });
  }

  void _onStepsChanged() {
    if (_updatingFields) return;
    final steps = int.tryParse(_stepsCtrl.text);
    if (steps != null && steps > 0) {
      _updatingFields = true;
      _distanceCtrl.text = WorkoutModel.stepsToDistance(steps, _type).toStringAsFixed(2);
      _updatingFields = false;
      _recalculate();
    }
  }

  void _onDistanceChanged() {
    if (_updatingFields) return;
    final dist = double.tryParse(_distanceCtrl.text);
    if (dist != null && dist > 0) {
      _updatingFields = true;
      _stepsCtrl.text = '${WorkoutModel.distanceToSteps(dist, _type)}';
      _updatingFields = false;
      _recalculate();
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
        context: context, initialDate: _date,
        firstDate: DateTime(2020), lastDate: DateTime.now(),
        builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: AppColors.primary)),
            child: child!));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    // Save navigator and messenger before async gap
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);

    try {
      final p     = context.read<FitnessProvider>();
      final dur   = int.tryParse(_durationCtrl.text) ?? 0;
      final dist  = double.tryParse(_distanceCtrl.text);
      final steps = int.tryParse(_stepsCtrl.text) ?? 0;
      final hr    = int.tryParse(_heartRateCtrl.text);
      final userId = p.uid.isNotEmpty ? p.uid : p.email;

      final cals = WorkoutModel.estimateCalories(
          type: _type, durationMinutes: dur,
          weightKg: _userWeight, distanceKm: dist);

      final entry = WorkoutModel(
        id:         widget.existing?.id ?? const Uuid().v4(),
        userId:     userId,
        name:       _nameCtrl.text.trim().isEmpty ? _type : _nameCtrl.text.trim(),
        type:       _type,
        duration:   dur,
        calories:   cals > 0 ? cals : 1,
        steps:      steps,
        distance:   dist,
        heartRate:  hr,
        difficulty: _difficulty,
        date:       _date,
        notes:      _notesCtrl.text.trim(),
      );

      if (widget.existing != null) {
        await p.updateWorkout(entry);
      } else {
        await p.addWorkout(entry);
      }

      // Use saved references — not context
      navigator.pop();

      messenger.showSnackBar(SnackBar(
          content: Text(widget.existing != null
              ? '✅ Workout updated!'
              : '💪 Workout saved! $cals kcal burned'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))));

    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2))),

        Flexible(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Form(key: _formKey, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(widget.existing != null ? 'Edit Workout' : 'Log Workout',
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 16),

            // Exercise Type
            _Label('Exercise Type'),
            const SizedBox(height: 8),
            SizedBox(height: 90, child: ListView.builder(
                scrollDirection: Axis.horizontal, itemCount: _types.length,
                itemBuilder: (_, i) {
                  final t   = _types[i];
                  final sel = _type == t;
                  final c   = WorkoutChip.colorFor(t);
                  return GestureDetector(
                      onTap: () {
                        setState(() => _type = t);
                        _recalculate();
                        if (_distanceCtrl.text.isNotEmpty) _onDistanceChanged();
                      },
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 76, margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: sel ? c : c.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: c.withOpacity(0.3))),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(_typeIcons[t] ?? Icons.sports,
                                color: sel ? Colors.white : c, size: 24),
                            const SizedBox(height: 6),
                            Text(t, textAlign: TextAlign.center, style: TextStyle(
                                fontSize: 8, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : c)),
                          ])));
                })),
            const SizedBox(height: 16),

            AppInput(controller: _nameCtrl,
                label: 'Workout Name (optional)',
                icon: Icons.drive_file_rename_outline),
            const SizedBox(height: 12),

            _Label('Duration *'),
            const SizedBox(height: 6),
            _NumberField(
                controller: _durationCtrl, label: 'Duration',
                hint: 'e.g. 30', unit: 'min', icon: Icons.timer_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Duration required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be > 0';
                  return null;
                }),
            const SizedBox(height: 12),

            // Calories auto
            Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2))),
                child: Row(children: [
                  const Icon(Icons.local_fire_department,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Estimated Calories (auto)', style: TextStyle(
                        fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
                    Text(
                        _estimatedCals > 0 ? '$_estimatedCals kcal' : 'Enter duration to calculate',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: _estimatedCals > 0 ? AppColors.accent : Colors.grey)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${_userWeight}kg', style: const TextStyle(
                        fontSize: 10, color: AppColors.primary,
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    Text(_type, style: TextStyle(fontSize: 9,
                        color: Colors.grey[500], fontFamily: 'Poppins')),
                  ]),
                ])),
            const SizedBox(height: 12),

            _Label('Steps & Distance (auto-linked 🔗)'),
            const SizedBox(height: 4),
            Text(
                _type == 'Cycling'
                    ? '💡 Enter km — pedal rotations auto-calculate'
                    : _type == 'Swimming'
                    ? '💡 Enter km — strokes auto-calculate'
                    : '💡 Enter steps OR distance — other auto-calculates',
                style: TextStyle(fontSize: 10,
                    color: Colors.grey[500], fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _NumberField(
                  controller: _stepsCtrl,
                  label: _type == 'Cycling' ? 'Pedal Rot.'
                      : _type == 'Swimming' ? 'Strokes' : 'Steps',
                  hint: 'e.g. 5000',
                  unit: _type == 'Cycling' ? 'rot'
                      : _type == 'Swimming' ? 'str' : 'steps',
                  icon: Icons.directions_walk_outlined,
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (int.tryParse(v) == null) return 'Invalid';
                    }
                    return null;
                  })),
              const SizedBox(width: 10),
              Expanded(child: _NumberField(
                  controller: _distanceCtrl, label: 'Distance',
                  hint: 'e.g. 3.5', unit: 'km',
                  icon: Icons.straighten, decimal: true,
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (double.tryParse(v) == null) return 'Invalid';
                    }
                    return null;
                  })),
            ]),
            const SizedBox(height: 12),

            _Label('Heart Rate (optional)'),
            const SizedBox(height: 6),
            _NumberField(
                controller: _heartRateCtrl, label: 'Heart Rate',
                hint: 'e.g. 140', unit: 'BPM', icon: Icons.favorite_outline,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final n = int.tryParse(v);
                    if (n == null || n < 40 || n > 220) return 'Must be 40–220 BPM';
                  }
                  return null;
                }),
            const SizedBox(height: 12),

            _Label('Date'),
            const SizedBox(height: 6),
            GestureDetector(
                onTap: _pickDate,
                child: Container(
                    height: 52, padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(DateFormat('EEE, dd MMM yyyy').format(_date),
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_outlined,
                          color: AppColors.primary, size: 16),
                    ]))),
            const SizedBox(height: 12),

            _Label('Difficulty'),
            const SizedBox(height: 6),
            Row(children: ['Easy', 'Medium', 'Hard'].map((d) {
              final c   = {'Easy': AppColors.success, 'Medium': AppColors.warning, 'Hard': AppColors.error}[d]!;
              final sel = _difficulty == d;
              return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: sel ? c : c.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.withOpacity(0.3))),
                      child: Text(d, textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600, fontSize: 12,
                              color: sel ? Colors.white : c)))));
            }).toList()),
            const SizedBox(height: 12),

            _Label('Notes (optional)'),
            const SizedBox(height: 6),
            AppInput(controller: _notesCtrl,
                label: 'How did it feel?',
                icon: Icons.notes_outlined, maxLines: 3),
            const SizedBox(height: 24),

            GradientButton(
                text: _isSaving
                    ? 'Saving...'
                    : widget.existing != null
                    ? 'Update Workout'
                    : 'Save Workout  •  ~$_estimatedCals kcal',
                onTap: _isSaving ? null : _save,
                loading: _isSaving),
            const SizedBox(height: 16),
          ])),
        )),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: Color(0xFF555555), fontFamily: 'Poppins'));
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint, unit;
  final IconData icon;
  final bool decimal;
  final String? Function(String?)? validator;

  const _NumberField({required this.controller, required this.label,
    required this.hint, required this.unit, required this.icon,
    this.decimal = false, this.validator});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
        controller: controller,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: [decimal
            ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            : FilteringTextInputFormatter.digitsOnly],
        validator: validator,
        decoration: InputDecoration(
            labelText: label, hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixText: unit,
            suffixStyle: const TextStyle(color: AppColors.primary,
                fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 12),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
  }
}
