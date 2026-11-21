import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Lovio Design Tokens - Typography
/// Headings: Playfair Display
/// General UI: Poppins
/// Expressive / Handwritten: Caveat
class AppTextStyles {
  AppTextStyles._();

  // Headings - Playfair Display
  static TextStyle displayLarge({Color color = AppColors.darkBrown}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayMedium({Color color = AppColors.darkBrown}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle displaySmall({Color color = AppColors.darkBrown}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle headlineLarge({Color color = AppColors.darkBrown}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle headlineMedium({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle headlineSmall({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // Body & UI - Poppins
  static TextStyle titleLarge({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle titleMedium({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle titleSmall({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyLarge({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.textMuted}) =>
      GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle labelLarge({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.3,
        color: color,
      );

  static TextStyle labelMedium({Color color = AppColors.darkBrown}) =>
      GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.3,
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.textMuted}) =>
      GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.3,
        color: color,
      );

  // Expressive Handwritten - Caveat
  static TextStyle handwrittenLarge({Color color = AppColors.roseAccent}) =>
      GoogleFonts.caveat(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color,
      );

  static TextStyle handwrittenMedium({Color color = AppColors.roseAccent}) =>
      GoogleFonts.caveat(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );
}
