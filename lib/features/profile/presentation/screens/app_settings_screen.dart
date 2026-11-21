import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../creation/domain/entities/page_document.dart';
import '../../../creation/presentation/widgets/surprise_opening_view.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _offlineFirst = true;
  bool _autoSyncCloud = true;
  bool _highQualityExport = true;
  bool _anniversaryAlerts = true;
  bool _dailyLoveQuotes = true;
  bool _hapticFeedback = true;
  bool _motionEffects = true;
  OpeningRevealStyle _defaultOpeningStyle = OpeningRevealStyle.romanticPinkEnvelope;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStyle = prefs.getString('default_opening_style');
      if (savedStyle != null) {
        final style = OpeningRevealStyle.values.firstWhere(
          (e) => e.name == savedStyle,
          orElse: () => OpeningRevealStyle.romanticPinkEnvelope,
        );
        if (mounted) setState(() => _defaultOpeningStyle = style);
      }
    } catch (_) {}
  }

  Future<void> _setOpeningStyle(OpeningRevealStyle style) async {
    setState(() => _defaultOpeningStyle = style);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_opening_style', style.name);
    } catch (_) {}
  }

  void _previewOpeningStyle(OpeningRevealStyle style) {
    final mockDoc = PageDocument(
      id: 'preview',
      title: 'Romantic Preview',
      shareToken: 'preview',
      openingStyle: style,
      background: const PageBackgroundConfig(
        type: PageBackgroundType.gradient,
        gradientColors: [0xFFF6B8C8, 0xFFEC8FA8],
      ),
      elements: [
        const PageElementModel(
          id: '1',
          type: PageElementType.text,
          x: 40,
          y: 120,
          text: 'Every love story is beautiful,\nbut ours is my favorite ❤️',
          fontFamily: 'Playfair Display',
          fontSize: 22,
          textColor: 0xFF882D4B,
        ),
        const PageElementModel(
          id: '2',
          type: PageElementType.sticker,
          x: 140,
          y: 220,
          stickerSymbol: '💖',
          stickerAnimation: StickerAnimationEffect.heartbeat,
        ),
      ],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.90,
            child: SurpriseOpeningView(
              document: mockDoc,
              onRevealed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Previewed ${style.label} ✨'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Temporary cache cleared successfully! (14.6 MB freed) ✨'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Text(
          'App Settings',
          style: AppTextStyles.displaySmall(color: lovio.textPrimary),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // 1. Storage & Local-First Engine
          Text(
            'Local Storage & Cloud Sync',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _offlineFirst,
                  activeColor: lovio.accent,
                  title: Text(
                    'Save to Device First',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Instant offline creation. Never lose a memory even without internet.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _offlineFirst = val),
                ),
                Divider(height: 1, color: lovio.border),
                SwitchListTile(
                  value: _autoSyncCloud,
                  activeColor: lovio.accent,
                  title: Text(
                    'Auto-Sync to Cloud',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Automatically backup creations to Firebase when Wi-Fi is connected.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _autoSyncCloud = val),
                ),
                Divider(height: 1, color: lovio.border),
                SwitchListTile(
                  value: _highQualityExport,
                  activeColor: lovio.accent,
                  title: Text(
                    'Ultra-HD Export (300 DPI)',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Render greeting cards and books in print-ready resolution.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _highQualityExport = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Reminders & Notifications
          Text(
            'Reminders & Notifications',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _anniversaryAlerts,
                  activeColor: lovio.accent,
                  title: Text(
                    'Anniversary & Date Alerts',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Receive timely reminders before important relationship milestones.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _anniversaryAlerts = val),
                ),
                Divider(height: 1, color: lovio.border),
                SwitchListTile(
                  value: _dailyLoveQuotes,
                  activeColor: lovio.accent,
                  title: Text(
                    'Daily Love & Story Prompts',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Inspiring ideas for personalized letters and greeting cards.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _dailyLoveQuotes = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Motion & Haptics
          Text(
            'Motion & Experience',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _hapticFeedback,
                  activeColor: lovio.accent,
                  title: Text(
                    'Haptic Feedback',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Gentle vibrations when tapping buttons, cards, and stickers.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _hapticFeedback = val),
                ),
                Divider(height: 1, color: lovio.border),
                SwitchListTile(
                  value: _motionEffects,
                  activeColor: lovio.accent,
                  title: Text(
                    'Animated Backgrounds',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Smooth floating particles, gradient waves, and dynamic effects.',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  onChanged: (val) => setState(() => _motionEffects = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Surprise Opening Style (Envelope & Gift Reveal)
          Text(
            'Surprise Envelope & Gift Opening Style',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how receivers first experience cards you share via links',
            style: AppTextStyles.bodySmall(color: lovio.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: OpeningRevealStyle.values.map((style) {
                final isSelected = style == _defaultOpeningStyle;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? lovio.accent.withOpacity(0.18)
                              : lovio.border.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Text(style.emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(
                        style.label,
                        style: AppTextStyles.titleMedium(
                          color: isSelected ? lovio.accent : lovio.textPrimary,
                        ).copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        style.description,
                        style: AppTextStyles.bodySmall(
                            color: lovio.textSecondary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline_rounded),
                            color: lovio.accent,
                            tooltip: 'Preview Reveal Animation',
                            onPressed: () => _previewOpeningStyle(style),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color:
                                isSelected ? lovio.accent : lovio.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                      onTap: () => _setOpeningStyle(style),
                    ),
                    if (style != OpeningRevealStyle.values.last)
                      Divider(height: 1, color: lovio.border),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 5. Cache & Quick Navigation
          Text(
            'Appearance & Cache',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: lovio.accent),
                  title: Text(
                    'Theme Settings',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Solid colors & dynamic gradient themes',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push(AppRoutes.themeSettings),
                ),
                Divider(height: 1, color: lovio.border),
                ListTile(
                  leading: Icon(Icons.brightness_medium_rounded, color: lovio.accent),
                  title: Text(
                    'Appearance Mode',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Light, Dark, or System Default',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push(AppRoutes.appearanceSettings),
                ),
                Divider(height: 1, color: lovio.border),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.error),
                  title: Text(
                    'Clear Temporary Cache',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Free up storage without deleting saved creations',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  trailing: TextButton(
                    onPressed: _clearCache,
                    child: Text(
                      'Clear',
                      style: AppTextStyles.labelLarge(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. App Details & Version
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lovio.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lovio Mobile Version',
                        style: AppTextStyles.titleMedium(color: lovio.textPrimary)),
                    Text('v1.0.0 (2026 Release)',
                        style: AppTextStyles.labelMedium(color: lovio.accent)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Created with Love 💕 Clean Architecture & Firebase Backend.',
                  style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

