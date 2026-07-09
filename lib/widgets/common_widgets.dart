import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── GRADIENT BUTTON ───────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  final double height;

  const GradientButton({super.key, required this.text, this.onTap, this.loading = false, this.height = 52});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: Ink(
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(14)),
          child: Center(child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(text, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white))),
        ),
      ),
    );
  }
}

// ── STAT CARD ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const StatCard({super.key, required this.icon, required this.label, required this.value, this.unit = '', required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 12),
        RichText(text: TextSpan(
            text: value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A2E), fontFamily: 'Poppins'),
            children: [TextSpan(text: ' $unit', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black38, fontFamily: 'Poppins'))])),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
      ]),
    );
  }
}

// ── CIRCULAR PROGRESS ─────────────────────────────────────
class CircularGoal extends StatelessWidget {
  final double progress;
  final String label;
  final String center;
  final Color color;
  final double size;

  const CircularGoal({super.key, required this.progress, required this.label, required this.center, required this.color, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(width: size, height: size,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: progress, strokeWidth: 7,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(color)),
            Text(center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
          ])),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
    ]);
  }
}

// ── WORKOUT TYPE CHIP ─────────────────────────────────────
class WorkoutChip extends StatelessWidget {
  final String type;
  final bool selected;
  final VoidCallback onTap;

  const WorkoutChip({super.key, required this.type, required this.selected, required this.onTap});

  static Color colorFor(String t) {
    switch (t) {
      case 'Running':  return AppColors.running;
      case 'Cycling':  return AppColors.cycling;
      case 'Swimming': return AppColors.swimming;
      case 'Gym':      return AppColors.gym;
      case 'Yoga':     return AppColors.yoga;
      case 'HIIT':     return AppColors.hiit;
      default:         return AppColors.primary;
    }
  }

  static IconData iconFor(String t) {
    switch (t) {
      case 'Running':  return Icons.directions_run;
      case 'Cycling':  return Icons.directions_bike;
      case 'Swimming': return Icons.pool;
      case 'Gym':      return Icons.fitness_center;
      case 'Yoga':     return Icons.self_improvement;
      case 'HIIT':     return Icons.flash_on;
      case 'Walking':  return Icons.directions_walk;
      default:         return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = colorFor(type);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: selected ? c : c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(iconFor(type), size: 14, color: selected ? Colors.white : c),
          const SizedBox(width: 5),
          Text(type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : c, fontFamily: 'Poppins')),
        ]),
      ),
    );
  }
}

// ── INPUT FIELD ───────────────────────────────────────────
class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final int maxLines;

  const AppInput({super.key, required this.controller, required this.label, this.icon,
    this.obscure = false, this.keyboardType = TextInputType.text,
    this.validator, this.suffix, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, obscureText: obscure,
      keyboardType: keyboardType, maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
          suffixIcon: suffix),
    );
  }
}

// ── SECTION HEADER ────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      if (action != null)
        TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontFamily: 'Poppins'))),
    ]);
  }
}

// ── EMPTY STATE ───────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 48, color: AppColors.primary.withOpacity(0.5))),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Text(subtitle, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38, fontFamily: 'Poppins')),
    ]));
  }
}

// ── WORKOUT TILE ──────────────────────────────────────────
class WorkoutTile extends StatelessWidget {
  final dynamic entry;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const WorkoutTile({super.key, required this.entry, this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = WorkoutChip.colorFor(entry.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(WorkoutChip.iconFor(entry.type), color: color, size: 22)),
        title: Text(entry.name.isNotEmpty ? entry.name : entry.type,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
        subtitle: Text('${entry.duration} min  •  ${entry.calories} kcal  •  ${entry.steps} steps',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (entry.synced) const Icon(Icons.cloud_done, size: 14, color: AppColors.secondary)
          else const Icon(Icons.cloud_off, size: 14, color: Color(0xFFAAAAAA)),
          if (onEdit != null) IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit, color: const Color(0xFFAAAAAA)),
          if (onDelete != null) IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: onDelete, color: const Color(0xFFAAAAAA)),
        ]),
      ),
    );
  }
}