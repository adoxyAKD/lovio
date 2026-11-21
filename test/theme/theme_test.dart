import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovio/app/theme/app_colors.dart';
import 'package:lovio/app/theme/app_theme.dart';
import 'package:lovio/app/theme/theme_notifier.dart';
import 'package:lovio/app/theme/theme_palette.dart';
import 'package:lovio/features/splash/presentation/screens/splash_screen.dart';

void main() {
  group('Lovio Design Tokens & Theme Tests', () {
    test('AppColors palette values adhere to specification', () {
      expect(AppColors.blushPink, const Color(0xFFF6B8C8));
      expect(AppColors.softLavender, const Color(0xFFDCD2F5));
      expect(AppColors.warmCream, const Color(0xFFFFF9F5));
      expect(AppColors.roseAccent, const Color(0xFFEC8FA8));
      expect(AppColors.darkBrown, const Color(0xFF49383B));
    });

    testWidgets('Light theme has correct LovioColors extension configured',
        (tester) async {
      final theme = AppTheme.lightTheme;
      final lovioColors = theme.extension<LovioColors>();

      expect(lovioColors, isNotNull);
      expect(lovioColors!.primary, const Color(0xFFEC8FA8));
      expect(lovioColors.background, AppColors.warmCream);
      expect(lovioColors.accent, const Color(0xFFE27396));
      expect(lovioColors.textPrimary, AppColors.darkBrown);
    });

    testWidgets('Dark theme has dark LovioColors extension configured',
        (tester) async {
      final theme = AppTheme.darkTheme;
      final lovioColors = theme.extension<LovioColors>();

      expect(lovioColors, isNotNull);
      expect(lovioColors!.background, AppColors.darkBackground);
      expect(theme.brightness, Brightness.dark);
    });

    test('Blue Theme (Indigo Blue) has cohesive blue-tinted background', () {
      final blueTheme = AppTheme.buildLightTheme(AppThemePresets.defaultIndigo);
      final blueColors = blueTheme.extension<LovioColors>();

      expect(blueColors, isNotNull);
      expect(blueColors!.primary, const Color(0xFF2260F2));
      expect(blueColors.background, const Color(0xFFF2F6FE));
    });

    testWidgets('SplashScreen dynamically uses gradient decoration for gradient themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialThemePresetProvider.overrideWithValue(AppThemePresets.sunsetRomanceGradient),
          ],
          child: MaterialApp(
            theme: AppTheme.buildLightTheme(AppThemePresets.sunsetRomanceGradient),
            home: const SplashScreen(),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          return box.gradient == AppThemePresets.sunsetRomanceGradient.gradient;
        }
        return false;
      });

      expect(containerFinder, findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('SplashScreen dynamically uses background color for solid themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialThemePresetProvider.overrideWithValue(AppThemePresets.emeraldRomance),
          ],
          child: MaterialApp(
            theme: AppTheme.buildLightTheme(AppThemePresets.emeraldRomance),
            home: const SplashScreen(),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          return box.color == AppThemePresets.emeraldRomance.backgroundColor;
        }
        return false;
      });

      expect(containerFinder, findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
