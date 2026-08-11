import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/themedata.dart';

/// Manages dark / light mode with persistence via SharedPreferences.
/// Also flips the [AppColors.isDark] flag so all `static get` tokens react.
class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'roomiesync_is_dark';

  bool _isDark = true;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefsKey) ?? true;
    AppColors.isDark = _isDark;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    AppColors.isDark = _isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, _isDark);
    notifyListeners();
  }
}