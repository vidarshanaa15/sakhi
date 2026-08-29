import 'package:flutter/material.dart';

/// Shared color coding for safety scores (0-10) used across map screens.
Color safetyColorFor(double? score) {
  if (score == null) return const Color(0xFF9E9E9E);
  if (score >= 8.0) return const Color(0xFF2E7D5B); // safe green
  if (score >= 6.5) return const Color(0xFFC98A2C); // caution amber
  return const Color(0xFFC1473F); // risk red
}

/// A small color-coded pill showing a safety score. Used anywhere a route
/// or destination's safety rating needs to be shown compactly and
/// consistently across the app.
class SafetyPill extends StatelessWidget {
  final double? score;
  final String? label;

  const SafetyPill({
    super.key,
    this.score,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = safetyColorFor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label ??
                (score != null
                    ? '${score!.toStringAsFixed(1)}/10'
                    : '--'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}