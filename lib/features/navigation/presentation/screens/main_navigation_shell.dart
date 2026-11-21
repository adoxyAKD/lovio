import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../widgets/lovio_bottom_nav_bar.dart';

/// Main navigation shell housing the 5 core tabs with a floating bottom navigation bar
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: lovio.background,
      body: Stack(
        children: [
          // Ambient pastel background atmosphere
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                  colors: isDark
                      ? [
                          AppColors.darkBackground,
                          AppColors.darkSurface,
                          AppColors.darkBackground,
                        ]
                      : [
                          lovio.primary.withOpacity(0.14),
                          lovio.secondary.withOpacity(0.10),
                          lovio.background,
                        ],
                ),
              ),
            ),
          ),

          // Primary Content
          Positioned.fill(
            child: navigationShell,
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LovioBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTabSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
