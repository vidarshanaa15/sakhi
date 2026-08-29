import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SafetyScoreWidget extends StatelessWidget {
  final double score; // 0-10
  final bool compact;

  const SafetyScoreWidget({super.key, required this.score, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.scoreColor(score);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: compact ? 14 : 18, color: color),
          const SizedBox(width: 4),
          Text(
            '${score.toStringAsFixed(1)} / 10',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}