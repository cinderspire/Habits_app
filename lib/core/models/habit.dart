import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String frequency; // 'daily', 'weekly', or 'custom'
  final List<int> customDays; // weekday numbers 1-7 for custom frequency
  final String? reminderTime; // HH:mm format
  final int targetPerDay; // how many times per day (default 1)
  final List<String> completedDates; // yyyy-MM-dd format
  final DateTime createdAt;

  // -- Habit Stacking --
  final String? stackGroupId; // group ID for chained habits
  final int stackOrder; // order within the stack (0-based)

  // -- Streak Protection --
  final List<String> freezeDates; // dates where streak freeze was used

  // -- Smart Reminders --
  final List<String> completionTimes; // HH:mm timestamps of completions

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.frequency = 'daily',
    List<int>? customDays,
    this.reminderTime,
    this.targetPerDay = 1,
    List<String>? completedDates,
    DateTime? createdAt,
    this.stackGroupId,
    this.stackOrder = 0,
    List<String>? freezeDates,
    List<String>? completionTimes,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now(),
        customDays = customDays ?? [],
        freezeDates = freezeDates ?? [],
        completionTimes = completionTimes ?? [];

  // ---------- Computed Properties ----------

  String get _todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get isCompletedToday => completedDates.contains(_todayString);

  bool get isFrozenToday => freezeDates.contains(_todayString);

  /// Whether this habit should be shown today based on frequency
  bool get isScheduledToday {
    if (frequency == 'daily') return true;
    if (frequency == 'weekly') return DateTime.now().weekday == 1;
    if (frequency == 'custom' && customDays.isNotEmpty) {
      return customDays.contains(DateTime.now().weekday);
    }
    return true;
  }

  /// Whether a freeze was already used this week (Mon-Sun)
  bool get freezeUsedThisWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dayStr = _formatDate(day);
      if (freezeDates.contains(dayStr)) return true;
    }
    return false;
  }

  int get currentStreak {
    if (completedDates.isEmpty && freezeDates.isEmpty) return 0;

    final allActiveDates = <String>{...completedDates, ...freezeDates};
    final sorted = allActiveDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayStr = _todayString;
    final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

    // Streak must include today or yesterday to be "current"
    if (!sorted.contains(todayStr) && !sorted.contains(yesterdayStr)) return 0;

    int streak = 0;
    DateTime checkDate = sorted.contains(todayStr)
        ? today
        : today.subtract(const Duration(days: 1));

    while (true) {
      final dateStr = _formatDate(checkDate);
      if (allActiveDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (completedDates.isEmpty && freezeDates.isEmpty) return 0;

    final allActiveDates = <String>{...completedDates, ...freezeDates};
    final sorted = allActiveDates.toList()..sort();
    int longest = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      final diff = curr.difference(prev).inDays;

      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
      // diff == 0 means duplicate date, skip
    }
    return longest;
  }

  double get completionRate {
    if (completedDates.isEmpty) return 0.0;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    final uniqueDates = completedDates.toSet().length;
    return (uniqueDates / daysSinceCreation).clamp(0.0, 1.0);
  }

  /// Habit Strength: 0-100 based on consistency over last 30 days
  double get strength {
    final now = DateTime.now();
    double score = 0.0;
    int totalWeight = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final weight = 30 - i;
      totalWeight += weight;

      if (completedDates.contains(dateStr)) {
        score += weight;
      } else if (freezeDates.contains(dateStr)) {
        score += weight * 0.5;
      }
    }

    if (totalWeight == 0) return 0.0;
    return ((score / totalWeight) * 100).clamp(0.0, 100.0);
  }

  /// Get the average completion time as HH:mm, or null if no data
  String? get averageCompletionTime {
    if (completionTimes.isEmpty) return null;

    int totalMinutes = 0;
    int count = 0;
    for (final t in completionTimes) {
      final parts = t.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          totalMinutes += h * 60 + m;
          count++;
        }
      }
    }
    if (count == 0) return null;

    final avgMinutes = totalMinutes ~/ count;
    final hour = avgMinutes ~/ 60;
    final minute = avgMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Human-readable smart reminder text
  String? get smartReminderText {
    final avg = averageCompletionTime;
    if (avg == null) return null;
    final parts = avg.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return 'You usually complete this around $displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Frequency display text
  String get frequencyDisplayText {
    if (frequency == 'daily') return 'Daily';
    if (frequency == 'weekly') return 'Weekly';
    if (frequency == 'custom' && customDays.isNotEmpty) {
      const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final labels = customDays.map((d) => dayLabels[d - 1]).toList();
      return labels.join(', ');
    }
    return 'Daily';
  }

  // ---------- Helpers ----------

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String todayFormatted() {
    return _formatDate(DateTime.now());
  }

  static String nowTimeFormatted() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ---------- Copy ----------

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    String? frequency,
    List<int>? customDays,
    String? reminderTime,
    int? targetPerDay,
    List<String>? completedDates,
    DateTime? createdAt,
    String? stackGroupId,
    int? stackOrder,
    List<String>? freezeDates,
    List<String>? completionTimes,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? List<int>.from(this.customDays),
      reminderTime: reminderTime ?? this.reminderTime,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      completedDates: completedDates ?? List<String>.from(this.completedDates),
      createdAt: createdAt ?? this.createdAt,
      stackGroupId: stackGroupId ?? this.stackGroupId,
      stackOrder: stackOrder ?? this.stackOrder,
      freezeDates: freezeDates ?? List<String>.from(this.freezeDates),
      completionTimes: completionTimes ?? List<String>.from(this.completionTimes),
    );
  }

  /// Copy that clears nullable stackGroupId
  Habit copyWithClearedStack() {
    return Habit(
      id: id,
      name: name,
      icon: icon,
      color: color,
      frequency: frequency,
      customDays: List<int>.from(customDays),
      reminderTime: reminderTime,
      targetPerDay: targetPerDay,
      completedDates: List<String>.from(completedDates),
      createdAt: createdAt,
      stackGroupId: null,
      stackOrder: 0,
      freezeDates: List<String>.from(freezeDates),
      completionTimes: List<String>.from(completionTimes),
    );
  }

  // ---------- JSON Serialization ----------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'customDays': customDays,
      'reminderTime': reminderTime,
      'targetPerDay': targetPerDay,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
      'stackGroupId': stackGroupId,
      'stackOrder': stackOrder,
      'freezeDates': freezeDates,
      'completionTimes': completionTimes,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      frequency: json['frequency'] as String? ?? 'daily',
      customDays: (json['customDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      reminderTime: json['reminderTime'] as String?,
      targetPerDay: json['targetPerDay'] as int? ?? 1,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      stackGroupId: json['stackGroupId'] as String?,
      stackOrder: json['stackOrder'] as int? ?? 0,
      freezeDates: (json['freezeDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      completionTimes: (json['completionTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  static String encode(List<Habit> habits) {
    return jsonEncode(habits.map((h) => h.toJson()).toList());
  }

  static List<Habit> decode(String habitsString) {
    final List<dynamic> jsonList = jsonDecode(habitsString) as List<dynamic>;
    return jsonList
        .map((json) => Habit.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
