import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import 'page_share_sheet.dart';

class PageSaveSuccessSheet {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final lovio = context.lovioColors;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: AppShadows.floating,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: lovio.border.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),

              // Animated Glowing Celebration Icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: lovio.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: lovio.primary.withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bookmark_added_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Saved to My Library! 📖✨',
                style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Your card has been preserved securely on this device and synced with cloud backup.',
                style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Storage Badges Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: lovio.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: lovio.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Offline Saved',
                      style: AppTextStyles.labelSmall(
                          color: const Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    const Icon(Icons.cloud_done_rounded,
                        color: Color(0xFF2260F2), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Cloud Synced',
                      style: AppTextStyles.labelSmall(
                          color: const Color(0xFF2260F2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action 1: Share Now (Prominent First Action)
              SizedBox(
                width: double.infinity,
                child: AnimatedPressable(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    PageShareSheet.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: lovio.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: lovio.glow,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Share Surprise with Loved One 💌',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: View in Library
              SizedBox(
                width: double.infinity,
                child: AnimatedPressable(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go(AppRoutes.library);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: lovio.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lovio.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            color: lovio.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'View in My Library',
                          style: AppTextStyles.labelLarge(color: lovio.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Action 3: Go to Home Dashboard
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go(AppRoutes.home);
                  },
                  icon: Icon(Icons.home_rounded,
                      color: lovio.textSecondary, size: 18),
                  label: Text(
                    'Go to Home Dashboard',
                    style:
                        AppTextStyles.labelMedium(color: lovio.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

