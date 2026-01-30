// App Constants for Habitly Habit Tracker
class AppConstants {
  // App Info
  static const String appName = 'Habitly';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Build Better Habits';

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyHabits = 'habits';
  static const String keyCompletions = 'completions';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyDarkMode = 'habitly_theme_mode';

  // Habit Frequencies
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyCustom = 'custom';

  // Default Colors
  static const List<int> habitColors = [
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFFEF4444, // Red
    0xFFF59E0B, // Amber
    0xFF22C55E, // Green
    0xFF14B8A6, // Teal
    0xFF3B82F6, // Blue
  ];

  // Default Icons
  static const List<String> habitIcons = [
    '\u{1F4AA}', // Exercise
    '\u{1F4DA}', // Reading
    '\u{1F9D8}', // Meditation
    '\u{1F4A7}', // Water
    '\u{1F3C3}', // Running
    '\u{1F634}', // Sleep
    '\u{1F957}', // Healthy eating
    '\u{1F48A}', // Medication
    '\u{1F4DD}', // Journaling
    '\u{1F3AF}', // Goals
    '\u{1F9F9}', // Cleaning
    '\u{1F4B0}', // Saving
    '\u{1F4F1}', // Screen time
    '\u{1F6B6}', // Walking
    '\u{1F3A8}', // Creative
    '\u{1F3B5}', // Music
    '\u{2615}', // Coffee
    '\u{1F34E}', // Apple/Fruit
    '\u{1F4A4}', // Sleep zzz
    '\u{1F30D}', // Globe/Environment
  ];

  // Streak Milestones
  static const List<int> streakMilestones = [7, 14, 21, 30, 60, 90, 180, 365];

  // Streak Milestone Messages
  static const Map<int, String> streakMessages = {
    7: 'One week strong!',
    14: 'Two weeks! Amazing!',
    21: 'Three weeks - habit forming!',
    30: 'One month milestone!',
    60: 'Two months! Incredible!',
    90: 'Three months! You\'re unstoppable!',
    180: 'Six months! True dedication!',
    365: 'One year! Legendary!',
  };

  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    'Small daily improvements lead to stunning results.',
    'The secret of getting ahead is getting started.',
    'Motivation gets you going, habit keeps you growing.',
    'Success is the sum of small efforts repeated daily.',
    'You don\'t have to be great to start, but you have to start to be great.',
    'Every day is a chance to get a little better.',
    'Consistency is what transforms average into excellence.',
    'The only bad habit is no habit at all.',
    'Progress, not perfection.',
    'Discipline is choosing what you want most over what you want now.',
    'Your habits shape your future.',
    'One day or day one. You decide.',
    'A journey of a thousand miles begins with a single step.',
    'Be stronger than your excuses.',
    'The best time to start was yesterday. The next best time is now.',
  ];

  // Time Periods
  static const List<String> reminderTimes = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '12:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  // Suggested Habits
  static const List<Map<String, dynamic>> suggestedHabits = [
    {'name': 'Exercise', 'icon': '\u{1F4AA}', 'color': 0xFFEF4444},
    {'name': 'Read', 'icon': '\u{1F4DA}', 'color': 0xFF3B82F6},
    {'name': 'Meditate', 'icon': '\u{1F9D8}', 'color': 0xFF8B5CF6},
    {'name': 'Drink Water', 'icon': '\u{1F4A7}', 'color': 0xFF14B8A6},
    {'name': 'Journal', 'icon': '\u{1F4DD}', 'color': 0xFFF59E0B},
    {'name': 'Walk 10k Steps', 'icon': '\u{1F6B6}', 'color': 0xFF22C55E},
    {'name': 'No Social Media', 'icon': '\u{1F4F1}', 'color': 0xFF6B7280},
    {'name': 'Healthy Meal', 'icon': '\u{1F957}', 'color': 0xFFEC4899},
  ];

  // Weekday names
  static const List<String> weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  // Limits
  static const int maxHabitNameLength = 50;
  static const int maxHabits = 20;
}
