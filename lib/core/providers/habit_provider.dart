import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

const _storageKey = 'habitly_habits';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// Main habit list provider
final habitProvider =
    StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HabitNotifier(prefs);
});

// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(false) {
    state = _prefs.getBool('habitly_theme_mode') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool('habitly_theme_mode', state);
  }

  Future<void> setDarkMode(bool value) async {
    state = value;
    await _prefs.setBool('habitly_theme_mode', value);
  }
}

// Computed providers
final todaysHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitProvider);
  return habits.where((h) => h.isScheduledToday).toList();
});

final completedTodayCountProvider = Provider<int>((ref) {
  final habits = ref.watch(todaysHabitsProvider);
  return habits.where((h) => h.isCompletedToday).length;
});

final overallCompletionRateProvider = Provider<double>((ref) {
  final habits = ref.watch(habitProvider);
  if (habits.isEmpty) return 0.0;
  final total = habits.fold<double>(0, (sum, h) => sum + h.completionRate);
  return total / habits.length;
});

final bestStreakProvider = Provider<int>((ref) {
  final habits = ref.watch(habitProvider);
  if (habits.isEmpty) return 0;
  return habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
});

final bestCurrentStreakProvider = Provider<int>((ref) {
  final habits = ref.watch(habitProvider);
  if (habits.isEmpty) return 0;
  return habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
});

// ====== HABIT STACKING PROVIDERS ======

/// All unique stack group IDs
final stackGroupIdsProvider = Provider<List<String>>((ref) {
  final habits = ref.watch(habitProvider);
  final ids = <String>{};
  for (final h in habits) {
    if (h.stackGroupId != null) ids.add(h.stackGroupId!);
  }
  return ids.toList();
});

/// Habits in a specific stack group, sorted by stackOrder
final stackGroupProvider = Provider.family<List<Habit>, String>((ref, groupId) {
  final habits = ref.watch(habitProvider);
  final group = habits.where((h) => h.stackGroupId == groupId).toList();
  group.sort((a, b) => a.stackOrder.compareTo(b.stackOrder));
  return group;
});

/// Habits NOT in any stack group
final unstackedHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitProvider);
  return habits.where((h) => h.stackGroupId == null).toList();
});

// ====== WEEKLY REVIEW PROVIDER ======

class WeeklyReview {
  final double completionRate;
  final int totalCompleted;
  final int totalPossible;
  final Habit? bestHabit;
  final Habit? worstHabit;
  final Map<String, int> streakChanges; // habitId -> change in streak
  final List<String> suggestions;
  final int perfectDays;
  final int frozenDays;

  WeeklyReview({
    required this.completionRate,
    required this.totalCompleted,
    required this.totalPossible,
    this.bestHabit,
    this.worstHabit,
    required this.streakChanges,
    required this.suggestions,
    required this.perfectDays,
    required this.frozenDays,
  });
}

final weeklyReviewProvider = Provider<WeeklyReview>((ref) {
  final habits = ref.watch(habitProvider);
  final now = DateTime.now();
  // Last 7 days
  final last7 = List.generate(7, (i) {
    final d = now.subtract(Duration(days: i));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  });

  int totalCompleted = 0;
  int totalPossible = habits.length * 7;
  int perfectDays = 0;
  int frozenDays = 0;

  // Per-habit week completions
  final habitWeekCompletions = <String, int>{};
  for (final h in habits) {
    int count = 0;
    for (final d in last7) {
      if (h.completedDates.contains(d)) count++;
      if (h.freezeDates.contains(d)) frozenDays++;
    }
    habitWeekCompletions[h.id] = count;
    totalCompleted += count;
  }

  // Perfect days
  for (final d in last7) {
    final allDone = habits.every((h) =>
        h.completedDates.contains(d) || h.freezeDates.contains(d));
    if (allDone && habits.isNotEmpty) perfectDays++;
  }

  // Best and worst
  Habit? bestHabit;
  Habit? worstHabit;
  int bestCount = -1;
  int worstCount = 8;
  for (final h in habits) {
    final c = habitWeekCompletions[h.id] ?? 0;
    if (c > bestCount) {
      bestCount = c;
      bestHabit = h;
    }
    if (c < worstCount) {
      worstCount = c;
      worstHabit = h;
    }
  }

  final rate = totalPossible > 0 ? totalCompleted / totalPossible : 0.0;

  // Suggestions
  final suggestions = <String>[];
  if (rate < 0.5) {
    suggestions.add('Try focusing on just 2-3 key habits to build momentum.');
  }
  if (rate >= 0.8) {
    suggestions.add('Amazing week! Consider adding a new challenge.');
  }
  if (worstHabit != null && worstCount <= 2) {
    suggestions.add(
        'Consider rescheduling "${worstHabit.name}" to a more convenient time.');
  }
  if (bestHabit != null && bestCount >= 6) {
    suggestions.add(
        '"${bestHabit.name}" is becoming automatic. Great consistency!');
  }
  if (perfectDays == 0) {
    suggestions.add('Aim for at least one perfect day next week.');
  }
  if (frozenDays > 3) {
    suggestions.add('You used several streak freezes. Try to rely less on them.');
  }
  if (habits.any((h) => h.strength < 30)) {
    suggestions.add('Some habits are losing strength. Focus on daily consistency.');
  }

  // Streak changes (approximate: current streak vs what it might have been 7 days ago)
  final streakChanges = <String, int>{};
  for (final h in habits) {
    streakChanges[h.id] = habitWeekCompletions[h.id] ?? 0;
  }

  return WeeklyReview(
    completionRate: rate,
    totalCompleted: totalCompleted,
    totalPossible: totalPossible,
    bestHabit: bestHabit,
    worstHabit: worstHabit,
    streakChanges: streakChanges,
    suggestions: suggestions,
    perfectDays: perfectDays,
    frozenDays: frozenDays,
  );
});

// ====== AVERAGE STRENGTH ======
final averageStrengthProvider = Provider<double>((ref) {
  final habits = ref.watch(habitProvider);
  if (habits.isEmpty) return 0.0;
  final total = habits.fold<double>(0, (sum, h) => sum + h.strength);
  return total / habits.length;
});

// HabitNotifier
class HabitNotifier extends StateNotifier<List<Habit>> {
  final SharedPreferences _prefs;

  HabitNotifier(this._prefs) : super([]) {
    _loadHabits();
  }

  void _loadHabits() {
    final habitsString = _prefs.getString(_storageKey);
    if (habitsString != null && habitsString.isNotEmpty) {
      try {
        state = Habit.decode(habitsString);
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _saveHabits() async {
    await _prefs.setString(_storageKey, Habit.encode(state));
  }

  void addHabit(Habit habit) {
    state = [...state, habit];
    _saveHabits();
  }

  void updateHabit(Habit updated) {
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h,
    ];
    _saveHabits();
  }

  void deleteHabit(String id) {
    state = state.where((h) => h.id != id).toList();
    _saveHabits();
  }

  void toggleCompletion(String habitId, String date) {
    state = [
      for (final h in state)
        if (h.id == habitId)
          h.copyWith(
            completedDates: h.completedDates.contains(date)
                ? (List<String>.from(h.completedDates)..remove(date))
                : [...h.completedDates, date],
            // Record completion time for smart reminders
            completionTimes: !h.completedDates.contains(date)
                ? [...h.completionTimes, Habit.nowTimeFormatted()]
                : h.completionTimes,
          )
        else
          h,
    ];
    _saveHabits();
  }

  // ====== STREAK FREEZE ======

  /// Use a streak freeze for today. Returns true if successful.
  bool useStreakFreeze(String habitId) {
    final habit = state.firstWhere((h) => h.id == habitId);
    final today = Habit.todayFormatted();

    // Can't freeze if already completed today
    if (habit.isCompletedToday) return false;
    // Can't freeze if already frozen today
    if (habit.isFrozenToday) return false;
    // Can't freeze if already used this week
    if (habit.freezeUsedThisWeek) return false;

    state = [
      for (final h in state)
        if (h.id == habitId)
          h.copyWith(freezeDates: [...h.freezeDates, today])
        else
          h,
    ];
    _saveHabits();
    return true;
  }

  // ====== HABIT STACKING ======

  /// Create a new stack group from a list of habit IDs (in order)
  void createStack(List<String> habitIds) {
    if (habitIds.length < 2) return;
    final groupId = DateTime.now().millisecondsSinceEpoch.toString();

    state = [
      for (final h in state)
        if (habitIds.contains(h.id))
          h.copyWith(
            stackGroupId: groupId,
            stackOrder: habitIds.indexOf(h.id),
          )
        else
          h,
    ];
    _saveHabits();
  }

  /// Remove a habit from its stack
  void removeFromStack(String habitId) {
    state = [
      for (final h in state)
        if (h.id == habitId) h.copyWithClearedStack() else h,
    ];
    _saveHabits();
  }

  /// Dissolve an entire stack group
  void dissolveStack(String groupId) {
    state = [
      for (final h in state)
        if (h.stackGroupId == groupId) h.copyWithClearedStack() else h,
    ];
    _saveHabits();
  }

  void clearAllHabits() {
    state = [];
    _saveHabits();
  }

  /// Reorder habits within a stack
  void reorderStack(String groupId, List<String> orderedIds) {
    state = [
      for (final h in state)
        if (h.stackGroupId == groupId)
          h.copyWith(stackOrder: orderedIds.indexOf(h.id))
        else
          h,
    ];
    _saveHabits();
  }
}
