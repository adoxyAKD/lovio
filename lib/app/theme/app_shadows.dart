import 'package:flutter/material.dart';

/// Lovio Design Tokens - Shadows & Elevations
class AppShadows {
  AppShadows._();

  /// Soft ambient shadow for cards
  static const List<BoxShadow> softCard = [
    BoxShadow(
      color: Color(0x0C49383B),
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0849383B),
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Floating element shadow (e.g. Floating Navigation Bar, FAB)
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1849383B),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0C49383B),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Rosy glow shadow for primary buttons & active indicators
  static const List<BoxShadow> roseGlow = [
    BoxShadow(
      color: Color(0x55EC8FA8),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  /// Lavender glow shadow
  static const List<BoxShadow> lavenderGlow = [
    BoxShadow(
      color: Color(0x44BCAEE0),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  /// Dark theme card shadow
  static const List<BoxShadow> darkCard = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
}
