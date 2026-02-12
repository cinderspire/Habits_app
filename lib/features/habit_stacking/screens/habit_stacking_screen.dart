import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HabitStackingScreen extends ConsumerStatefulWidget {
  const HabitStackingScreen({super.key});

  @override
  ConsumerState<HabitStackingScreen> createState() =>
      _HabitStackingScreenState();
}

class _HabitStackingScreenState extends ConsumerState<HabitStackingScreen> {
  bool _isCreatingStack = false;
  final List<String> _selectedForStack = [];

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final stackGroupIds = ref.watch(stackGroupIdsProvider);
    final unstacked = ref.watch(unstackedHabitsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Habit Stacking',
          style: AppTextStyles.headlineMedium
              .copyWith(color: AppColors.textPrimaryLight),
        ),
        centerTitle: true,
        actions: [
          if (!_isCreatingStack && habits.length >= 2)
            IconButton(
              icon: const Icon(Icons.add_link_rounded,
                  color: AppColors.secondaryBlue),
              onPressed: () => setState(() {
                _isCreatingStack = true;
                _selectedForStack.clear();
              }),
              tooltip: 'Create new chain',
            ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Info banner
          SliverToBoxAdapter(child: _buildInfoBanner()),

          // Create stack mode
          if (_isCreatingStack)
            SliverToBoxAdapter(child: _buildCreateStackSection(habits)),

          // Existing stacks
          if (stackGroupIds.isNotEmpty && !_isCreatingStack)
            SliverToBoxAdapter(
                child: _buildExistingStacks(stackGroupIds)),

          // Unstacked habits
          if (unstacked.isNotEmpty && !_isCreatingStack)
            SliverToBoxAdapter(
                child: _buildUnstackedHabits(unstacked)),

          if (habits.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState()),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondaryBlue.withValues(alpha: 0.08),
              AppColors.secondaryPurple.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryBlue.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link_rounded,
                  color: AppColors.secondaryBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chain habits together',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.secondaryBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'e.g. After coffee -> Meditate -> Journal. Complete them in order to build powerful routines.',
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

  Widget _buildCreateStackSection(List<Habit> habits) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select habits to chain (min 2)',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textSecondaryLight)),
              TextButton(
                onPressed: () => setState(() {
                  _isCreatingStack = false;
                  _selectedForStack.clear();
                }),
                child: Text('Cancel',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...habits.map((habit) {
            final isSelected = _selectedForStack.contains(habit.id);
            final order = _selectedForStack.indexOf(habit.id);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedForStack.remove(habit.id);
                  } else {
                    _selectedForStack.add(habit.id);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondaryBlue.withValues(alpha: 0.08)
                      : AppColors.backgroundLightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryBlue
                        : AppColors.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${order + 1}',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(habit.color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(habit.icon,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(habit.name,
                          style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.textPrimaryLight)),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected
                          ? AppColors.secondaryBlue
                          : AppColors.textTertiaryLight,
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          }),

          // Preview
          if (_selectedForStack.length >= 2) ...[
            const SizedBox(height: 16),
            Text('Chain preview:',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightCard,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.secondaryBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: _selectedForStack.asMap().entries.map((entry) {
                  final i = entry.key;
                  final id = entry.value;
                  final habit = habits.firstWhere((h) => h.id == id);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(habit.icon, style: const TextStyle(fontSize: 22)),
                      if (i < _selectedForStack.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 18, color: AppColors.secondaryBlue),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _createStack,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Create Chain',
                    style:
                        AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExistingStacks(List<String> stackGroupIds) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Habit Chains',
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.textPrimaryLight)),
          const SizedBox(height: 12),
          ...stackGroupIds.map((groupId) {
            final stackHabits = ref.watch(stackGroupProvider(groupId));
            final allDone =
                stackHabits.every((h) => h.isCompletedToday || h.isFrozenToday);
            final completedCount = stackHabits
                .where((h) => h.isCompletedToday || h.isFrozenToday)
                .length;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: allDone
                    ? AppColors.secondaryGreen.withValues(alpha: 0.06)
                    : AppColors.backgroundLightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: allDone
                      ? AppColors.secondaryGreen.withValues(alpha: 0.3)
                      : AppColors.glassBorder,
                ),
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
                  // Chain visual
                  Row(
                    children: [
                      ...stackHabits.asMap().entries.map((entry) {
                        final i = entry.key;
                        final h = entry.value;
                        final done =
                            h.isCompletedToday || h.isFrozenToday;
                        return Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: done
                                            ? Color(h.color).withValues(alpha: 0.2)
                                            : AppColors.backgroundLightElevated,
                                        shape: BoxShape.circle,
                                        border: done
                                            ? Border.all(
                                                color: Color(h.color), width: 2)
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(h.icon,
                                            style:
                                                const TextStyle(fontSize: 20)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      h.name,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: done
                                            ? Color(h.color)
                                            : AppColors.textTertiaryLight,
                                        fontWeight: done
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (i < stackHabits.length - 1)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: done
                                        ? AppColors.secondaryGreen
                                        : AppColors.textTertiaryLight
                                            .withValues(alpha: 0.4),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress + dissolve
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stackHabits.isEmpty
                                ? 0
                                : completedCount / stackHabits.length,
                            backgroundColor: AppColors.backgroundLightElevated,
                            color: allDone
                                ? AppColors.secondaryGreen
                                : AppColors.secondaryBlue,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedCount/${stackHabits.length}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: allDone
                              ? AppColors.secondaryGreen
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _dissolveStack(groupId),
                        child: Icon(Icons.link_off_rounded,
                            size: 20,
                            color: AppColors.textTertiaryLight),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUnstackedHabits(List<Habit> unstacked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unchained Habits',
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.textTertiaryLight)),
          const SizedBox(height: 8),
          ...unstacked.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Text(h.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(h.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimaryLight)),
                    ),
                    Text('${h.strength.toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiaryLight)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          Icon(Icons.link_off_rounded,
              size: 48, color: AppColors.textTertiaryLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No habits to chain yet',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Create at least 2 habits first, then chain them into a routine.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiaryLight),
          ),
        ],
      ),
    );
  }

  void _createStack() {
    if (_selectedForStack.length < 2) return;
    HapticFeedback.mediumImpact();
    ref.read(habitProvider.notifier).createStack(_selectedForStack);
    setState(() {
      _isCreatingStack = false;
      _selectedForStack.clear();
    });
  }

  void _dissolveStack(String groupId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Break Chain?',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textPrimaryLight)),
        content: Text(
          'This will unlink all habits in this chain. The habits themselves will not be deleted.',
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
              ref.read(habitProvider.notifier).dissolveStack(groupId);
              Navigator.pop(ctx);
            },
            child: Text('Break Chain',
                style:
                    AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
