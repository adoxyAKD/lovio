import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _keyPresetId = 'lovio_theme_preset_id';
  static const String _keyThemeMode = 'lovio_theme_mode';

  static Future<String> getSavedPresetId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_keyPresetId);
      if (id == null || id == 'blush_default' || id == 'indigo_default') {
        return 'indigo_gradient_default';
      }
      return id;
    } catch (_) {
      return 'indigo_gradient_default';
    }
  }

  static Future<void> savePresetId(String presetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPresetId, presetId);
    } catch (_) {}
  }

  static Future<ThemeMode> getSavedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_keyThemeMode);
      switch (modeStr) {
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        case 'light':
        default:
          return ThemeMode.light;
      }
    } catch (_) {
      return ThemeMode.light;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, mode.name);
    } catch (_) {}
  }
}

