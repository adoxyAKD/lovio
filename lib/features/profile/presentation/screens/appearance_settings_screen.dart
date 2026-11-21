import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_notifier.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lovio = context.lovioColors;
    final themeState = ref.watch(themeProvider);
    final currentMode = themeState.themeMode;
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Text(
          'Appearance Settings',
          style: AppTextStyles.displaySmall(color: lovio.textPrimary),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            'Display Mode',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how Lovio adapts to your environment and lighting',
            style: AppTextStyles.bodySmall(color: lovio.textSecondary),
          ),
          const SizedBox(height: 20),

          // 1. Light Mode Option Card
          _ModeSelectionCard(
            title: 'Light Mode',
            description:
                'Clean warm cream background, delicate blush accents, and high-contrast typography.',
            icon: Icons.light_mode_rounded,
            isSelected: currentMode == ThemeMode.light,
            previewWidget: const _LightModeMockup(),
            onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
          ),
          const SizedBox(height: 16),

          // 2. Dark Mode Option Card
          _ModeSelectionCard(
            title: 'Dark Mode',
            description:
                'Deep velvet surfaces, glowing pastel highlights, and comfortable low-light reading.',
            icon: Icons.dark_mode_rounded,
            isSelected: currentMode == ThemeMode.dark,
            previewWidget: const _DarkModeMockup(),
            onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: 16),

          // 3. System Default Option Card
          _ModeSelectionCard(
            title: 'System Default',
            description:
                'Automatically mirrors your operating system appearance and schedule seamlessly.',
            icon: Icons.brightness_auto_rounded,
            isSelected: currentMode == ThemeMode.system,
            previewWidget: const _SystemModeMockup(),
            onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
          ),

          const SizedBox(height: 32),

          // Shortcut to Color & Gradient Themes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: lovio.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: lovio.glow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solid & Gradient Themes',
                        style: AppTextStyles.headlineSmall(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explore 6 solid palettes and 6 animated gradients with live interactive preview.',
                        style: AppTextStyles.bodySmall(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedPressable(
                  onPressed: () => context.push(AppRoutes.themeSettings),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: lovio.accent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final Widget previewWidget;
  final VoidCallback onTap;

  const _ModeSelectionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.previewWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: lovio.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? lovio.accent : lovio.border,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected ? lovio.glow : AppShadows.softCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? lovio.accent.withOpacity(0.15)
                        : lovio.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? lovio.accent : lovio.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium(
                          color: lovio.textPrimary,
                        ),
                      ),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall(
                          color: lovio.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? lovio.accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? lovio.accent : lovio.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Mini visual representation
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: previewWidget,
            ),
          ],
        ),
      ),
    );
  }
}

class _LightModeMockup extends StatelessWidget {
  const _LightModeMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFFFFF9F5),
      child: Row(
        children: [
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF3E7EA)),
            ),
            child: const Center(
              child: Icon(Icons.favorite, size: 20, color: Color(0xFFEC8FA8)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 8,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF49383B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A777A),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEC8FA8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Love',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkModeMockup extends StatelessWidget {
  const _DarkModeMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF1A1517),
      child: Row(
        children: [
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF282023),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3D3236)),
            ),
            child: const Center(
              child: Icon(Icons.favorite, size: 20, color: Color(0xFFF6B8C8)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 8,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5A7AA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEC8FA8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Love',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemModeMockup extends StatelessWidget {
  const _SystemModeMockup();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 70,
      child: Row(
        children: [
          Expanded(child: _LightModeMockup()),
          Expanded(child: _DarkModeMockup()),
        ],
      ),
    );
  }
}

