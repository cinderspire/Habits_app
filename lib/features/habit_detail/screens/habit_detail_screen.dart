import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final habit = habits.where((h) => h.id == widget.habitId).firstOrNull;

    if (habit == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text('Habit not found',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryLight)),
        ),
      );
    }

    final color = Color(habit.color);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(habit, color),
            SliverToBoxAdapter(child: _buildStatsRow(habit, color)),
            SliverToBoxAdapter(child: _build30DayHeatmap(habit, color)),
            SliverToBoxAdapter(child: _buildStrengthSection(habit, color)),
            SliverToBoxAdapter(child: _buildSmartReminderSection(habit, color)),
            SliverToBoxAdapter(child: _buildCalendarHeatmap(habit, color)),
            SliverToBoxAdapter(child: _buildStreakInfo(habit, color)),
            SliverToBoxAdapter(child: _buildCompletionHistory(habit, color)),
            SliverToBoxAdapter(child: _buildActions(habit, color)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Habit habit, Color color) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () => _showEditDialog(habit),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () => _confirmDelete(habit),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(habit.icon, style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 12),
                Text(
                  habit.name,
                  style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${habit.frequencyDisplayText} Habit',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    if (habit.stackGroupId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text('Chained', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Habit habit, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatTile('Current\nStreak', '${habit.currentStreak}', Icons.local_fire_department_rounded, color),
          const SizedBox(width: 12),
          _buildStatTile('Longest\nStreak', '${habit.longestStreak}', Icons.emoji_events_rounded, AppColors.streakGold),
          const SizedBox(width: 12),
          _buildStatTile('Completion\nRate', '${(habit.completionRate * 100).toInt()}%', Icons.trending_up_rounded, AppColors.secondaryGreen),
          const SizedBox(width: 12),
          _buildStatTile('Total\nDays', '${habit.completedDates.toSet().length}', Icons.calendar_today_rounded, AppColors.secondaryBlue),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiaryLight)),
          ],
        ),
      ),
    );
  }

  // ---------- 30-DAY HEATMAP ----------
  Widget _build30DayHeatmap(Habit habit, Color color) {
    final now = DateTime.now();
    final completedSet = habit.completedDates.toSet();
    final frozenSet = habit.freezeDates.toSet();

    // Generate last 30 days
    final days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

    int completedCount = 0;
    for (final day in days) {
      final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      if (completedSet.contains(dateStr)) completedCount++;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Last 30 Days',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.textPrimaryLight)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount/30',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 30-day grid: 6 columns x 5 rows
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                final day = days[index];
                final dateStr =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                final isCompleted = completedSet.contains(dateStr);
                final isFrozen = frozenSet.contains(dateStr);
                final isToday = dateStr == Habit.todayFormatted();

                Color cellColor;
                if (isCompleted) {
                  cellColor = color.withValues(alpha: 0.85);
                } else if (isFrozen) {
                  cellColor = AppColors.streakIce.withValues(alpha: 0.5);
                } else {
                  cellColor = AppColors.backgroundLightElevated;
                }

                return Tooltip(
                  message: '${day.month}/${day.day}${isCompleted ? ' - Done' : isFrozen ? ' - Frozen' : ''}',
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(4),
                      border: isToday
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Center(
                            child: Icon(Icons.check_rounded,
                                color: Colors.white, size: 10))
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _build30DayLegend(AppColors.backgroundLightElevated, 'Missed'),
                const SizedBox(width: 12),
                _build30DayLegend(color.withValues(alpha: 0.85), 'Done'),
                const SizedBox(width: 12),
                _build30DayLegend(AppColors.streakIce.withValues(alpha: 0.5), 'Frozen'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _build30DayLegend(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textTertiaryLight, fontSize: 10)),
      ],
    );
  }

  // ---------- HABIT STRENGTH SECTION ----------
  Widget _buildStrengthSection(Habit habit, Color color) {
    final strength = habit.strength;
    final strengthLabel = _getStrengthLabel(strength);
    final strengthColor = _getStrengthColor(strength);
    final strengthIcon = _getStrengthIcon(strength);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                Icon(strengthIcon, color: strengthColor, size: 24),
                const SizedBox(width: 10),
                Text('Habit Strength',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.textPrimaryLight)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: strengthColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${strength.toInt()}% - $strengthLabel',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: strengthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: LinearProgressIndicator(
                  value: strength / 100,
                  backgroundColor: AppColors.backgroundLightElevated,
                  color: strengthColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getStrengthDescription(strength),
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondaryLight),
            ),
            // Freeze info
            if (habit.freezeDates.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.ac_unit_rounded,
                      size: 16, color: AppColors.streakIce),
                  const SizedBox(width: 6),
                  Text(
                    '${habit.freezeDates.length} streak freeze${habit.freezeDates.length == 1 ? '' : 's'} used total',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.streakIce),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: habit.freezeUsedThisWeek
                          ? AppColors.textTertiaryLight.withValues(alpha: 0.1)
                          : AppColors.streakIce.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      habit.freezeUsedThisWeek
                          ? 'Weekly freeze used'
                          : 'Freeze available',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: habit.freezeUsedThisWeek
                            ? AppColors.textTertiaryLight
                            : AppColors.streakIce,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- SMART REMINDER SECTION ----------
  Widget _buildSmartReminderSection(Habit habit, Color color) {
    final reminder = habit.smartReminderText;
    if (reminder == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondaryPurple.withValues(alpha: 0.08),
              AppColors.secondaryPurple.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule_rounded,
                  color: AppColors.secondaryPurple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Smart Reminder',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.secondaryPurple)),
                  const SizedBox(height: 2),
                  Text(
                    reminder,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeatmap(Habit habit, Color color) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon
    final completedSet = habit.completedDates.toSet();
    final frozenSet = habit.freezeDates.toSet();

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(year, month - 1);
                    });
                  },
                ),
                Text(
                  '${monthNames[month - 1]} $year',
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    final now = DateTime.now();
                    if (_displayedMonth.isBefore(DateTime(now.year, now.month))) {
                      setState(() {
                        _displayedMonth = DateTime(year, month + 1);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Day headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(d,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textTertiaryLight)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: ((startWeekday - 1) + daysInMonth),
              itemBuilder: (context, index) {
                if (index < startWeekday - 1) {
                  return const SizedBox();
                }
                final day = index - (startWeekday - 1) + 1;
                if (day > daysInMonth) return const SizedBox();

                final dateStr =
                    '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                final isCompleted = completedSet.contains(dateStr);
                final isFrozen = frozenSet.contains(dateStr);
                final isToday = dateStr == Habit.todayFormatted();
                final isFuture = DateTime(year, month, day).isAfter(DateTime.now());

                return Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? color.withValues(alpha: 0.85)
                        : isFrozen
                            ? AppColors.streakIce.withValues(alpha: 0.4)
                            : isToday
                                ? color.withValues(alpha: 0.15)
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isCompleted && !isFrozen
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isFrozen && !isCompleted
                        ? const Icon(Icons.ac_unit_rounded,
                            size: 14, color: Colors.white)
                        : Text(
                            '$day',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isCompleted
                                  ? Colors.white
                                  : isFuture
                                      ? AppColors.textTertiaryLight.withValues(alpha: 0.4)
                                      : AppColors.textSecondaryLight,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                  ),
                );
              },
            ),
            // Legend
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(color.withValues(alpha: 0.85), 'Completed'),
                const SizedBox(width: 16),
                _buildLegendItem(AppColors.streakIce.withValues(alpha: 0.4), 'Frozen'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textTertiaryLight)),
      ],
    );
  }

  Widget _buildStreakInfo(Habit habit, Color color) {
    // Find applicable milestone
    String? milestoneMsg;
    for (final milestone in AppConstants.streakMilestones.reversed) {
      if (habit.currentStreak >= milestone) {
        milestoneMsg = AppConstants.streakMessages[milestone];
        break;
      }
    }

    if (milestoneMsg == null && habit.currentStreak == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_fire_department_rounded, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestoneMsg ?? '${habit.currentStreak} day streak!',
                    style: AppTextStyles.titleMedium.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  if (habit.currentStreak > 0)
                    Text(
                      _getNextMilestoneText(habit.currentStreak),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextMilestoneText(int currentStreak) {
    for (final milestone in AppConstants.streakMilestones) {
      if (currentStreak < milestone) {
        final remaining = milestone - currentStreak;
        return '$remaining more days to reach $milestone-day milestone!';
      }
    }
    return 'You\'ve reached all milestones! Amazing!';
  }

  Widget _buildCompletionHistory(Habit habit, Color color) {
    final last7Days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return date;
    });

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 Days',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: last7Days.map((date) {
              final dateStr =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final isCompleted = habit.completedDates.contains(dateStr);
              final isFrozen = habit.freezeDates.contains(dateStr);
              final isToday = dateStr == Habit.todayFormatted();

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? color
                          : isFrozen
                              ? AppColors.streakIce
                              : AppColors.backgroundLightElevated,
                      shape: BoxShape.circle,
                      border: isToday && !isCompleted && !isFrozen
                          ? Border.all(color: color, width: 2)
                          : null,
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : isFrozen
                                ? Icons.ac_unit_rounded
                                : Icons.close_rounded,
                        color: (isCompleted || isFrozen)
                            ? Colors.white
                            : AppColors.textTertiaryLight,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNames[date.weekday - 1],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isToday ? color : AppColors.textTertiaryLight,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Habit habit, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          // Toggle today
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(habitProvider.notifier).toggleCompletion(
                    habit.id,
                    Habit.todayFormatted(),
                  );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: habit.isCompletedToday ? null : AppColors.primaryGradient,
                color: habit.isCompletedToday ? AppColors.backgroundLightElevated : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: habit.isCompletedToday
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  habit.isCompletedToday ? 'Undo Today\'s Completion' : 'Mark as Complete Today',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: habit.isCompletedToday ? AppColors.textSecondaryLight : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Streak freeze button
          if (!habit.isCompletedToday && !habit.isFrozenToday) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: habit.freezeUsedThisWeek
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      final success = ref
                          .read(habitProvider.notifier)
                          .useStreakFreeze(habit.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Streak freeze activated!',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: Colors.white)),
                            backgroundColor: AppColors.streakIce,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: habit.freezeUsedThisWeek
                      ? AppColors.backgroundLightElevated
                      : AppColors.streakIce.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: habit.freezeUsedThisWeek
                        ? AppColors.glassBorder
                        : AppColors.streakIce,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ac_unit_rounded,
                        color: habit.freezeUsedThisWeek
                            ? AppColors.textTertiaryLight
                            : AppColors.streakIce,
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      habit.freezeUsedThisWeek
                          ? 'Weekly Freeze Already Used'
                          : 'Use Streak Freeze (1/week)',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: habit.freezeUsedThisWeek
                            ? AppColors.textTertiaryLight
                            : AppColors.streakIce,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (habit.isFrozenToday) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.streakIce.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.streakIce.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ac_unit_rounded,
                      color: AppColors.streakIce, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Streak is frozen today',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.streakIce),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(Habit habit) {
    final nameController = TextEditingController(text: habit.name);
    String selectedIcon = habit.icon;
    int selectedColor = habit.color;
    String selectedFrequency = habit.frequency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundLightCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Edit Habit',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.textPrimaryLight)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
                  decoration: InputDecoration(
                    hintText: 'Habit name',
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Icon', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondaryLight)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.habitIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = icon),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(selectedColor).withValues(alpha: 0.15)
                              : AppColors.backgroundLightElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: Color(selectedColor), width: 2)
                              : null,
                        ),
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Color', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondaryLight)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.habitColors.map((c) {
                    final isSelected = c == selectedColor;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.textPrimaryLight, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _editFrequencyChip('Daily', 'daily', selectedFrequency, (val) {
                      setModalState(() => selectedFrequency = val);
                    }),
                    const SizedBox(width: 8),
                    _editFrequencyChip('Weekly', 'weekly', selectedFrequency, (val) {
                      setModalState(() => selectedFrequency = val);
                    }),
                    const SizedBox(width: 8),
                    _editFrequencyChip('Custom', 'custom', selectedFrequency, (val) {
                      setModalState(() => selectedFrequency = val);
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    final updated = habit.copyWith(
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      frequency: selectedFrequency,
                    );
                    ref.read(habitProvider.notifier).updateHabit(updated);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('Save Changes',
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editFrequencyChip(
      String label, String value, String selected, ValueChanged<String> onTap) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryOrange.withValues(alpha: 0.1)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryOrange : AppColors.glassBorder,
            ),
          ),
          child: Center(
            child: Text(label,
                style: AppTextStyles.titleSmall.copyWith(
                    color: isSelected ? AppColors.primaryOrange : AppColors.textSecondaryLight)),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Habit',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight)),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? All streak data will be lost.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.textTertiaryLight)),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // Strength helpers
  static String _getStrengthLabel(double strength) {
    if (strength >= 80) return 'Strong';
    if (strength >= 60) return 'Growing';
    if (strength >= 40) return 'Building';
    if (strength >= 20) return 'Fragile';
    return 'New';
  }

  static String _getStrengthDescription(double strength) {
    if (strength >= 80) return 'This habit is deeply rooted. Keep it up to maintain your streak!';
    if (strength >= 60) return 'Getting stronger! A few more consistent days will solidify this habit.';
    if (strength >= 40) return 'Building momentum. Stay consistent to grow this habit further.';
    if (strength >= 20) return 'This habit is still fragile. Daily practice will help it grow.';
    return 'This habit is just starting. Complete it daily to build strength.';
  }

  static IconData _getStrengthIcon(double strength) {
    if (strength >= 80) return Icons.park_rounded;
    if (strength >= 60) return Icons.nature_rounded;
    if (strength >= 40) return Icons.grass_rounded;
    if (strength >= 20) return Icons.eco_rounded;
    return Icons.spa_rounded;
  }

  static Color _getStrengthColor(double strength) {
    if (strength >= 80) return const Color(0xFF10B981);
    if (strength >= 60) return const Color(0xFF34D399);
    if (strength >= 40) return const Color(0xFFFBBF24);
    if (strength >= 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
