import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../view_models/auth_view_model.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      final user = ref.read(authProvider).user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text('Welcome back, ${user?.displayName ?? ""}! 💕'),
        ),
      );
      context.go(AppRoutes.home);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final lovio = context.lovioColors;
        return AlertDialog(
          backgroundColor: lovio.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            'Reset Password',
            style: AppTextStyles.headlineSmall(color: lovio.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your registered email address and we will send you a password reset link.',
                style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'you@love.com',
                ),
              ),
            ],
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
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  await ref
                      .read(authRepositoryProvider)
                      .sendPasswordResetEmail(email);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent to your email!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
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
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: lovio.glow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displaySmall(color: lovio.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to your Lovio account to access your library 💕',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.handwrittenMedium(color: lovio.accent),
                  ),
                  const SizedBox(height: 32),

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
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter your password'
                        : null,
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.labelSmall(color: lovio.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Sign In Action Button
                  AnimatedPressable(
                    onPressed: authState.isLoading ? null : _handleSignIn,
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
                                'Sign In to Lovio',
                                style: AppTextStyles.labelLarge(
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: lovio.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: AppTextStyles.labelSmall(
                              color: lovio.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: lovio.border)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Social Sign-In Hooks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialPillButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Google',
                        onTap: () {
                          ref.read(authProvider.notifier).signInWithGoogle();
                        },
                      ),
                      const SizedBox(width: 14),
                      _SocialPillButton(
                        icon: Icons.apple_rounded,
                        label: 'Apple',
                        onTap: () {
                          ref.read(authProvider.notifier).signInWithApple();
                        },
                      ),
                      const SizedBox(width: 14),
                      _SocialPillButton(
                        icon: Icons.facebook_rounded,
                        label: 'Facebook',
                        onTap: () {
                          ref.read(authProvider.notifier).signInWithFacebook();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Link to Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium(
                            color: lovio.textSecondary),
                      ),
                      AnimatedPressable(
                        onPressed: () => context.go(AppRoutes.signUp),
                        child: Text(
                          'Sign Up',
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

class _SocialPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialPillButton({
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

