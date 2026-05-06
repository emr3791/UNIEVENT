import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

// This file was modified but wasn't fully revised

class ThemeProvider with ChangeNotifier {
  static const _kThemeModeKey = 'theme_mode';
  static const _kUniversityKey = 'university_code';

  ThemeMode _themeMode = ThemeMode.system;
  String _universityCode = 'DEFAULT';

  ThemeData? _cachedLight;
  ThemeData? _cachedDark;
  String? _cachedCode;

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  String get universityCode => _universityCode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeData getLightTheme() {
    if (_cachedCode != _universityCode || _cachedLight == null) {
      _cachedCode = _universityCode;
      _cachedLight = AppTheme.getUniversityTheme(code: _universityCode, isDark: false);
      _cachedDark  = AppTheme.getUniversityTheme(code: _universityCode, isDark: true);
    }
    return _cachedLight!;
  }

  ThemeData getDarkTheme() {
    getLightTheme();
    return _cachedDark!;
  }

  void _invalidateThemeCache() {
    _cachedCode = null;
    _cachedLight = null;
    _cachedDark = null;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_kThemeModeKey);
    if (storedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (mode) => mode.toString() == storedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    final storedUni = prefs.getString(_kUniversityKey);
    if (storedUni != null) {
      _universityCode = storedUni;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.toString());
  }

  Future<void> setUniversityCode(String code) async {
    if (_universityCode == code) return;
    _universityCode = code;
    _invalidateThemeCache();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUniversityKey, code);
  }

  void toggleTheme() {
    setThemeMode(
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}