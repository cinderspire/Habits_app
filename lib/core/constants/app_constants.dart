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
    0xFF6B7280, // Gray
  ];

  // Default Icons
  static const List<String> habitIcons = [
    '💪', // Exercise
    '📚', // Reading
    '🧘', // Meditation
    '💧', // Water
    '🏃', // Running
    '😴', // Sleep
    '🥗', // Healthy eating
    '💊', // Medication
    '📝', // Journaling
    '🎯', // Goals
    '🧹', // Cleaning
    '💰', // Saving
    '📱', // Screen time
    '🚶', // Walking
    '🎨', // Creative
    '🎵', // Music
  ];

  // Streak Milestones
  static const List<int> streakMilestones = [7, 14, 21, 30, 60, 90, 180, 365];

  // Streak Milestone Messages
  static const Map<int, String> streakMessages = {
    7: 'One week strong! 🎉',
    14: 'Two weeks! Amazing! 🌟',
    21: 'Three weeks - habit forming! 💪',
    30: 'One month milestone! 🏆',
    60: 'Two months! Incredible! 🚀',
    90: 'Three months! You\'re unstoppable! ⭐',
    180: 'Six months! True dedication! 💎',
    365: 'One year! Legendary! 👑',
  };

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
    {'name': 'Exercise', 'icon': '💪', 'color': 0xFFEF4444},
    {'name': 'Read', 'icon': '📚', 'color': 0xFF3B82F6},
    {'name': 'Meditate', 'icon': '🧘', 'color': 0xFF8B5CF6},
    {'name': 'Drink Water', 'icon': '💧', 'color': 0xFF14B8A6},
    {'name': 'Journal', 'icon': '📝', 'color': 0xFFF59E0B},
    {'name': 'Walk 10k Steps', 'icon': '🚶', 'color': 0xFF22C55E},
    {'name': 'No Social Media', 'icon': '📱', 'color': 0xFF6B7280},
    {'name': 'Healthy Meal', 'icon': '🥗', 'color': 0xFFEC4899},
  ];

  // Limits
  static const int maxHabitNameLength = 50;
  static const int maxHabits = 20;
}
