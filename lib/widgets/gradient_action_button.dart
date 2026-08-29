import 'package:flutter/material.dart';

/// The app's shared big, bold call-to-action button: a primary-color
/// gradient with an icon, title, optional subtitle, and a forward arrow.
/// Used for the main next-step action on map and itinerary screens.
class GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool loading;

  const GradientActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = onTap == null || loading;

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: disabled ? 0 : 6,
      shadowColor: colorScheme.primary.withValues(alpha: 0.4),
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: disabled
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.82),
                    ],
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loading ? 'Working...' : label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null && !loading) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!loading)
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}