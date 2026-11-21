import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_palette.dart';
import 'theme_preferences.dart';

class ThemeState {
  final ThemePreset currentPreset;
  final ThemePreset previewPreset;
  final ThemeMode themeMode;
  final bool isPreviewing;

  const ThemeState({
    required this.currentPreset,
    required this.previewPreset,
    this.themeMode = ThemeMode.light,
    this.isPreviewing = false,
  });

  bool get hasUnappliedChanges => currentPreset.id != previewPreset.id;

  ThemeState copyWith({
    ThemePreset? currentPreset,
    ThemePreset? previewPreset,
    ThemeMode? themeMode,
    bool? isPreviewing,
  }) {
    return ThemeState(
      currentPreset: currentPreset ?? this.currentPreset,
      previewPreset: previewPreset ?? this.previewPreset,
      themeMode: themeMode ?? this.themeMode,
      isPreviewing: isPreviewing ?? this.isPreviewing,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier({
    ThemePreset initialPreset = AppThemePresets.defaultIndigoGradient,
    ThemeMode initialMode = ThemeMode.light,
  }) : super(
          ThemeState(
            currentPreset: initialPreset,
            previewPreset: initialPreset,
            themeMode: initialMode,
          ),
        ) {
    loadSavedTheme();
  }

  Future<void> loadSavedTheme() async {
    final presetId = await ThemePreferences.getSavedPresetId();
    final mode = await ThemePreferences.getSavedThemeMode();
    final preset = AppThemePresets.findById(presetId);

    state = state.copyWith(
      currentPreset: preset,
      previewPreset: preset,
      themeMode: mode,
      isPreviewing: false,
    );
  }

  void selectPreview(ThemePreset preset) {
    state = state.copyWith(
      previewPreset: preset,
      isPreviewing: true,
    );
  }

  void cancelPreview() {
    state = state.copyWith(
      previewPreset: state.currentPreset,
      isPreviewing: false,
    );
  }

  Future<void> applyPreview() async {
    final newPreset = state.previewPreset;
    await ThemePreferences.savePresetId(newPreset.id);
    state = state.copyWith(
      currentPreset: newPreset,
      previewPreset: newPreset,
      isPreviewing: false,
    );
  }

  Future<void> resetToDefault() async {
    const defaultPreset = AppThemePresets.defaultIndigoGradient;
    await ThemePreferences.savePresetId(defaultPreset.id);
    await ThemePreferences.saveThemeMode(ThemeMode.system);
    state = state.copyWith(
      currentPreset: defaultPreset,
      previewPreset: defaultPreset,
      themeMode: ThemeMode.system,
      isPreviewing: false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ThemePreferences.saveThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }
}

final initialThemePresetProvider = Provider<ThemePreset>((ref) {
  return AppThemePresets.defaultIndigoGradient;
});

final initialThemeModeProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.light;
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final initialPreset = ref.watch(initialThemePresetProvider);
  final initialMode = ref.watch(initialThemeModeProvider);
  return ThemeNotifier(
    initialPreset: initialPreset,
    initialMode: initialMode,
  );
});

