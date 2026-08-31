import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class SafetyScoreWidget extends StatelessWidget {
  final double score; // 0-10
  final bool compact;

  const SafetyScoreWidget({super.key, required this.score, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.scoreColor(score);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? AppSpacing.sm : AppSpacing.sm + 4, vertical: compact ? AppSpacing.xs + 1 : AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill,),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: compact ? 14 : 17, color: color),
          const SizedBox(width: 5),
          Text(
            '${score.toStringAsFixed(1)} / 10',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11.5 : 13,
            ),
          ),
        ],
      ),
    );
  }
}