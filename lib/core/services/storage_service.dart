import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

/// Hive-style persistence layer built on SharedPreferences.
/// Manages all habit data storage and retrieval operations.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _habitsKey = 'habitly_habits';
  static const String _themeKey = 'habitly_theme_mode';
  static const String _firstLaunchKey = 'habitly_first_launch';

  // ---------- Habits ----------

  List<Habit> loadHabits() {
    final raw = _prefs.getString(_habitsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Habit.decode(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    await _prefs.setString(_habitsKey, Habit.encode(habits));
  }

  Future<void> addHabit(Habit habit) async {
    final habits = loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit updated) async {
    final habits = loadHabits();
    final index = habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      habits[index] = updated;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String id) async {
    final habits = loadHabits();
    habits.removeWhere((h) => h.id == id);
    await saveHabits(habits);
  }

  // ---------- Theme ----------

  bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_themeKey, value);
  }

  // ---------- First Launch ----------

  bool get isFirstLaunch => _prefs.getBool(_firstLaunchKey) ?? true;

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(_firstLaunchKey, false);
  }

  // ---------- Export ----------

  String exportAllData() {
    final habits = loadHabits();
    final exportData = {
      'app': 'Habitly',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  // ---------- Clear ----------

  Future<void> clearAllData() async {
    await _prefs.remove(_habitsKey);
  }
}
