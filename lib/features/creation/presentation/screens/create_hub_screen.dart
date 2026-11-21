import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/creation_document.dart';
import '../../domain/entities/creation_item.dart';
import '../view_models/creations_view_model.dart';

class CreateHubScreen extends ConsumerWidget {
  const CreateHubScreen({super.key});

  void _showCreateDialog(
    BuildContext context,
    WidgetRef ref, {
    required String defaultTitle,
    required CreationType type,
    required LinearGradient gradient,
    required String gradientKey,
  }) {
    final titleController = TextEditingController(text: defaultTitle);
    bool syncToCloud = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final lovio = context.lovioColors;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: lovio.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start New Creation',
                              style: AppTextStyles.headlineSmall(
                                  color: lovio.textPrimary),
                            ),
                            Text(
                              'Stored locally on your device first',
                              style: AppTextStyles.bodySmall(
                                  color: lovio.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Creation Title',
                    style: AppTextStyles.labelMedium(color: lovio.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Enter title...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => titleController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Storage & Sync Options Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lovio.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lovio.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_android_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Local Storage',
                                    style: AppTextStyles.titleSmall(
                                        color: lovio.textPrimary),
                                  ),
                                  Text(
                                    'Always saved instantly offline',
                                    style: AppTextStyles.labelSmall(
                                        color: lovio.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Enabled',
                                style: AppTextStyles.labelSmall(
                                    color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              color: AppColors.roseAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sync to Cloud (Firebase)',
                                    style: AppTextStyles.titleSmall(
                                        color: lovio.textPrimary),
                                  ),
                                  Text(
                                    'Backup & access across devices',
                                    style: AppTextStyles.labelSmall(
                                        color: lovio.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: syncToCloud,
                              activeColor: lovio.accent,
                              onChanged: (val) {
                                setSheetState(() => syncToCloud = val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedPressable(
                      onPressed: () async {
                        final title = titleController.text.trim().isEmpty
                            ? defaultTitle
                            : titleController.text.trim();

                        Navigator.of(bottomSheetContext).pop();

                        await ref
                            .read(creationsProvider.notifier)
                            .createNewCreation(
                              title: title,
                              type: type,
                              coverGradientKey: gradientKey,
                              syncImmediately: syncToCloud,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: lovio.surface,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: [
                                  Icon(
                                    syncToCloud
                                        ? Icons.cloud_done_rounded
                                        : Icons.save_rounded,
                                    color: lovio.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      syncToCloud
                                          ? 'Saved locally & synced to cloud! ☁️'
                                          : 'Saved securely on your device! 📱',
                                      style: AppTextStyles.bodyMedium(
                                          color: lovio.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          // Navigate to My Library to inspect the saved file
                          context.go(AppRoutes.library);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: lovio.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: lovio.glow,
                        ),
                        child: Center(
                          child: Text(
                            syncToCloud
                                ? 'Save & Upload to Cloud'
                                : 'Save to Device',
                            style:
                                AppTextStyles.labelLarge(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lovio = context.lovioColors;

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: lovio.textPrimary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Create Studio',
          style: AppTextStyles.titleLarge(color: lovio.textPrimary),
        ),
        centerTitle: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Subtitle Header
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Express Your Heart',
                  style: AppTextStyles.headlineMedium(color: lovio.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your canvas & design cherished memories ✨',
                  style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
                ),
              ],
            ),
          ),

          // 1. Create a Page (Most Prominent First Card)
          _CreationActionCard(
            title: 'Create a Page',
            subtitle:
                'Interactive artistic canvas with animated backgrounds, photo frames, floating stickers & instant sharing.',
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.auto_stories_rounded,
            badge: 'Featured • Full Studio',
            onTap: () => context.push(AppRoutes.createPageWrite),
          ),
          const SizedBox(height: 16),

          // 2. Create Short Book
          _CreationActionCard(
            title: 'Create Short Book',
            subtitle:
                'Multi-page digital storybook with animated pages, music & cover page.',
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.menu_book_rounded,
            badge: 'Most Popular',
            onTap: () => _showCreateDialog(
              context,
              ref,
              defaultTitle: 'Our Love Story',
              type: CreationType.shortBook,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              gradientKey: 'theme_secondary',
            ),
          ),
          const SizedBox(height: 16),

          // 3. Create Card
          _CreationActionCard(
            title: 'Create Card',
            subtitle:
                'Interactive greeting card with 3D folding effect and animated stickers.',
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.card_giftcard_rounded,
            badge: 'Instant Share',
            onTap: () => _showCreateDialog(
              context,
              ref,
              defaultTitle: 'Thinking of You',
              type: CreationType.card,
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
              ),
              gradientKey: 'primary',
            ),
          ),
          const SizedBox(height: 16),

          // 4. Write Love Letter
          _CreationActionCard(
            title: 'Write Love Letter',
            subtitle:
                'Elegant digital letter on vintage stationery with wax seal animation.',
            gradient: const LinearGradient(
              colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.mark_email_unread_rounded,
            badge: 'Heartfelt',
            onTap: () => _showCreateDialog(
              context,
              ref,
              defaultTitle: 'To My Beloved',
              type: CreationType.loveLetter,
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
              ),
              gradientKey: 'letter',
            ),
          ),
          const SizedBox(height: 24),

          // Quick Start Strip
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.softCard,
              border: Border.all(color: lovio.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Blank Canvas',
                  onTap: () => context.push(AppRoutes.createPageWrite),
                ),
                _QuickActionButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Templates',
                  onTap: () => context.go(AppRoutes.explore),
                ),
                _QuickActionButton(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'Import Photos',
                  onTap: () => context.push(
                    AppRoutes.createPageEditor,
                    extra: {'pickImage': true},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Saved Content Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Content & Drafts',
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
                  '${ref.watch(creationsProvider).items.length} items',
                  style: AppTextStyles.labelSmall(color: lovio.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SavedCreationsList(
            items: ref.watch(creationsProvider).items,
            onUpload: (doc) {
              ref
                  .read(creationsProvider.notifier)
                  .uploadToCloud(doc.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Syncing "${doc.title}" to Firebase Cloud ☁️'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SavedCreationsList extends StatelessWidget {
  final List<CreationDocument> items;
  final ValueChanged<CreationDocument> onUpload;

  const _SavedCreationsList({
    required this.items,
    required this.onUpload,
  });

  LinearGradient _getGradient(BuildContext context, String key) {
    final lovio = context.lovioColors;
    switch (key) {
      case 'sunset':
      case 'theme_primary':
      case 'primary':
        return lovio.primaryGradient;
      case 'lavender':
      case 'secondary':
        return lovio.secondaryGradient;
      default:
        return lovio.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: lovio.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: lovio.border),
          boxShadow: AppShadows.softCard,
        ),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 40, color: lovio.textMuted),
            const SizedBox(height: 10),
            Text(
              'No saved creations yet',
              style: AppTextStyles.titleMedium(color: lovio.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose an option above to create your first book, card, or letter ✨',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: lovio.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((doc) {
        final isSynced = doc.syncStatus == SyncStatus.synced;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lovio.border),
            boxShadow: AppShadows.softCard,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient:
                      _getGradient(context, doc.coverGradientKey ?? 'primary'),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style:
                          AppTextStyles.titleMedium(color: lovio.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSynced
                                ? const Color(0xFF06D6A0).withOpacity(0.15)
                                : lovio.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSynced
                                    ? Icons.cloud_done_rounded
                                    : Icons.phone_android_rounded,
                                size: 12,
                                color: isSynced
                                    ? const Color(0xFF06D6A0)
                                    : lovio.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSynced ? 'Synced' : 'Saved on Device',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSynced
                                      ? const Color(0xFF06D6A0)
                                      : lovio.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${doc.pageCount} pages',
                          style:
                              AppTextStyles.labelSmall(color: lovio.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isSynced)
                IconButton(
                  icon: Icon(Icons.cloud_upload_outlined,
                      color: lovio.accent, size: 22),
                  onPressed: () => onUpload(doc),
                  tooltip: 'Upload to Cloud',
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CreationActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final String badge;
  final VoidCallback onTap;

  const _CreationActionCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          color: lovio.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppShadows.softCard,
          border: Border.all(color: lovio.border.withOpacity(0.8), width: 1.5),
        ),
        child: Row(
          children: [
            // Left Graphic with animated interactive icon & dynamic gradient
            Container(
              width: 110,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
              ),
              child: Center(
                child: _DynamicInteractiveIcon(
                  icon: icon,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            // Right Description
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: lovio.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: lovio.accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lovio.background,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: lovio.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: AppTextStyles.titleLarge(color: lovio.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.bodySmall(color: lovio.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicInteractiveIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _DynamicInteractiveIcon({
    required this.icon,
    this.color = Colors.white,
    this.size = 34,
  });

  @override
  State<_DynamicInteractiveIcon> createState() => _DynamicInteractiveIconState();
}

class _DynamicInteractiveIconState extends State<_DynamicInteractiveIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final val = _anim.value;
        final dy = math.sin(val * math.pi * 2) * 3.5;
        final scale = 1.0 + 0.05 * math.sin(val * math.pi * 2);

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.25),
                border: Border.all(
                    color: Colors.white.withOpacity(0.45), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lovio.accent.withOpacity(0.2),
                  lovio.primary.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: lovio.accent.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: lovio.accent, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: lovio.textPrimary),
          ),
        ],
      ),
    );
  }
}
