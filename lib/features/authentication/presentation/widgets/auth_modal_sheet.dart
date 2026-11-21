import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../view_models/auth_view_model.dart';

/// Next-Generation 2026 Authentication Sheet (Login & Signup)
class AuthModalSheet extends ConsumerStatefulWidget {
  final bool initialIsSignUp;

  const AuthModalSheet({
    super.key,
    this.initialIsSignUp = false,
  });

  static Future<void> show(BuildContext context, {bool isSignUp = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthModalSheet(initialIsSignUp: isSignUp),
    );
  }

  @override
  ConsumerState<AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends ConsumerState<AuthModalSheet> {
  late bool _isSignUp;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _partnerNameController = TextEditingController();

  DateTime? _selectedAnniversary;
  File? _selectedAvatarFile;
  bool _obscurePassword = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedAvatarFile = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _selectAnniversaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedAnniversary ?? now,
      firstDate: DateTime(1980),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: context.theme.copyWith(
            colorScheme: context.colorScheme.copyWith(
              primary: AppColors.roseAccent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedAnniversary = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    bool success = false;

    if (_isSignUp) {
      success = await authNotifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim().isEmpty
            ? 'Beloved'
            : _displayNameController.text.trim(),
        photoUrl: _selectedAvatarFile?.path,
        partnerName: _partnerNameController.text.trim().isEmpty
            ? null
            : _partnerNameController.text.trim(),
        anniversaryDate: _selectedAnniversary,
      );
    } else {
      success = await authNotifier.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      final user = ref.read(authProvider).user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            _isSignUp
                ? 'Welcome to Lovio, ${user?.displayName ?? ""}! ✨'
                : 'Welcome back, ${user?.displayName ?? ""}! 💕',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final authState = ref.watch(authProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: AppShadows.floating,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
              const SizedBox(height: 18),

              // Title & Mode Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        style: AppTextStyles.displaySmall(
                            color: lovio.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isSignUp
                            ? 'Capture & celebrate your love ✨'
                            : 'Sign in to access your library',
                        style: AppTextStyles.handwrittenMedium(
                            color: lovio.accent),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: lovio.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AuthTabPill(
                          label: 'Login',
                          isSelected: !_isSignUp,
                          onTap: () => setState(() => _isSignUp = false),
                        ),
                        _AuthTabPill(
                          label: 'Sign Up',
                          isSelected: _isSignUp,
                          onTap: () => setState(() => _isSignUp = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Error Banner if present
              if (authState.errorMessage != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style:
                              AppTextStyles.bodySmall(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Sign Up Only: Circular Profile Avatar Picker
              if (_isSignUp) ...[
                Center(
                  child: Stack(
                    children: [
                      AnimatedPressable(
                        onPressed: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: lovio.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: lovio.glow,
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: lovio.surface,
                            backgroundImage: _selectedAvatarFile != null
                                ? FileImage(_selectedAvatarFile!)
                                : null,
                            child: _selectedAvatarFile == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 42,
                                    color: AppColors.roseAccent,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: AnimatedPressable(
                          onPressed: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: lovio.accent,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Upload Profile Picture',
                    style: AppTextStyles.labelSmall(color: lovio.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Name
                TextFormField(
                  controller: _displayNameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    hintText: 'e.g. Alexander',
                  ),
                  validator: (value) {
                    if (_isSignUp && (value == null || value.trim().isEmpty)) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Partner's Name (Personalized for Lovio)
                TextFormField(
                  controller: _partnerNameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                  decoration: const InputDecoration(
                    labelText: "Partner's Name (Optional)",
                    prefixIcon: Icon(Icons.favorite_border_rounded, size: 20),
                    hintText: 'e.g. Sophia',
                  ),
                ),
                const SizedBox(height: 12),

                // Anniversary Date
                AnimatedPressable(
                  onPressed: _selectAnniversaryDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: lovio.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lovio.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_outlined,
                            size: 20, color: AppColors.roseAccent),
                        const SizedBox(width: 12),
                        Text(
                          _selectedAnniversary == null
                              ? 'Anniversary Date (Optional)'
                              : 'Anniversary: ${_selectedAnniversary!.day}/${_selectedAnniversary!.month}/${_selectedAnniversary!.year}',
                          style: AppTextStyles.bodyMedium(
                            color: _selectedAnniversary == null
                                ? lovio.textMuted
                                : lovio.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_rounded,
                            size: 16, color: lovio.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Email Input
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                  hintText: 'you@love.com',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Password Input
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (_isSignUp && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              // Submit Button
              AnimatedPressable(
                onPressed: authState.isLoading ? null : _handleSubmit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: lovio.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: lovio.glow,
                  ),
                  child: Center(
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Create My Account' : 'Sign In',
                            style:
                                AppTextStyles.labelLarge(color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider with "Or continue with"
              Row(
                children: [
                  Expanded(child: Divider(color: lovio.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style:
                          AppTextStyles.labelSmall(color: lovio.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: lovio.border)),
                ],
              ),
              const SizedBox(height: 16),

              // Social Sign-In Hooks (Google, Apple, Facebook)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialAuthButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Google',
                    onTap: () {
                      ref.read(authProvider.notifier).signInWithGoogle();
                    },
                  ),
                  const SizedBox(width: 14),
                  _SocialAuthButton(
                    icon: Icons.apple_rounded,
                    label: 'Apple',
                    onTap: () {
                      ref.read(authProvider.notifier).signInWithApple();
                    },
                  ),
                  const SizedBox(width: 14),
                  _SocialAuthButton(
                    icon: Icons.facebook_rounded,
                    label: 'Facebook',
                    onTap: () {
                      ref.read(authProvider.notifier).signInWithFacebook();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AuthTabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? lovio.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: isSelected ? Colors.white : lovio.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: lovio.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: lovio.border),
          boxShadow: AppShadows.softCard,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: lovio.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: lovio.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
