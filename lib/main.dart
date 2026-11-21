import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'app/theme/theme_notifier.dart';
import 'app/theme/theme_palette.dart';
import 'app/theme/theme_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure modern edge-to-edge transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Pre-load saved theme preset so the app and splash screen launch with the user's theme instantaneously
  ThemePreset initialPreset = AppThemePresets.defaultIndigoGradient;
  ThemeMode initialMode = ThemeMode.light;
  try {
    final savedPresetId = await ThemePreferences.getSavedPresetId();
    final savedThemeMode = await ThemePreferences.getSavedThemeMode();
    initialPreset = AppThemePresets.findById(savedPresetId);
    initialMode = savedThemeMode;
  } catch (e) {
    debugPrint('Theme pre-load warning: $e');
  }

  // Initialize Firebase with platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        initialThemePresetProvider.overrideWithValue(initialPreset),
        initialThemeModeProvider.overrideWithValue(initialMode),
      ],
      child: const LovioApp(),
    ),
  );
}
