import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/glass_container.dart';

/// Next-Generation 2026 Floating Navigation Bar
/// Featuring:
/// - Softly elevated translucent floating pill
/// - Prominent glowing center Create (+) button
/// - Animated active tab indicator pill
/// - Smooth icon transitions and haptic feedback
class LovioBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onCreatePressed;

  const LovioBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = context.padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, bottomPadding > 0 ? bottomPadding : 16),
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Floating Translucent Pill
            Positioned.fill(
              child: GlassContainer(
                blur: 24,
                borderRadius: BorderRadius.circular(36),
                shadows: AppShadows.floating,
                color:
                    (context.isDarkMode ? AppColors.darkSurface : Colors.white)
                        .withOpacity(0.92),
                border: Border.all(
                  color: context.lovioColors.border.withOpacity(0.7),
                  width: 1.5,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Tab 0: Home (Social Feed)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: 'Home',
                          isSelected: currentIndex == 0,
                          onTap: () => _handleSelect(0),
                        ),
                      ),
                      // Tab 1: Explore (Social Discover & Inspiration)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.explore_outlined,
                          activeIcon: Icons.explore_rounded,
                          label: 'Explore',
                          isSelected: currentIndex == 1,
                          onTap: () => _handleSelect(1),
                        ),
                      ),

                      // Gap for Center Elevated Create Button
                      const SizedBox(width: 64),

                      // Tab 2: Library (Saved & Unsaved Creations)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.collections_bookmark_outlined,
                          activeIcon: Icons.collections_bookmark_rounded,
                          label: 'Library',
                          isSelected: currentIndex == 2,
                          onTap: () => _handleSelect(2),
                        ),
                      ),
                      // Tab 3: Inbox (Chats & Messaging)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          activeIcon: Icons.chat_bubble_rounded,
                          label: 'Inbox',
                          isSelected: currentIndex == 3,
                          onTap: () => _handleSelect(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Prominent Center Elevated Create (+) Button (Pushes full-screen studio without bottom nav)
            Positioned(
              top: -14,
              child: _CenterCreateButton(
                isSelected: false,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (onCreatePressed != null) {
                    onCreatePressed!();
                  } else {
                    context.push(AppRoutes.create);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelect(int index) {
    HapticFeedback.selectionClick();
    onTabSelected(index);
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      scaleDown: 0.9,
      enableHaptics: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? lovio.accent.withOpacity(0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? lovio.accent : lovio.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.labelSmall(
              color: isSelected ? lovio.accent : lovio.textMuted,
            ).copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
            ),
            child: Text(label),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? 4 : 0,
            height: isSelected ? 4 : 0,
            decoration: BoxDecoration(
              color: isSelected ? lovio.accent : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterCreateButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterCreateButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      scaleDown: 0.92,
      enableHaptics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: lovio.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: lovio.primary.withOpacity(isSelected ? 0.6 : 0.45),
              blurRadius: isSelected ? 20 : 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: AnimatedRotation(
          turns: isSelected ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
