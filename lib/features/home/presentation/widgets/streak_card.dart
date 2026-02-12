import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;

  const StreakCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Icon(icon, color: Colors.white, size: 24),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.streakNumber.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
