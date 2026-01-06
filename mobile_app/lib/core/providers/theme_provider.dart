import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use a FutureProvider to load the initial state
final themeInitializationProvider = FutureProvider<ThemeMode>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app-theme');
  if (savedTheme == 'light') return ThemeMode.light;
  return ThemeMode.dark; // Default to dark for "Institutional" look
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(super.initialMode);

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'app-theme', state == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  // This provider should be overridden in main.dart with the loaded value
  // or handle checking async state.
  // For simplicity after init, we default to dark if not overridden yet.
  return ThemeNotifier(ThemeMode.dark);
});
