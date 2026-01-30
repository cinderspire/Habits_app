import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(weeklyReviewProvider);
    final habits = ref.watch(habitProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Review',
          style: AppTextStyles.headlineMedium
              .copyWith(color: AppColors.textPrimaryLight),
        ),
        centerTitle: true,
      ),
      body: habits.isEmpty
          ? _buildEmpty()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(review),
                  const SizedBox(height: 20),
                  _buildCompletionBreakdown(review),
                  const SizedBox(height: 20),
                  _buildBestWorstHabits(review),
                  const SizedBox(height: 20),
                  _buildHabitStrengths(habits),
                  const SizedBox(height: 20),
                  _buildSmartInsights(habits),
                  const SizedBox(height: 20),
                  _buildSuggestions(review),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 56, color: AppColors.textTertiaryLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No data for review',
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking habits to see your weekly review.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textTertiaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(WeeklyReview review) {
    final ratePercent = (review.completionRate * 100).toInt();
    final rateColor = ratePercent >= 70
        ? AppColors.secondaryGreen
        : ratePercent >= 40
            ? AppColors.warning
            : AppColors.error;
    final emoji = ratePercent >= 80
        ? 'Excellent!'
        : ratePercent >= 60
            ? 'Good progress!'
            : ratePercent >= 40
                ? 'Keep going!'
                : 'Room to grow';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryPurple.withOpacity(0.1),
            AppColors.secondaryBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.secondaryPurple.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('This Week',
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.textTertiaryLight)),
          const SizedBox(height: 8),
          Text(
            '$ratePercent%',
            style: AppTextStyles.displayLarge.copyWith(color: rateColor),
          ),
          Text(emoji,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Completed',
                  '${review.totalCompleted}/${review.totalPossible}',
                  AppColors.secondaryGreen),
              _buildMiniStat('Perfect Days', '${review.perfectDays}/7',
                  AppColors.streakGold),
              _buildMiniStat('Freezes Used', '${review.frozenDays}',
                  AppColors.streakIce),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Text(value,
              style: AppTextStyles.labelMedium
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textTertiaryLight)),
      ],
    );
  }

  Widget _buildCompletionBreakdown(WeeklyReview review) {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 Days',
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final date = now.subtract(Duration(days: 6 - i));
              final isToday = i == 6;
              // Simple visual indicator
              final rate = review.totalPossible > 0
                  ? (review.totalCompleted / 7 / (review.totalPossible / 7))
                      .clamp(0.0, 1.0)
                  : 0.0;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primaryOrange.withOpacity(0.15)
                          : AppColors.secondaryGreen
                              .withOpacity(0.05 + rate * 0.3),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: AppColors.primaryOrange, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isToday
                              ? AppColors.primaryOrange
                              : AppColors.textSecondaryLight,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNames[date.weekday - 1],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isToday
                          ? AppColors.primaryOrange
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBestWorstHabits(WeeklyReview review) {
    return Row(
      children: [
        if (review.bestHabit != null)
          Expanded(child: _buildHabitHighlight(
            title: 'Best Habit',
            habit: review.bestHabit!,
            count: review.streakChanges[review.bestHabit!.id] ?? 0,
            color: AppColors.secondaryGreen,
            icon: Icons.emoji_events_rounded,
          )),
        if (review.bestHabit != null && review.worstHabit != null)
          const SizedBox(width: 12),
        if (review.worstHabit != null)
          Expanded(child: _buildHabitHighlight(
            title: 'Needs Work',
            habit: review.worstHabit!,
            count: review.streakChanges[review.worstHabit!.id] ?? 0,
            color: AppColors.warning,
            icon: Icons.trending_down_rounded,
          )),
      ],
    );
  }

  Widget _buildHabitHighlight({
    required String title,
    required Habit habit,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.labelMedium.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(habit.color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(habit.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name,
                        style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textPrimaryLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('$count/7 days',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textTertiaryLight)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStrengths(List<Habit> habits) {
    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => b.strength.compareTo(a.strength));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.park_rounded,
                  color: AppColors.secondaryGreen, size: 22),
              const SizedBox(width: 8),
              Text('Habit Strength',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.textPrimaryLight)),
            ],
          ),
          const SizedBox(height: 16),
          ...sorted.map((habit) {
            final strength = habit.strength;
            final strengthColor = _getStrengthColor(strength);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Text(habit.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textPrimaryLight)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            child: LinearProgressIndicator(
                              value: strength / 100,
                              backgroundColor:
                                  AppColors.backgroundLightElevated,
                              color: strengthColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${strength.toInt()}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: strengthColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSmartInsights(List<Habit> habits) {
    final habitsWithTiming =
        habits.where((h) => h.smartReminderText != null).toList();
    if (habitsWithTiming.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: AppColors.secondaryPurple, size: 22),
              const SizedBox(width: 8),
              Text('Smart Reminders',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.textPrimaryLight)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your completion patterns',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiaryLight),
          ),
          const SizedBox(height: 16),
          ...habitsWithTiming.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(h.color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Text(h.icon, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.name,
                              style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.textPrimaryLight)),
                          Text(
                            h.smartReminderText!,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryPurple),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSuggestions(WeeklyReview review) {
    if (review.suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.06),
            AppColors.primaryYellow.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.primaryOrange, size: 22),
              const SizedBox(width: 8),
              Text('Suggestions',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.textPrimaryLight)),
            ],
          ),
          const SizedBox(height: 14),
          ...review.suggestions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Color _getStrengthColor(double strength) {
    if (strength >= 80) return const Color(0xFF10B981);
    if (strength >= 60) return const Color(0xFF34D399);
    if (strength >= 40) return const Color(0xFFFBBF24);
    if (strength >= 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
