import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _themeKey = 'quiz-app-theme';
  SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    _preferences ??= await SharedPreferences.getInstance();
    final saved = _preferences!.getString(_themeKey);
    _themeMode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await _preferences?.setString(_themeKey, isDark ? 'dark' : 'light');
    notifyListeners();
  }
}
