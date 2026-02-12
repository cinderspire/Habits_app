import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _selectedPeriod = 0; // 0 = week, 1 = month

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
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
    final overallRate = ref.watch(overallCompletionRateProvider);
    final bestStreak = ref.watch(bestStreakProvider);

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildOverviewCards(habits, overallRate, bestStreak)),
          SliverToBoxAdapter(child: _buildPeriodSelector()),
          SliverToBoxAdapter(child: _buildCompletionChart(habits)),
          SliverToBoxAdapter(child: _buildHabitRanking(habits)),
          SliverToBoxAdapter(child: _buildStreakLeaderboard(habits)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        'Statistics',
        style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryLight),
      ),
    );
  }

  Widget _buildOverviewCards(List<Habit> habits, double overallRate, int bestStreak) {
    final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.completedDates.toSet().length);
    final activeDays = _getActiveDays(habits);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOverviewTile(
                  'Completion Rate',
                  '${(overallRate * 100).toInt()}%',
                  Icons.pie_chart_rounded,
                  AppColors.secondaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewTile(
                  'Best Streak',
                  '$bestStreak days',
                  Icons.local_fire_department_rounded,
                  AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewTile(
                  'Total Completions',
                  '$totalCompletions',
                  Icons.check_circle_rounded,
                  AppColors.secondaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewTile(
                  'Active Days',
                  '$activeDays',
                  Icons.calendar_today_rounded,
                  AppColors.secondaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewTile(
                  'Total Habits',
                  '${habits.length}',
                  Icons.list_alt_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewTile(
                  'Avg Strength',
                  habits.isEmpty
                      ? '0%'
                      : '${(habits.fold<double>(0, (s, h) => s + h.strength) / habits.length).toInt()}%',
                  Icons.park_rounded,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTile(String label, String value, IconData icon, Color color) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.textPrimaryLight)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryLight)),
        ],
      ),
    );
  }

  int _getActiveDays(List<Habit> habits) {
    final allDates = <String>{};
    for (final h in habits) {
      allDates.addAll(h.completedDates);
    }
    return allDates.length;
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildPeriodChip('Weekly', 0),
          const SizedBox(width: 12),
          _buildPeriodChip('Monthly', 1),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionChart(List<Habit> habits) {
    if (habits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.backgroundLightCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text('Add habits to see statistics',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryLight)),
          ),
        ),
      );
    }

    final isWeekly = _selectedPeriod == 0;
    final dataPoints = isWeekly ? _getWeeklyData(habits) : _getMonthlyData(habits);
    final labels = isWeekly
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['W1', 'W2', 'W3', 'W4'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 260,
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
            Text('Completion Trend',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryLight)),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.textPrimaryLight,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()}%',
                          AppTextStyles.labelSmall.copyWith(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[idx],
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.textTertiaryLight)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 50 || value == 100) {
                            return Text('${value.toInt()}',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.textTertiaryLight));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.backgroundLightElevated,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(dataPoints.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: dataPoints[i],
                          width: isWeekly ? 28 : 40,
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryOrange,
                              AppColors.primaryOrange.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _getWeeklyData(List<Habit> habits) {
    final now = DateTime.now();
    final todayWeekday = now.weekday;

    return List.generate(7, (index) {
      final dayOffset = index + 1 - todayWeekday;
      final date = now.add(Duration(days: dayOffset));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (habits.isEmpty) return 0.0;
      final completed = habits.where((h) => h.completedDates.contains(dateStr)).length;
      return (completed / habits.length * 100).clamp(0.0, 100.0);
    });
  }

  List<double> _getMonthlyData(List<Habit> habits) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);

    return List.generate(4, (weekIndex) {
      double total = 0;
      int days = 0;

      for (int d = 0; d < 7; d++) {
        final dayOffset = weekIndex * 7 + d;
        final date = firstOfMonth.add(Duration(days: dayOffset));
        if (date.month != now.month || date.isAfter(now)) continue;

        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (habits.isNotEmpty) {
          final completed = habits.where((h) => h.completedDates.contains(dateStr)).length;
          total += completed / habits.length * 100;
        }
        days++;
      }

      return days > 0 ? (total / days).clamp(0.0, 100.0) : 0.0;
    });
  }

  Widget _buildHabitRanking(List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Habit Performance',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          ...sorted.map((habit) {
            final rate = habit.completionRate;
            final color = Color(habit.color);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(habit.icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name,
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.textPrimaryLight)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate,
                            backgroundColor: AppColors.backgroundLightElevated,
                            color: color,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${(rate * 100).toInt()}%',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStreakLeaderboard(List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    final top = sorted.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Streak Leaderboard',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          Container(
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
              children: List.generate(top.length, (index) {
                final habit = top[index];
                final color = Color(habit.color);
                final medals = ['🥇', '🥈', '🥉'];

                return Padding(
                  padding: EdgeInsets.only(bottom: index < top.length - 1 ? 16 : 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Center(
                          child: Text(
                            index < 3 ? medals[index] : '${index + 1}',
                            style: index < 3
                                ? const TextStyle(fontSize: 20)
                                : AppTextStyles.titleSmall
                                    .copyWith(color: AppColors.textTertiaryLight),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(habit.icon, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(habit.name,
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.textPrimaryLight)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: habit.currentStreak > 0
                              ? AppColors.primaryOrange.withValues(alpha: 0.1)
                              : AppColors.backgroundLightElevated,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: habit.currentStreak > 0
                                  ? AppColors.primaryOrange
                                  : AppColors.textTertiaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.currentStreak}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: habit.currentStreak > 0
                                    ? AppColors.primaryOrange
                                    : AppColors.textTertiaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
