import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

extension BuildContextExtensions on BuildContext {
  /// Easy access to Lovio custom color palette
  LovioColors get lovioColors =>
      Theme.of(this).extension<LovioColors>() ?? LovioColors.light;

  /// Theme data
  ThemeData get theme => Theme.of(this);

  /// Color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get screenWidth => screenSize.width;

  /// Screen height
  double get screenHeight => screenSize.height;

  /// Safe area padding
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// Check if tablet or wide screen
  bool get isTablet => screenWidth >= 600;

  /// Check if desktop or ultra-wide
  bool get isDesktop => screenWidth >= 1024;
}
