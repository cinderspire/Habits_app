import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/habit_provider.dart';
import '../models/challenge_model.dart';

const String _challengesKey = 'gabby_challenges';

class ChallengeNotifier extends StateNotifier<List<ChallengeModel>> {
  final SharedPreferences _prefs;

  ChallengeNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final data = _prefs.getStringList(_challengesKey);
    if (data != null && data.isNotEmpty) {
      try {
        state = data
            .map((e) => ChallengeModel.fromJson(jsonDecode(e)))
            .toList();
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _save() async {
    final data = state.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_challengesKey, data);
  }

  Future<void> joinChallenge(ChallengeModel challenge) async {
    if (state.any((c) => c.id == challenge.id)) return;
    state = [...state, challenge];
    await _save();
  }

  Future<void> completeTodayForChallenge(String challengeId) async {
    state = state.map((c) {
      if (c.id == challengeId) return c.completeToday();
      return c;
    }).toList();
    await _save();
  }

  Future<void> removeChallenge(String challengeId) async {
    state = state.where((c) => c.id != challengeId).toList();
    await _save();
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<ChallengeModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ChallengeNotifier(prefs);
});

final activeChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  return ref.watch(challengeProvider).where((c) => !c.isCompleted).toList();
});

final completedChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  return ref.watch(challengeProvider).where((c) => c.isCompleted).toList();
});
