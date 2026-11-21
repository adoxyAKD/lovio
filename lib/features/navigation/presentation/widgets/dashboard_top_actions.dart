import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/avatar_helper.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../authentication/presentation/view_models/auth_view_model.dart';

/// Top-Right Dashboard Actions containing:
/// 1. Notifications (Bell Icon) with unread indicator badge
/// 2. User Profile Avatar with custom circular photo/initial
class DashboardTopActions extends ConsumerWidget {
  final bool hasUnreadNotifications;

  const DashboardTopActions({
    super.key,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lovio = context.lovioColors;
    final user = ref.watch(authProvider).user;

    final avatarProvider = getAvatarImageProvider(user?.photoUrl);

    final initial = (user?.displayName.isNotEmpty == true)
        ? user!.displayName[0].toUpperCase()
        : 'L';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Notifications (Bell Icon)
        AnimatedPressable(
          onPressed: () => context.push(AppRoutes.notifications),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: lovio.surface,
              shape: BoxShape.circle,
              boxShadow: AppShadows.softCard,
              border: Border.all(color: lovio.border),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: lovio.textPrimary,
                  size: 20,
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: lovio.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 2. Profile Avatar
        AnimatedPressable(
          onPressed: () => context.push(AppRoutes.profile),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              gradient: lovio.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: lovio.glow,
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: lovio.surface,
              backgroundImage: avatarProvider,
              child: avatarProvider == null
                  ? Text(
                      initial,
                      style: AppTextStyles.labelMedium(
                        color: lovio.accent,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
