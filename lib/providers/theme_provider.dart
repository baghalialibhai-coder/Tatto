// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    } catch (e) {
      // Handle error
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Provider to check if dark mode is enabled
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider) == ThemeMode.dark;
});