import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final polishTokenProvider =
    StateNotifierProvider<PolishTokenNotifier, int>((ref) {
  return PolishTokenNotifier();
});

class PolishTokenNotifier extends StateNotifier<int> {
  PolishTokenNotifier() : super(0) {
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('ai_credits') ?? 5; // Start with 5 free credits
  }

  Future<void> addCredits(int amount) async {
    state += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ai_credits', state);
  }

  Future<bool> spendCredit() async {
    if (state > 0) {
      state -= 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ai_credits', state);
      return true;
    }
    return false;
  }
}
