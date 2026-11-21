import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../view_models/auth_view_model.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _partnerController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _selectedAnniversary;
  File? _avatarFile;
  bool _obscurePassword = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _partnerController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
        // Save to permanent application documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');
        setState(() => _avatarFile = savedFile);
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
    );
    if (picked != null) {
      setState(() => _selectedAnniversary = picked);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          photoUrl: _avatarFile?.path,
          partnerName: _partnerController.text.trim().isEmpty
              ? null
              : _partnerController.text.trim(),
          anniversaryDate: _selectedAnniversary,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            'Welcome to Lovio, ${_nameController.text.trim()}! 💕',
          ),
        ),
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: lovio.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: lovio.glow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Lovio',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displaySmall(color: lovio.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your account to capture & share your love story ✨',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.handwrittenMedium(color: lovio.accent),
                  ),
                  const SizedBox(height: 24),

                  // Circular Profile Picture Upload
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
                              radius: 46,
                              backgroundColor: lovio.surface,
                              backgroundImage: _avatarFile != null
                                  ? FileImage(_avatarFile!)
                                  : null,
                              child: _avatarFile == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 46,
                                      color: lovio.accent,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: lovio.accent,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2.5),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Upload Profile Photo',
                      style: AppTextStyles.labelSmall(
                          color: lovio.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style:
                            AppTextStyles.bodySmall(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      hintText: 'e.g. Alexander Vance',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter your full name'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Partner Name
                  TextFormField(
                    controller: _partnerController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                    decoration: const InputDecoration(
                      labelText: "Partner's Name (Optional)",
                      prefixIcon:
                          Icon(Icons.favorite_border_rounded, size: 20),
                      hintText: 'e.g. Sophia Vance',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Anniversary Date
                  AnimatedPressable(
                    onPressed: _selectAnniversaryDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: lovio.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: lovio.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cake_outlined,
                              size: 20, color: lovio.accent),
                          const SizedBox(width: 12),
                          Text(
                            _selectedAnniversary == null
                                ? 'Select Anniversary Date (Optional)'
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
                  const SizedBox(height: 14),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                      hintText: 'alexander@love.com',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) => val == null || val.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Action Button
                  AnimatedPressable(
                    onPressed: authState.isLoading ? null : _handleSignUp,
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
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                'Create My Account',
                                style: AppTextStyles.labelLarge(
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium(
                            color: lovio.textSecondary),
                      ),
                      AnimatedPressable(
                        onPressed: () {
                          ref.read(authProvider.notifier).markFirstTimeComplete();
                          context.go(AppRoutes.signIn);
                        },
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.labelLarge(
                              color: lovio.accent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
