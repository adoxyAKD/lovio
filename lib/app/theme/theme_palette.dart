import 'package:flutter/material.dart';

enum ThemeType { solid, gradient }

/// Definition of a custom Lovio Theme Preset
class ThemePreset {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final LinearGradient gradient;
  final ThemeType type;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.backgroundColor = const Color(0xFFFFF9F5),
    required this.gradient,
    this.type = ThemeType.solid,
  });

  bool get isGradient => type == ThemeType.gradient;
}

class AppThemePresets {
  AppThemePresets._();

  // 1. Primary Default Theme: Lovio Blue (#2260F2) Gradient
  static const ThemePreset defaultIndigoGradient = ThemePreset(
    id: 'indigo_gradient_default',
    name: 'Lovio Blue Gradient (Default)',
    primaryColor: Color(0xFF2260F2),
    secondaryColor: Color(0xFF6B93F8),
    accentColor: Color(0xFF0D3299),
    backgroundColor: Color(0xFFF2F6FE),
    gradient: LinearGradient(
      colors: [Color(0xFF2260F2), Color(0xFF0D3299)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  // 2. Solid Color Themes
  static const ThemePreset defaultIndigo = ThemePreset(
    id: 'indigo_blue',
    name: 'Lovio Blue (Solid)',
    primaryColor: Color(0xFF2260F2),
    secondaryColor: Color(0xFFBFDBFE),
    accentColor: Color(0xFF1042B8),
    backgroundColor: Color(0xFFF2F6FE),
    gradient: LinearGradient(
      colors: [Color(0xFF2260F2), Color(0xFF1042B8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const ThemePreset defaultBlushRomance = ThemePreset(
    id: 'blush_default',
    name: 'Lovio Romance',
    primaryColor: Color(0xFFEC8FA8),
    secondaryColor: Color(0xFFDCD2F5),
    accentColor: Color(0xFFE27396),
    backgroundColor: Color(0xFFFFF9F5),
    gradient: LinearGradient(
      colors: [Color(0xFFF6B8C8), Color(0xFFEC8FA8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const ThemePreset blushRose = ThemePreset(
    id: 'blush_rose',
    name: 'Blush Rose',
    primaryColor: Color(0xFFF72585),
    secondaryColor: Color(0xFFFBCFE8),
    accentColor: Color(0xFFEC4899),
    backgroundColor: Color(0xFFFFF1F6),
    gradient: LinearGradient(
      colors: [Color(0xFFF72585), Color(0xFFEC4899)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const ThemePreset royalViolet = ThemePreset(
    id: 'royal_violet',
    name: 'Royal Violet',
    primaryColor: Color(0xFF7209B7),
    secondaryColor: Color(0xFFDDD6FE),
    accentColor: Color(0xFF8B5CF6),
    backgroundColor: Color(0xFFF8F5FF),
    gradient: LinearGradient(
      colors: [Color(0xFF7209B7), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const ThemePreset emeraldRomance = ThemePreset(
    id: 'emerald_romance',
    name: 'Emerald Romance',
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFFA7F3D0),
    accentColor: Color(0xFF059669),
    backgroundColor: Color(0xFFF0FDF8),
    gradient: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const ThemePreset sunsetCoral = ThemePreset(
    id: 'sunset_coral',
    name: 'Sunset Coral',
    primaryColor: Color(0xFFF97316),
    secondaryColor: Color(0xFFFED7AA),
    accentColor: Color(0xFFEA580C),
    backgroundColor: Color(0xFFFFF7ED),
    gradient: LinearGradient(
      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const ThemePreset midnightVelvet = ThemePreset(
    id: 'midnight_velvet',
    name: 'Midnight Velvet',
    primaryColor: Color(0xFF4F46E5),
    secondaryColor: Color(0xFFC7D2FE),
    accentColor: Color(0xFF4338CA),
    backgroundColor: Color(0xFFF4F3FF),
    gradient: LinearGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.solid,
  );

  static const List<ThemePreset> solidThemes = [
    defaultBlushRomance,
    defaultIndigo,
    blushRose,
    royalViolet,
    emeraldRomance,
    sunsetCoral,
    midnightVelvet,
  ];

  // 2. Gradient Themes
  static const ThemePreset sunsetRomanceGradient = ThemePreset(
    id: 'sunset_romance',
    name: 'Sunset Romance',
    primaryColor: Color(0xFF2260F2),
    secondaryColor: Color(0xFFFBCFE8),
    accentColor: Color(0xFFF72585),
    backgroundColor: Color(0xFFFAF5FF),
    gradient: LinearGradient(
      colors: [Color(0xFF2260F2), Color(0xFFF72585)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  static const ThemePreset auroraLoveGradient = ThemePreset(
    id: 'aurora_love',
    name: 'Aurora Love',
    primaryColor: Color(0xFF7209B7),
    secondaryColor: Color(0xFFFCE7F3),
    accentColor: Color(0xFFEC4899),
    backgroundColor: Color(0xFFFDF4FA),
    gradient: LinearGradient(
      colors: [Color(0xFF7209B7), Color(0xFFEC4899)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  static const ThemePreset oceanBreezeGradient = ThemePreset(
    id: 'ocean_breeze',
    name: 'Ocean Breeze',
    primaryColor: Color(0xFF0284C7),
    secondaryColor: Color(0xFFBAE6FD),
    accentColor: Color(0xFF2260F2),
    backgroundColor: Color(0xFFF0F9FF),
    gradient: LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFF2260F2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  static const ThemePreset goldenHourGradient = ThemePreset(
    id: 'golden_hour',
    name: 'Golden Hour',
    primaryColor: Color(0xFFEA580C),
    secondaryColor: Color(0xFFFEF3C7),
    accentColor: Color(0xFFE11D48),
    backgroundColor: Color(0xFFFFFBEB),
    gradient: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFE11D48)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  static const ThemePreset mysticLavenderGradient = ThemePreset(
    id: 'mystic_lavender',
    name: 'Mystic Lavender',
    primaryColor: Color(0xFF8B5CF6),
    secondaryColor: Color(0xFFEDE9FE),
    accentColor: Color(0xFF4895EF),
    backgroundColor: Color(0xFFFAF7FF),
    gradient: LinearGradient(
      colors: [Color(0xFFB5179E), Color(0xFF4895EF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  static const ThemePreset emeraldGlowGradient = ThemePreset(
    id: 'emerald_glow',
    name: 'Emerald Glow',
    primaryColor: Color(0xFF059669),
    secondaryColor: Color(0xFFD1FAE5),
    accentColor: Color(0xFF10B981),
    backgroundColor: Color(0xFFF0FDF5),
    gradient: LinearGradient(
      colors: [Color(0xFF0D9488), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    type: ThemeType.gradient,
  );

  static const List<ThemePreset> gradientThemes = [
    defaultIndigoGradient,
    sunsetRomanceGradient,
    auroraLoveGradient,
    oceanBreezeGradient,
    goldenHourGradient,
    mysticLavenderGradient,
    emeraldGlowGradient,
  ];

  static ThemePreset findById(String id) {
    if (id == 'indigo_gradient_default' ||
        id == 'indigo_default' ||
        id == 'blush_default' ||
        id.isEmpty) {
      return defaultIndigoGradient;
    }
    for (final preset in [...gradientThemes, ...solidThemes]) {
      if (preset.id == id) return preset;
    }
    return defaultIndigoGradient;
  }
}

