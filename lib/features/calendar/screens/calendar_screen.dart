import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildMonthNavigation()),
          SliverToBoxAdapter(child: _buildCalendarGrid(habits)),
          if (_selectedDate != null)
            SliverToBoxAdapter(child: _buildDateDetail(habits)),
          SliverToBoxAdapter(child: _buildMonthSummary(habits)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        'Calendar',
        style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryLight),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(year, month - 1);
                _selectedDate = null;
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightCard,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textPrimaryLight),
            ),
          ),
          Text(
            '${_monthNames[month - 1]} $year',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryLight),
          ),
          IconButton(
            onPressed: () {
              final now = DateTime.now();
              if (_displayedMonth.isBefore(DateTime(now.year, now.month))) {
                setState(() {
                  _displayedMonth = DateTime(year, month + 1);
                  _selectedDate = null;
                });
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightCard,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<Habit> habits) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon

    // Build completion map for this month
    final completionMap = <String, int>{};
    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      completionMap[dateStr] = habits.where((h) => h.completedDates.contains(dateStr)).length;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Day headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => SizedBox(
                        width: 40,
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
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: (startWeekday - 1) + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startWeekday - 1) {
                  return const SizedBox();
                }
                final day = index - (startWeekday - 1) + 1;
                if (day > daysInMonth) return const SizedBox();

                final dateStr =
                    '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                final completedCount = completionMap[dateStr] ?? 0;
                final isToday = dateStr == Habit.todayFormatted();
                final isFuture = DateTime(year, month, day).isAfter(DateTime.now());
                final isSelected = _selectedDate == dateStr;

                // Heatmap intensity
                double intensity = 0;
                if (habits.isNotEmpty && !isFuture) {
                  intensity = completedCount / habits.length;
                }

                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () => setState(() => _selectedDate = dateStr),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isFuture
                          ? Colors.transparent
                          : intensity > 0
                              ? AppColors.secondaryGreen.withValues(alpha: 0.15 + intensity * 0.65)
                              : isSelected
                                  ? AppColors.primaryOrange.withValues(alpha: 0.1)
                                  : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: AppColors.primaryOrange, width: 2)
                          : isSelected
                              ? Border.all(color: AppColors.primaryOrange, width: 1.5)
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: intensity > 0.6
                              ? Colors.white
                              : isFuture
                                  ? AppColors.textTertiaryLight.withValues(alpha: 0.4)
                                  : isToday
                                      ? AppColors.primaryOrange
                                      : AppColors.textSecondaryLight,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Less ',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiaryLight)),
                ...List.generate(5, (i) {
                  final opacity = 0.15 + (i / 4) * 0.65;
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? AppColors.backgroundLightElevated
                          : AppColors.secondaryGreen.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
                Text(' More',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiaryLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDetail(List<Habit> habits) {
    if (_selectedDate == null) return const SizedBox.shrink();

    final parts = _selectedDate!.split('-');
    final day = int.parse(parts[2]);
    final month = int.parse(parts[1]);
    final dayOfWeek = DateTime(int.parse(parts[0]), month, day).weekday;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    final completedHabits =
        habits.where((h) => h.completedDates.contains(_selectedDate)).toList();
    final missedHabits =
        habits.where((h) => !h.completedDates.contains(_selectedDate)).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primaryOrange, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_monthNames[month - 1]} $day',
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: AppColors.textPrimaryLight),
                      ),
                      Text(
                        dayNames[dayOfWeek - 1],
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textTertiaryLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${completedHabits.length}/${habits.length}',
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.secondaryGreen),
                  ),
                ),
              ],
            ),
            if (completedHabits.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Completed',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.secondaryGreen)),
              const SizedBox(height: 8),
              ...completedHabits.map((h) => _buildDateHabitRow(h, true)),
            ],
            if (missedHabits.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Missed',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.error)),
              const SizedBox(height: 8),
              ...missedHabits.map((h) => _buildDateHabitRow(h, false)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateHabitRow(Habit habit, bool completed) {
    final color = Color(habit.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Text(habit.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimaryLight,
                decoration: completed ? TextDecoration.lineThrough : null,
              )),
          const Spacer(),
          Icon(
            completed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: completed ? AppColors.secondaryGreen : AppColors.error.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final now = DateTime.now();

    int totalPossible = 0;
    int totalCompleted = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.isAfter(now)) break;

      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      totalPossible += habits.length;
      totalCompleted += habits.where((h) => h.completedDates.contains(dateStr)).length;
    }

    final rate = totalPossible > 0 ? totalCompleted / totalPossible : 0.0;

    // Best day this month
    String bestDay = '';
    int bestCount = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.isAfter(now)) break;
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final count = habits.where((h) => h.completedDates.contains(dateStr)).length;
      if (count > bestCount) {
        bestCount = count;
        bestDay = '${_monthNames[month - 1]} $day';
      }
    }

    // Perfect days
    int perfectDays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.isAfter(now)) break;
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final count = habits.where((h) => h.completedDates.contains(dateStr)).length;
      if (count == habits.length) perfectDays++;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Summary',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.textPrimaryLight)),
            const SizedBox(height: 16),
            _buildSummaryRow(Icons.percent_rounded, 'Completion Rate',
                '${(rate * 100).toInt()}%', AppColors.secondaryGreen),
            _buildSummaryRow(Icons.star_rounded, 'Perfect Days',
                '$perfectDays', AppColors.streakGold),
            _buildSummaryRow(Icons.emoji_events_rounded, 'Best Day',
                bestDay.isEmpty ? '-' : '$bestDay ($bestCount/${habits.length})', AppColors.primaryOrange),
            _buildSummaryRow(Icons.check_circle_outline_rounded, 'Total Completions',
                '$totalCompleted', AppColors.secondaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondaryLight)),
          ),
          Text(value,
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryLight)),
        ],
      ),
    );
  }
}
