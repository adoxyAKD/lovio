import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_notifier.dart';
import '../../../../app/theme/theme_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lovio = context.lovioColors;
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final activePreview = themeState.previewPreset;

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Text(
          'Theme Settings',
          style: AppTextStyles.displaySmall(color: lovio.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await themeNotifier.resetToDefault();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme reset to default Lovio Blue (#2260F2) ✨'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Reset',
              style: AppTextStyles.labelLarge(color: lovio.accent),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // 1. Live Interactive Mini App Preview
          Text(
            'Live Theme Preview',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Interactive visual demonstration of how Lovio looks with this theme',
            style: AppTextStyles.bodySmall(color: lovio.textSecondary),
          ),
          const SizedBox(height: 14),

          _LiveMiniAppPreview(preset: activePreview),

          const SizedBox(height: 16),

          // Apply / Cancel Bar
          if (themeState.hasUnappliedChanges)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.softCard,
                border: Border.all(color: activePreview.primaryColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Previewing: ${activePreview.name}',
                          style: AppTextStyles.titleSmall(
                              color: lovio.textPrimary),
                        ),
                        Text(
                          'Tap Apply to save as your theme',
                          style: AppTextStyles.labelSmall(
                              color: lovio.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => themeNotifier.cancelPreview(),
                    child: Text(
                      'Discard',
                      style: AppTextStyles.labelMedium(color: lovio.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedPressable(
                    onPressed: () async {
                      await themeNotifier.applyPreview();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Applied "${activePreview.name}" across Lovio! ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: activePreview.gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: activePreview.primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Apply Theme',
                        style: AppTextStyles.labelMedium(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Appearance Mode (Light / Dark / System)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.brightness_medium_rounded,
                        color: lovio.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Appearance Mode',
                      style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 18),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 18),
                        label: Text('Dark'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_suggest_rounded, size: 18),
                        label: Text('System'),
                      ),
                    ],
                    selected: {themeState.themeMode},
                    onSelectionChanged: (newSelection) {
                      themeNotifier.setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Solid Color Themes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solid Color Themes',
                style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lovio.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${AppThemePresets.solidThemes.length} Themes',
                  style: AppTextStyles.labelSmall(color: lovio.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Clean, bold colors applied to primary buttons, highlights & accents',
            style: AppTextStyles.bodySmall(color: lovio.textSecondary),
          ),
          const SizedBox(height: 14),

          ...AppThemePresets.solidThemes.map((preset) {
            final isCurrent = themeState.currentPreset.id == preset.id;
            final isPreviewingThis = activePreview.id == preset.id;

            return _ThemePresetCard(
              preset: preset,
              isCurrent: isCurrent,
              isSelected: isPreviewingThis,
              onTap: () => themeNotifier.selectPreview(preset),
            );
          }),

          const SizedBox(height: 28),

          // 3. Gradient Themes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gradient Themes',
                style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lovio.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${AppThemePresets.gradientThemes.length} Gradients',
                  style: AppTextStyles.labelSmall(color: lovio.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Multi-color blended gradients for hero cards, buttons & vibrant backgrounds',
            style: AppTextStyles.bodySmall(color: lovio.textSecondary),
          ),
          const SizedBox(height: 14),

          ...AppThemePresets.gradientThemes.map((preset) {
            final isCurrent = themeState.currentPreset.id == preset.id;
            final isPreviewingThis = activePreview.id == preset.id;

            return _ThemePresetCard(
              preset: preset,
              isCurrent: isCurrent,
              isSelected: isPreviewingThis,
              onTap: () => themeNotifier.selectPreview(preset),
            );
          }),
        ],
      ),
    );
  }
}

class _LiveMiniAppPreview extends StatelessWidget {
  final ThemePreset preset;

  const _LiveMiniAppPreview({required this.preset});

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Container(
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.floating,
        border: Border.all(color: preset.primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          // Mini Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: preset.primaryColor.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: preset.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Lovio Preview',
                  style: AppTextStyles.titleSmall(color: lovio.textPrimary),
                ),
                const Spacer(),
                Icon(Icons.search_rounded,
                    size: 16, color: preset.primaryColor),
                const SizedBox(width: 10),
                Icon(Icons.favorite_rounded,
                    size: 16, color: preset.accentColor),
              ],
            ),
          ),

          // Mini Content Card
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Sample Gradient/Colored Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: preset.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: preset.primaryColor.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Love Story',
                              style: AppTextStyles.titleMedium(
                                  color: Colors.white),
                            ),
                            Text(
                              'Animated storybook page with dynamic petals',
                              style: AppTextStyles.bodySmall(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Sample Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: preset.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Primary Button',
                            style: AppTextStyles.labelSmall(
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: preset.secondaryColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: preset.primaryColor.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'Secondary Action',
                            style: AppTextStyles.labelSmall(
                                color: lovio.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mini Nav Bar representation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(22)),
              border: Border(top: BorderSide(color: lovio.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home_rounded, size: 18, color: preset.primaryColor),
                Icon(Icons.auto_stories_rounded,
                    size: 18, color: lovio.textMuted),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: preset.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded,
                      size: 14, color: Colors.white),
                ),
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: lovio.textMuted),
                Icon(Icons.person_outline_rounded,
                    size: 18, color: lovio.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePresetCard extends StatelessWidget {
  final ThemePreset preset;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePresetCard({
    required this.preset,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: lovio.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? preset.primaryColor : lovio.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: preset.primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppShadows.softCard,
        ),
        child: Row(
          children: [
            // Color Swatch
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: preset.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: preset.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check_rounded,
                          color: Colors.white, size: 22),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Theme Name & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          preset.name,
                          style: AppTextStyles.titleMedium(
                              color: lovio.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (preset.id == 'indigo_gradient_default' ||
                          preset.id == 'indigo_blue') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2260F2).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF2260F2).withOpacity(0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '#2260F2',
                            style: AppTextStyles.labelSmall(
                              color: const Color(0xFF2260F2),
                            ),
                          ),
                        ),
                      ],
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyles.labelSmall(
                                color: AppColors.success),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.isGradient ? 'Gradient Blend' : 'Solid Accent',
                    style: AppTextStyles.bodySmall(
                        color: lovio.textSecondary),
                  ),
                ],
              ),
            ),

            // Color Palette Circles
            Row(
              children: [
                _PaletteDot(color: preset.primaryColor),
                const SizedBox(width: 4),
                _PaletteDot(color: preset.accentColor),
                const SizedBox(width: 4),
                _PaletteDot(color: preset.secondaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  final Color color;

  const _PaletteDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

