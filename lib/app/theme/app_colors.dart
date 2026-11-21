import 'package:flutter/material.dart';
import 'theme_palette.dart';

/// Lovio Design Tokens - Color Palette
///
/// Palette specification:
/// - Primary (Blush Pink): #F6B8C8
/// - Secondary (Soft Lavender): #DCD2F5
/// - Background (Warm Cream): #FFF9F5
/// - Accent (Rose Pink): #EC8FA8
/// - Text (Dark Brown): #49383B
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color blushPink = Color(0xFFF6B8C8);
  static const Color softLavender = Color(0xFFDCD2F5);
  static const Color warmCream = Color(0xFFFFF9F5);
  static const Color roseAccent = Color(0xFFEC8FA8);
  static const Color darkBrown = Color(0xFF49383B);

  // Extended Tones - Light
  static const Color blushPinkLight = Color(0xFFFDF0F3);
  static const Color blushPinkDark = Color(0xFFE291A7);
  static const Color softLavenderLight = Color(0xFFF4F0FC);
  static const Color softLavenderDark = Color(0xFFBCAEE0);
  static const Color warmCreamAlt = Color(0xFFFAF3EC);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F1EE);
  static const Color textMuted = Color(0xFF867276);
  static const Color textLight = Color(0xFFAFA3A6);
  static const Color borderLight = Color(0xFFF0E5E2);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF1E1719);
  static const Color darkSurface = Color(0xFF282023);
  static const Color darkSurfaceCard = Color(0xFF332A2E);
  static const Color darkTextPrimary = Color(0xFFFFF4EE);
  static const Color darkTextSecondary = Color(0xFFD4C7C9);
  static const Color darkTextMuted = Color(0xFF9F8F92);
  static const Color darkBorder = Color(0xFF3F3438);

  // Functional Colors
  static const Color success = Color(0xFF7CB88F);
  static const Color error = Color(0xFFE56969);
  static const Color warning = Color(0xFFF5B061);
  static const Color info = Color(0xFF74A8DE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2260F2), Color(0xFF0D3299)],
  );

  static const LinearGradient lavenderBlushGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softLavender, blushPink],
  );

  static const LinearGradient sunsetLoveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blushPink, Color(0xFFFCE2CE), softLavender],
  );

  static const LinearGradient emeraldRomanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2EC4B6), Color(0xFFCBF3F0)],
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x99FFFFFF),
      Color(0x4DFFFFFF),
    ],
  );

  static const LinearGradient darkCardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4044373C),
      Color(0x20352A2E),
    ],
  );

  static const LinearGradient heroGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33F6B8C8),
      Color(0x00FFF9F5),
    ],
  );
}

/// Custom Theme Extension for Lovio tokens
class LovioColors extends ThemeExtension<LovioColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceCard;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient cardGlassGradient;
  final List<BoxShadow> glow;

  const LovioColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceCard,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.cardGlassGradient,
    required this.glow,
  });

  static const light = LovioColors(
    primary: Color(0xFF2260F2),
    secondary: Color(0xFF6B93F8),
    background: Color(0xFFF2F6FE),
    surface: AppColors.pureWhite,
    surfaceCard: Color(0xFFEEF3FF),
    accent: Color(0xFF1042B8),
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2260F2), Color(0xFF0D3299)],
    ),
    secondaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6B93F8), Color(0xFF2260F2)],
    ),
    cardGlassGradient: AppColors.cardGlassGradient,
    glow: [
      BoxShadow(
        color: Color(0x4D2260F2),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const dark = LovioColors(
    primary: Color(0xFF2260F2),
    secondary: Color(0xFF6B93F8),
    background: Color(0xFF070B19),
    surface: Color(0xFF10162F),
    surfaceCard: Color(0xFF182042),
    accent: Color(0xFF6B93F8),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    border: Color(0xFF253158),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2260F2), Color(0xFF0D3299)],
    ),
    secondaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6B93F8), Color(0xFF2260F2)],
    ),
    cardGlassGradient: AppColors.darkCardGlassGradient,
    glow: [
      BoxShadow(
        color: Color(0x602260F2),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  factory LovioColors.fromPreset(ThemePreset preset, {bool isDark = false}) {
    final glow = [
      BoxShadow(
        color: preset.primaryColor.withOpacity(isDark ? 0.45 : 0.32),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
    final secGradient = LinearGradient(
      colors: [preset.secondaryColor, preset.primaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    if (isDark) {
      return LovioColors(
        primary: preset.primaryColor,
        secondary: preset.secondaryColor,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceCard: AppColors.darkSurfaceCard,
        accent: preset.accentColor,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        textMuted: AppColors.darkTextMuted,
        border: AppColors.darkBorder,
        primaryGradient: preset.gradient,
        secondaryGradient: secGradient,
        cardGlassGradient: AppColors.darkCardGlassGradient,
        glow: glow,
      );
    }
    return LovioColors(
      primary: preset.primaryColor,
      secondary: preset.secondaryColor,
      background: preset.backgroundColor,
      surface: AppColors.pureWhite,
      surfaceCard: AppColors.surfaceMuted,
      accent: preset.accentColor,
      textPrimary: AppColors.darkBrown,
      textSecondary: AppColors.textMuted,
      textMuted: AppColors.textLight,
      border: AppColors.borderLight,
      primaryGradient: preset.gradient,
      secondaryGradient: secGradient,
      cardGlassGradient: AppColors.cardGlassGradient,
      glow: glow,
    );
  }

  @override
  ThemeExtension<LovioColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceCard,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? cardGlassGradient,
    List<BoxShadow>? glow,
  }) {
    return LovioColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      cardGlassGradient: cardGlassGradient ?? this.cardGlassGradient,
      glow: glow ?? this.glow,
    );
  }

  @override
  ThemeExtension<LovioColors> lerp(
    covariant ThemeExtension<LovioColors>? other,
    double t,
  ) {
    if (other is! LovioColors) return this;
    return LovioColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t) ?? surfaceCard,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      primaryGradient:
          LinearGradient.lerp(primaryGradient, other.primaryGradient, t) ??
              primaryGradient,
      secondaryGradient:
          LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t) ??
              secondaryGradient,
      cardGlassGradient:
          LinearGradient.lerp(cardGlassGradient, other.cardGlassGradient, t) ??
              cardGlassGradient,
      glow: other.glow,
    );
  }
}
