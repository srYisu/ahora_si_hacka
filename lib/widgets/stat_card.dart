import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? subtitle;
  final bool highlighted;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.subtitle,
    this.highlighted = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        highlighted ? AppColors.primaryDark : AppColors.bgCard;
    final textColor =
        highlighted ? AppColors.textWhite : AppColors.textPrimary;
    final secondaryColor =
        highlighted ? AppColors.textWhite.withValues(alpha: 0.7) : AppColors.textSecondary;
    final effectiveIconColor =
        iconColor ?? (highlighted ? AppColors.primaryGreen : AppColors.primaryTeal);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: AppColors.primaryTeal, width: 2)
            : Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: highlighted ? 0.3 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: effectiveIconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: secondaryColor,
              letterSpacing: 1.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: secondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.progress = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgMint,
              color: AppColors.primaryTeal,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
