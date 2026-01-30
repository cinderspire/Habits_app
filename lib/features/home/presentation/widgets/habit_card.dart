import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/habit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onFreeze;
  final bool showStrength;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onDelete,
    this.onTap,
    this.onFreeze,
    this.showStrength = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday;
    final isFrozen = habit.isFrozenToday;
    final color = Color(habit.color);
    final streak = habit.currentStreak;
    final strength = habit.strength;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFrozen
              ? AppColors.streakIce.withOpacity(0.08)
              : isCompleted
                  ? color.withOpacity(0.1)
                  : AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFrozen
                ? AppColors.streakIce
                : isCompleted
                    ? color
                    : AppColors.glassBorder,
            width: (isCompleted || isFrozen) ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? color.withOpacity(0.2)
                  : isFrozen
                      ? AppColors.streakIce.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onToggle();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFrozen
                          ? AppColors.streakIce
                          : isCompleted
                              ? color
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFrozen
                            ? AppColors.streakIce
                            : isCompleted
                                ? color
                                : AppColors.textTertiaryLight,
                        width: 2,
                      ),
                    ),
                    child: isFrozen
                        ? const Icon(Icons.ac_unit_rounded,
                            color: Colors.white, size: 16)
                        : isCompleted
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 18)
                            : null,
                  ),
                ),

                const SizedBox(width: 16),

                // Emoji Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.18), color.withOpacity(0.08)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    habit.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isCompleted ? color : AppColors.textPrimaryLight,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            habit.frequency == 'daily' ? 'Daily' : 'Weekly',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                          if (habit.smartReminderText != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: AppColors.secondaryPurple.withOpacity(0.6),
                            ),
                          ],
                          if (habit.stackGroupId != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.link_rounded,
                              size: 14,
                              color: AppColors.secondaryBlue.withOpacity(0.6),
                            ),
                          ],
                          if (isFrozen) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.streakIce.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Frozen',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.streakIce,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Freeze button (only show if not completed and not frozen)
                if (!isCompleted && !isFrozen && onFreeze != null)
                  GestureDetector(
                    onTap: onFreeze,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Tooltip(
                        message: habit.freezeUsedThisWeek
                            ? 'Freeze already used this week'
                            : 'Use streak freeze',
                        child: Icon(
                          Icons.ac_unit_rounded,
                          size: 20,
                          color: habit.freezeUsedThisWeek
                              ? AppColors.textTertiaryLight.withOpacity(0.3)
                              : AppColors.streakIce,
                        ),
                      ),
                    ),
                  ),

                // Streak
                if (streak > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: streak >= 7 ? AppColors.fireGradient : null,
                      color:
                          streak < 7 ? AppColors.backgroundLightElevated : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color:
                              streak >= 7 ? Colors.white : AppColors.streakFire,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: streak >= 7
                                ? Colors.white
                                : AppColors.streakFire,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Strength meter
            if (showStrength) ...[
              const SizedBox(height: 10),
              _HabitStrengthBar(strength: strength, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact strength bar showing habit strength 0-100%
class _HabitStrengthBar extends StatelessWidget {
  final double strength;
  final Color color;

  const _HabitStrengthBar({required this.strength, required this.color});

  @override
  Widget build(BuildContext context) {
    final strengthLabel = _getStrengthLabel(strength);
    final strengthIcon = _getStrengthIcon(strength);

    return Row(
      children: [
        Icon(strengthIcon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: strength / 100),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: AppColors.backgroundLightElevated,
                    color: _getStrengthColor(strength),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${strength.toInt()}% $strengthLabel',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiaryLight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static String _getStrengthLabel(double strength) {
    if (strength >= 80) return 'Strong';
    if (strength >= 60) return 'Growing';
    if (strength >= 40) return 'Building';
    if (strength >= 20) return 'Fragile';
    return 'New';
  }

  static IconData _getStrengthIcon(double strength) {
    if (strength >= 80) return Icons.park_rounded; // Full tree
    if (strength >= 60) return Icons.nature_rounded; // Growing tree
    if (strength >= 40) return Icons.grass_rounded; // Grass
    if (strength >= 20) return Icons.eco_rounded; // Seedling
    return Icons.spa_rounded; // Seed
  }

  static Color _getStrengthColor(double strength) {
    if (strength >= 80) return const Color(0xFF10B981);
    if (strength >= 60) return const Color(0xFF34D399);
    if (strength >= 40) return const Color(0xFFFBBF24);
    if (strength >= 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
