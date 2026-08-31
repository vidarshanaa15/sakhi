import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

Color safetyColorFor(double? score) {
  if (score == null) return const Color(0xFF9E9E9E);
  if (score >= 8.0) return AppTheme.safetyGreen;
  if (score >= 6.5) return AppTheme.safetyAmber;
  return AppTheme.safetyRed;
}

class SafetyPill extends StatelessWidget {
  final double? score;
  final String? label;
  final bool solid; // true = filled badge (like the "7.5/10" card badge), false = soft chip

  const SafetyPill({super.key, this.score, this.label, this.solid = false});

  @override
  Widget build(BuildContext context) {
    final color = safetyColorFor(score);
    final text = label ?? (score != null ? '${score!.toStringAsFixed(1)}/10' : '--');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 13, color: solid ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: solid ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}