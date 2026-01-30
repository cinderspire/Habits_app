import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/habit.dart';
import '../../../../core/providers/habit_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../add_habit/screens/add_habit_screen.dart';
import '../../../calendar/screens/calendar_screen.dart';
import '../../../habit_detail/screens/habit_detail_screen.dart';
import '../../../settings/screens/settings_screen.dart';
import '../../../statistics/screens/statistics_screen.dart';
import '../../../habit_stacking/screens/habit_stacking_screen.dart';
import '../../../weekly_review/screens/weekly_review_screen.dart';
import '../widgets/habit_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/progress_ring.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final AnimationController _fabAnimController;
  late final Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );
    _fabAnimController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    // Re-animate FAB
    _fabAnimController.reset();
    _fabAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHomeTab(),
            const CalendarScreen(),
            const StatisticsScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? ScaleTransition(
              scale: _fabScaleAnim,
              child: FloatingActionButton(
                onPressed: _navigateToAddHabit,
                backgroundColor: AppColors.primaryOrange,
                elevation: 6,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    final habits = ref.watch(todaysHabitsProvider);
    final completedCount = ref.watch(completedTodayCountProvider);
    final bestCurrentStreak = ref.watch(bestCurrentStreakProvider);
    final stackGroupIds = ref.watch(stackGroupIdsProvider);
    final avgStrength = ref.watch(averageStrengthProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(
          child: _buildStreakSection(
            bestCurrentStreak: bestCurrentStreak,
            completedCount: completedCount,
            totalCount: habits.length,
            avgStrength: avgStrength,
          ),
        ),
        // Quick actions row
        SliverToBoxAdapter(child: _buildQuickActions(stackGroupIds)),
        // Habit Stacks section
        if (stackGroupIds.isNotEmpty)
          SliverToBoxAdapter(child: _buildStacksPreview(stackGroupIds)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's Habits",
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.textPrimaryLight)),
                Text('$completedCount/${habits.length}',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primaryOrange)),
              ],
            ),
          ),
        ),
        if (habits.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = habits[index];
                return Dismissible(
                  key: Key(habit.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_rounded, color: AppColors.error, size: 28),
                  ),
                  confirmDismiss: (_) => _confirmDismiss(habit),
                  onDismissed: (_) {
                    ref.read(habitProvider.notifier).deleteHabit(habit.id);
                  },
                  child: HabitCard(
                    habit: habit,
                    onToggle: () => _toggleHabit(habit.id),
                    onDelete: () => _confirmDeleteHabit(habit),
                    onTap: () => _navigateToDetail(habit.id),
                    onFreeze: () => _useStreakFreeze(habit),
                  ),
                );
              },
              childCount: habits.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildQuickActions(List<String> stackGroupIds) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.link_rounded,
              label: 'Habit Stacking',
              color: AppColors.secondaryBlue,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HabitStackingScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.analytics_rounded,
              label: 'Weekly Review',
              color: AppColors.secondaryPurple,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeeklyReviewScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStacksPreview(List<String> stackGroupIds) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded,
                  size: 18, color: AppColors.secondaryBlue),
              const SizedBox(width: 6),
              Text('Habit Chains',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
          const SizedBox(height: 10),
          ...stackGroupIds.map((groupId) {
            final stackHabits = ref.watch(stackGroupProvider(groupId));
            final allDone =
                stackHabits.every((h) => h.isCompletedToday || h.isFrozenToday);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: allDone
                    ? AppColors.secondaryGreen.withOpacity(0.08)
                    : AppColors.backgroundLightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: allDone
                      ? AppColors.secondaryGreen.withOpacity(0.3)
                      : AppColors.glassBorder,
                ),
              ),
              child: Row(
                children: [
                  ...stackHabits.asMap().entries.map((entry) {
                    final i = entry.key;
                    final h = entry.value;
                    final done = h.isCompletedToday || h.isFrozenToday;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: done
                                ? Color(h.color).withOpacity(0.2)
                                : AppColors.backgroundLightElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: done
                                ? Border.all(
                                    color: Color(h.color).withOpacity(0.5))
                                : null,
                          ),
                          child: Text(h.icon,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: done ? null : Colors.grey)),
                        ),
                        if (i < stackHabits.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppColors.textTertiaryLight),
                          ),
                      ],
                    );
                  }),
                  const Spacer(),
                  if (allDone)
                    Icon(Icons.check_circle_rounded,
                        size: 20, color: AppColors.secondaryGreen),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_task_rounded,
                  size: 40, color: AppColors.primaryOrange),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No habits yet',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first habit and start building a better you!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.04),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiaryLight)),
              const SizedBox(height: 4),
              Text('Stay consistent!',
                  style: AppTextStyles.headlineLarge
                      .copyWith(color: AppColors.textPrimaryLight)),
            ],
          ),
          GestureDetector(
            onTap: () => _onTabChanged(3),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection({
    required int bestCurrentStreak,
    required int completedCount,
    required int totalCount,
    required double avgStrength,
  }) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          StreakCard(
            title: 'Current Streak',
            value: '$bestCurrentStreak',
            subtitle: 'days',
            gradient: AppColors.fireGradient,
            icon: Icons.local_fire_department_rounded,
          ),
          StreakCard(
            title: 'Completed Today',
            value: '$completedCount',
            subtitle: 'of $totalCount',
            gradient: AppColors.successGradient,
            icon: Icons.check_circle_rounded,
          ),
          StreakCard(
            title: 'Avg Strength',
            value: '${avgStrength.toInt()}%',
            subtitle: _getStrengthLabel(avgStrength),
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.park_rounded,
          ),
          ProgressRing(
            progress: progress,
            label: 'Daily Goal',
          ),
        ],
      ),
    );
  }

  static String _getStrengthLabel(double strength) {
    if (strength >= 80) return 'Strong';
    if (strength >= 60) return 'Growing';
    if (strength >= 40) return 'Building';
    if (strength >= 20) return 'Fragile';
    return 'New';
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendar'),
              _buildNavItem(2, Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Stats'),
              _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.primaryOrange : AppColors.textTertiaryLight,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleHabit(String habitId) {
    HapticFeedback.mediumImpact();
    final today = Habit.todayFormatted();
    ref.read(habitProvider.notifier).toggleCompletion(habitId, today);
  }

  void _useStreakFreeze(Habit habit) {
    if (habit.isCompletedToday) {
      _showSnackBar('Already completed today!', AppColors.secondaryGreen);
      return;
    }
    if (habit.isFrozenToday) {
      _showSnackBar('Already frozen today!', AppColors.streakIce);
      return;
    }
    if (habit.freezeUsedThisWeek) {
      _showSnackBar(
          'Streak freeze already used this week', AppColors.textTertiaryLight);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.ac_unit_rounded, color: AppColors.streakIce),
            const SizedBox(width: 10),
            Text('Use Streak Freeze?',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.textPrimaryLight)),
          ],
        ),
        content: Text(
          'This will protect your streak for "${habit.name}" today without completing it. You get one freeze per habit per week.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textTertiaryLight)),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final success = ref
                  .read(habitProvider.notifier)
                  .useStreakFreeze(habit.id);
              Navigator.pop(ctx);
              if (success) {
                _showSnackBar(
                    'Streak freeze activated for "${habit.name}"!',
                    AppColors.streakIce);
              }
            },
            child: Text('Freeze',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.streakIce)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _confirmDismiss(Habit habit) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Delete Habit',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.textPrimaryLight)),
            content: Text(
              'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.textTertiaryLight)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _confirmDeleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Habit',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textPrimaryLight)),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textTertiaryLight)),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style:
                    AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddHabit() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddHabitScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToDetail(String habitId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HabitDetailScreen(habitId: habitId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
