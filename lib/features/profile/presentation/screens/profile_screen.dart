import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/avatar_helper.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../authentication/presentation/view_models/auth_view_model.dart';
import '../../../creation/presentation/view_models/creations_view_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final lovio = context.lovioColors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: lovio.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            'Sign Out of Lovio?',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          content: Text(
            'Your local creations will remain safely stored on this device. You can sign back in anytime to sync with the cloud.',
            style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge(color: lovio.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signed out successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircularAvatar(
      BuildContext context, String? photoUrl, String displayName) {
    final lovio = context.lovioColors;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'L';
    final imageProvider = getAvatarImageProvider(photoUrl);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: lovio.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: lovio.glow,
      ),
      child: CircleAvatar(
        radius: 46,
        backgroundColor: lovio.surface,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                initial,
                style: AppTextStyles.displayMedium(color: lovio.accent),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lovio = context.lovioColors;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final creationsCount = ref.watch(creationsProvider).items.length;

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.displaySmall(color: lovio.textPrimary),
        ),
        actions: [
          // Professional App Settings Gear Icon in Top Right
          AnimatedPressable(
            onPressed: () => context.push(AppRoutes.appSettings),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: lovio.surface,
                shape: BoxShape.circle,
                boxShadow: AppShadows.softCard,
                border: Border.all(color: lovio.border),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: lovio.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // 1. Authenticated User Profile Header
          if (user != null) ...[
            Center(
              child: AnimatedPressable(
                onPressed: () => context.push(AppRoutes.accountSettings),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _buildCircularAvatar(
                            context, user.photoUrl, user.displayName),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: lovio.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.favorite_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.partnerName != null
                              ? '${user.displayName} & ${user.partnerName}'
                              : user.displayName,
                          style: AppTextStyles.headlineMedium(
                              color: lovio.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_rounded,
                            size: 16, color: lovio.accent),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style:
                          AppTextStyles.bodySmall(color: lovio.textSecondary),
                    ),
                    const SizedBox(height: 12),

                    // Anniversary or Partner Connection Pill
                    if (user.daysTogether != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: lovio.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: lovio.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_rounded,
                                size: 16, color: lovio.accent),
                            const SizedBox(width: 6),
                            Text(
                              '${user.daysTogether} Days Together 💕',
                              style: AppTextStyles.labelMedium(
                                  color: lovio.textPrimary),
                            ),
                          ],
                        ),
                      )
                    else if (user.partnerName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: lovio.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: lovio.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_rounded,
                                size: 16, color: lovio.accent),
                            const SizedBox(width: 6),
                            Text(
                              'Connected with ${user.partnerName} 💕',
                              style: AppTextStyles.labelMedium(
                                  color: lovio.textPrimary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.softCard,
                border: Border.all(color: lovio.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(count: '$creationsCount', label: 'Creations'),
                  _VerticalDivider(color: lovio.border),
                  const _StatColumn(count: '1', label: 'Partner'),
                  _VerticalDivider(color: lovio.border),
                  const _StatColumn(count: 'Synced', label: 'Cloud Status'),
                ],
              ),
            ),
          ]

          // 2. Unauthenticated Guest Hero Card
          else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppShadows.softCard,
                border: Border.all(color: lovio.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: lovio.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: lovio.glow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Lovio',
                    style:
                        AppTextStyles.headlineMedium(color: lovio.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in or create an account with email to backup your stories to Firebase and connect with your partner.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedPressable(
                          onPressed: () => context.push(AppRoutes.signIn),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: lovio.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: lovio.border),
                            ),
                            child: Center(
                              child: Text(
                                'Sign In',
                                style: AppTextStyles.labelLarge(
                                    color: lovio.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedPressable(
                          onPressed: () => context.push(AppRoutes.signUp),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: lovio.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: lovio.glow,
                            ),
                            child: Center(
                              child: Text(
                                'Sign Up Free',
                                style: AppTextStyles.labelLarge(
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Privacy & Vault Guarantee Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.softCard,
              border: Border.all(color: lovio.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: lovio.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy & Vault Guarantee',
                      style:
                          AppTextStyles.titleMedium(color: lovio.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your letters, books and memories are encrypted. Personal creations stay strictly private unless you choose to share them.',
                  style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options & Settings (Unified & Streamlined)
          _SettingsOptionTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile & Account',
            subtitle: 'Name, partner details, anniversary & photo',
            onTap: () {
              if (user != null) {
                context.push(AppRoutes.accountSettings);
              } else {
                context.push(AppRoutes.signIn);
              }
            },
          ),
          // Single Unified Theme & Appearance Setting
          _SettingsOptionTile(
            icon: Icons.palette_outlined,
            title: 'App Theme & Appearance',
            subtitle: 'Solid colors, romantic gradients & dark/light mode',
            onTap: () => context.push(AppRoutes.themeSettings),
          ),
          _SettingsOptionTile(
            icon: Icons.tune_rounded,
            title: 'App Settings & Preferences',
            subtitle: 'Cloud sync, notifications, offline storage & vault',
            onTap: () => context.push(AppRoutes.appSettings),
          ),

          // Professional Logout Button at bottom if authenticated
          if (user != null) ...[
            const SizedBox(height: 24),
            Center(
              child: AnimatedPressable(
                onPressed: () => _showSignOutDialog(context, ref),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout_rounded,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out of Lovio',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.headlineMedium(color: lovio.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall(color: lovio.textSecondary),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: color,
    );
  }
}

class _SettingsOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.softCard,
        border: Border.all(color: lovio.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: lovio.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: lovio.accent, size: 22),
        ),
        title: Text(title,
            style: AppTextStyles.titleMedium(color: lovio.textPrimary)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: AppTextStyles.bodySmall(color: lovio.textSecondary))
            : null,
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: lovio.textMuted),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
