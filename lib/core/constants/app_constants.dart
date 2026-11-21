import 'package:flutter/animation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Lovio';
  static const String appTagline = 'Create. Personalize. Share Love.';

  // Animation Durations
  static const Duration durationQuick = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationPageTransition = Duration(milliseconds: 400);

  // Motion Curves
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;

  // Spacing & Radii
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusFull = 999.0;

  static const double paddingScreen = 20.0;
  static const double paddingCard = 16.0;
  static const double navBarHeight = 72.0;
}
