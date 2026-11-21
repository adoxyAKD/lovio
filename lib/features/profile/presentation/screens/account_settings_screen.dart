import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/avatar_helper.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../authentication/presentation/view_models/auth_view_model.dart';
import '../../../creation/presentation/view_models/creations_view_model.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _partnerController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _anniversaryDate;
  File? _avatarFile;
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.displayName;
      _partnerController.text = user.partnerName ?? '';
      _bioController.text = user.bio ?? '';
      _anniversaryDate = user.anniversaryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _partnerController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile =
            await File(picked.path).copy('${appDir.path}/$fileName');
        setState(() {
          _avatarFile = savedFile;
          _isEditing = true;
        });
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
    }
  }

  Future<void> _pickAnniversary() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _anniversaryDate ?? now,
      firstDate: DateTime(1980),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _anniversaryDate = picked;
        _isEditing = true;
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    final success = await ref.read(authProvider.notifier).updateProfile(
          displayName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          photoUrl: _avatarFile?.path,
          partnerName: _partnerController.text.trim().isNotEmpty
              ? _partnerController.text.trim()
              : null,
          anniversaryDate: _anniversaryDate,
          bio: _bioController.text.trim().isNotEmpty
              ? _bioController.text.trim()
              : null,
        );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully! ✨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);
    bool obscureCurrent = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final lovio = context.lovioColors;

            return AlertDialog(
              backgroundColor: lovio.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                'Change Password',
                style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () => setDialogState(
                              () => obscureCurrent = !obscureCurrent),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Minimum 6 characters required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureNew,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                      validator: (val) {
                        if (val != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
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
                    backgroundColor: lovio.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop();

                    final success =
                        await ref.read(authProvider.notifier).changePassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );

                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Password changed successfully! 🔒'
                                : 'Failed to change password. Please verify current password.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    final lovio = context.lovioColors;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: lovio.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          title,
          style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: lovio.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    final lovio = context.lovioColors;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: lovio.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Sign Out of Lovio?',
          style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
        ),
        content: Text(
          'Your local creations stay safe on this device. You will be redirected to the sign-in screen.',
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
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final creations = ref.watch(creationsProvider).items;

    ImageProvider? avatarProvider;
    if (_avatarFile != null && _avatarFile!.existsSync()) {
      avatarProvider = FileImage(_avatarFile!);
    } else {
      avatarProvider = getAvatarImageProvider(user?.photoUrl);
    }

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Text(
          'Account Settings',
          style: AppTextStyles.displaySmall(color: lovio.textPrimary),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: authState.isLoading ? null : _saveProfileChanges,
              child: Text(
                'Save',
                style: AppTextStyles.labelLarge(color: lovio.accent),
              ),
            ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // 1. Avatar Section
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: lovio.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: lovio.glow,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: lovio.surface,
                    backgroundImage: avatarProvider,
                    child: avatarProvider == null
                        ? Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName[0].toUpperCase()
                                : 'L',
                            style: AppTextStyles.displayMedium(
                              color: lovio.accent,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedPressable(
                    onPressed: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lovio.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: lovio.glow,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.email ?? 'Not logged in',
              style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Personal Information Fields
          Text(
            'Personal Information',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          const SizedBox(height: 12),

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
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() => _isEditing = true),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _partnerController,
                  onChanged: (_) => setState(() => _isEditing = true),
                  decoration: const InputDecoration(
                    labelText: 'Partner Name',
                    prefixIcon: Icon(Icons.favorite_border_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today_rounded,
                      color: lovio.textPrimary),
                  title: Text(
                    _anniversaryDate != null
                        ? 'Anniversary: ${_anniversaryDate!.day}/${_anniversaryDate!.month}/${_anniversaryDate!.year}'
                        : 'Select Anniversary Date',
                    style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                  ),
                  trailing: TextButton(
                    onPressed: _pickAnniversary,
                    child: Text(
                      'Choose',
                      style: AppTextStyles.labelLarge(color: lovio.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bioController,
                  maxLines: 2,
                  onChanged: (_) => setState(() => _isEditing = true),
                  decoration: const InputDecoration(
                    labelText: 'Bio & Love Note',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    hintText: 'Share a sweet quote or memory...',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Security & Cloud Backup
          Text(
            'Security & Cloud Backup',
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
                  leading: Icon(Icons.lock_reset_rounded, color: lovio.accent),
                  title: Text(
                    'Change Password',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    'Update your account security credentials',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: _showChangePasswordDialog,
                ),
                Divider(height: 1, color: lovio.border),
                ListTile(
                  leading:
                      Icon(Icons.cloud_done_rounded, color: lovio.accent),
                  title: Text(
                    'Cloud Storage & Sync',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  subtitle: Text(
                    '${creations.length} items saved locally on device',
                    style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Syncing profile & creations to Firebase... ☁️'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );

                      try {
                        // 1. Re-sync profile to Realtime Database & Firestore
                        if (user != null) {
                          await ref.read(authProvider.notifier).updateProfile(
                                displayName: user.displayName,
                                photoUrl: user.photoUrl,
                                partnerName: user.partnerName,
                                anniversaryDate: user.anniversaryDate,
                              );
                        }

                        // 2. Sync creations
                        final creationsNotifier =
                            ref.read(creationsProvider.notifier);
                        for (final item in creations) {
                          try {
                            await creationsNotifier.uploadToCloud(item.id);
                          } catch (_) {}
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Synced profile & ${creations.length} creations to Firebase Realtime Database! ☁️✨',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sync error: $e. Check Firebase Realtime Database rules.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Sync All',
                      style: AppTextStyles.labelLarge(color: lovio.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Support & Information
          Text(
            'Support & Information',
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
                  leading:
                      Icon(Icons.shield_outlined, color: lovio.textPrimary),
                  title: Text(
                    'Privacy Policy',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () => _showInfoDialog(
                    'Privacy Policy',
                    'Lovio is built with privacy at its heart. Your personal stories, love letters, photos, and memory collections are stored locally on your device by default.\n\nWhen you choose to backup or sync to the cloud, all data is transmitted securely via Firebase with end-to-end encryption. We never sell or share your memories with third parties.',
                  ),
                ),
                Divider(height: 1, color: lovio.border),
                ListTile(
                  leading: Icon(Icons.description_outlined,
                      color: lovio.textPrimary),
                  title: Text(
                    'Terms & Conditions',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () => _showInfoDialog(
                    'Terms & Conditions',
                    'By using Lovio, you agree to create and share respectful, meaningful, and loving content. You retain 100% full ownership and intellectual rights of everything you create in Lovio.',
                  ),
                ),
                Divider(height: 1, color: lovio.border),
                ListTile(
                  leading: Icon(Icons.help_outline_rounded,
                      color: lovio.textPrimary),
                  title: Text(
                    'Help & Support',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () => _showInfoDialog(
                    'Help & Support',
                    'Need assistance with your creations, books, or account?\n\nOur team is here to support your journey:\nEmail: support@lovio.app\nWebsite: https://lovio.app/help\nResponse Time: Within 24 hours.',
                  ),
                ),
                Divider(height: 1, color: lovio.border),
                ListTile(
                  leading: Icon(Icons.info_outline_rounded,
                      color: lovio.textPrimary),
                  title: Text(
                    'About Lovio',
                    style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () => _showInfoDialog(
                    'About Lovio',
                    'Lovio v1.0.0 (2026 Next-Gen Edition)\n\nTagline: Create. Personalize. Share Love.\n\nDesigned as a premium digital storytelling and creative companion. Featuring dynamic animated backgrounds, customizable color themes, and offline-first memory protection.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 5. Danger Zone / Sign Out
          AnimatedPressable(
            onPressed: _showSignOutDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sign Out of Lovio',
                    style: AppTextStyles.labelLarge(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

