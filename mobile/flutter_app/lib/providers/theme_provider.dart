import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

// This file was optimized
/* Possible conflicts:
1. _loadPreferences runs in the constructor but is async — the ThemeProvider constructor returns before preferences are loaded. Any widget that reads themeMode or universityCode immediately after the provider is created will get the defaults (ThemeMode.system, 'DEFAULT') until _loadPreferences completes and calls notifyListeners(). This causes a brief flash of the default theme on startup.
2. getDarkTheme() force-unwraps _cachedDark! — it calls getLightTheme() first to populate the cache, so _cachedDark should never be null here. But if AppTheme.getUniversityTheme ever throws an exception, _cachedDark stays null and the ! will crash. Wrap in a try/catch if AppTheme does any complex work.
3. toggleTheme ignores ThemeMode.system — if the current mode is ThemeMode.system, toggling switches to ThemeMode.light (not dark), which may feel wrong to users who were in system-dark mode.
4. SharedPreferences is called twice — setThemeMode and setUniversityCode each call SharedPreferences.getInstance() separately. This is fine (it's cached internally by the plugin) but if you call both rapidly in succession they each open their own instance. No real risk, just worth knowing.
5. ThemeMode.toString() is used as the persistence key — this stores strings like "ThemeMode.dark". If Flutter ever changes the toString() format of the enum (unlikely but possible in a major version), saved preferences will silently fall back to ThemeMode.system on next load.
*/

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
      _cachedLight = AppTheme.getUniversityTheme(
          code: _universityCode, isDark: false);
      _cachedDark = AppTheme.getUniversityTheme(
          code: _universityCode, isDark: true);
    }
    return _cachedLight!;
  }

  ThemeData getDarkTheme() {
    getLightTheme(); // ensures cache is populated
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
    if (_themeMode == mode) return; // no-op if unchanged
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.toString());
  }

  Future<void> setUniversityCode(String code) async {
    if (_universityCode == code) return; // no-op if unchanged
    _universityCode = code;
    _invalidateThemeCache();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUniversityKey, code);
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}