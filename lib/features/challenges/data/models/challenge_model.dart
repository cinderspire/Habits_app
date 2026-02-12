class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int totalDays;
  final int currentDay;
  final Map<int, bool> dailyCompletion;
  final DateTime startDate;
  final int dailyTarget;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '🏆',
    required this.totalDays,
    required this.currentDay,
    required this.dailyCompletion,
    required this.startDate,
    this.dailyTarget = 1,
  });

  double get progress {
    if (totalDays == 0) return 0;
    return completedDays / totalDays;
  }

  int get completedDays => dailyCompletion.values.where((v) => v).length;
  bool get isCompleted => completedDays >= totalDays;

  int get daysLeft {
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (totalDays - elapsed).clamp(0, totalDays);
  }

  bool get isTodayCompleted {
    final dayNumber = DateTime.now().difference(startDate).inDays + 1;
    return dailyCompletion[dayNumber] ?? false;
  }

  int get currentStreak {
    final today = DateTime.now().difference(startDate).inDays + 1;
    int streak = 0;
    for (int d = today; d >= 1; d--) {
      if (dailyCompletion[d] == true) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  ChallengeModel completeToday() {
    final dayNumber = DateTime.now().difference(startDate).inDays + 1;
    if (dayNumber > totalDays) return this;
    final newCompletion = Map<int, bool>.from(dailyCompletion);
    newCompletion[dayNumber] = true;
    return ChallengeModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      totalDays: totalDays,
      currentDay: dayNumber,
      dailyCompletion: newCompletion,
      startDate: startDate,
      dailyTarget: dailyTarget,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'totalDays': totalDays,
        'currentDay': currentDay,
        'dailyCompletion':
            dailyCompletion.map((k, v) => MapEntry(k.toString(), v)),
        'startDate': startDate.toIso8601String(),
        'dailyTarget': dailyTarget,
      };

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    final raw = json['dailyCompletion'] as Map<String, dynamic>? ?? {};
    return ChallengeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'] ?? '🏆',
      totalDays: json['totalDays'],
      currentDay: json['currentDay'],
      dailyCompletion: raw.map((k, v) => MapEntry(int.parse(k), v as bool)),
      startDate: DateTime.parse(json['startDate']),
      dailyTarget: json['dailyTarget'] ?? 1,
    );
  }
}

class PreBuiltChallenges {
  static List<ChallengeModel> get templates => [
        ChallengeModel(
          id: 'meditation_21',
          title: '21-Day Meditation',
          description: 'Build a daily meditation practice. Start with 5 minutes and grow.',
          icon: '🧘',
          totalDays: 21,
          currentDay: 0,
          dailyCompletion: {},
          startDate: DateTime.now(),
        ),
        ChallengeModel(
          id: 'reading_30',
          title: '30-Day Reading Challenge',
          description: 'Read for at least 20 minutes every day for a month.',
          icon: '📚',
          totalDays: 30,
          currentDay: 0,
          dailyCompletion: {},
          startDate: DateTime.now(),
        ),
        ChallengeModel(
          id: 'water_14',
          title: '14-Day Hydration Challenge',
          description: 'Drink 8 glasses of water every day for two weeks.',
          icon: '💧',
          totalDays: 14,
          currentDay: 0,
          dailyCompletion: {},
          startDate: DateTime.now(),
        ),
        ChallengeModel(
          id: 'exercise_30',
          title: '30-Day Exercise Challenge',
          description: 'Move your body every day for 30 days. Any exercise counts!',
          icon: '💪',
          totalDays: 30,
          currentDay: 0,
          dailyCompletion: {},
          startDate: DateTime.now(),
        ),
        ChallengeModel(
          id: 'journal_21',
          title: '21-Day Journaling',
          description: 'Write in your journal every day to build self-awareness.',
          icon: '📝',
          totalDays: 21,
          currentDay: 0,
          dailyCompletion: {},
          startDate: DateTime.now(),
        ),
        ChallengeModel(
          id: 'no_phone_7',
          title: '7-Day Digital Detox',
          description: 'No phone for the first hour after waking up.',
          icon: '📵',
          totalDays: 7,
          currentDay: 0,
          dailyCompletion: {},
          startDate: DateTime.now(),
        ),
      ];
}
