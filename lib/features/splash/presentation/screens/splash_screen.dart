import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme_notifier.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../authentication/presentation/view_models/auth_view_model.dart';

/// Modern, High-Performance Animated Splash Screen
///
/// Delivers a dynamic branded launch experience:
/// - Automatically adapts its background color or gradient to the user's chosen theme
/// - Matches solid themes with their background color and gradient themes with their gradient
/// - Displays smooth pulsating glowing brand heart & dynamic typography
/// - Quickly transitions to Login page (if unauthenticated) or Home (if authenticated)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _taglineFadeAnimation;

  Timer? _navigationTimer;
  Timer? _retryTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.95, curve: Curves.easeOut),
      ),
    );

    _animController.forward();

    // Show splash screen for minimum 5 seconds as requested
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    // Wait minimum 5 seconds for the branded splash reveal and experience
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() {
    if (_hasNavigated || !mounted) return;

    final authState = ref.read(authProvider);

    // If still loading, wait a maximum of 400ms more before making a deterministic routing decision
    if (authState.isLoading) {
      _retryTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted && !_hasNavigated) {
          _performNavigation();
        }
      });
      return;
    }

    _performNavigation();
  }

  void _performNavigation() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final authState = ref.read(authProvider);
    final pendingDeepLinkToken =
        DeepLinkService.instance.consumePendingToken();

    try {
      // 1. If a deep link is pending, navigate directly to that card
      if (pendingDeepLinkToken != null && pendingDeepLinkToken.isNotEmpty) {
        context.go('/p/$pendingDeepLinkToken');
        return;
      }

      // 2. If authenticated, proceed to Home Dashboard
      if (authState.isAuthenticated) {
        context.go(AppRoutes.home);
        return;
      }

      // 3. By default for all unauthenticated/first-time users: Go to Login (Sign In)
      context.go(AppRoutes.signIn);
    } catch (e) {
      debugPrint('Splash navigation notice: $e');
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _retryTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final preset = themeState.currentPreset;
    final lovio = context.lovioColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGradient = preset.isGradient;
    final isDarkSurface = isDark || isGradient;

    // Dynamically match the background:
    // - Gradient themes use the theme's linear gradient
    // - Solid themes use the theme's background color
    final BoxDecoration backgroundDecoration = isGradient
        ? BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(preset.gradient.colors.first,
                          const Color(0xFF070913), 0.45)!,
                      Color.lerp(preset.gradient.colors.last,
                          const Color(0xFF070913), 0.70)!,
                    ],
                  )
                : preset.gradient,
          )
        : BoxDecoration(
            color: isDark ? lovio.background : preset.backgroundColor,
          );

    final Color primaryGlow = preset.primaryColor
        .withOpacity(isDarkSurface ? 0.35 : 0.16);
    final Color secondaryGlow = (isGradient
            ? preset.accentColor
            : preset.secondaryColor)
        .withOpacity(isDarkSurface ? 0.28 : 0.12);

    final systemUiStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isDarkSurface ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkSurface
          ? Colors.transparent
          : (isDark ? lovio.background : preset.backgroundColor),
      systemNavigationBarIconBrightness:
          isDarkSurface ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: Scaffold(
        backgroundColor: isGradient
            ? null
            : (isDark ? lovio.background : preset.backgroundColor),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: backgroundDecoration,
          child: Stack(
            children: [
              // 1. Ambient Background Glows dynamically matched to theme accents
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryGlow,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -80,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        secondaryGlow,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Central Animated Brand Mark
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing App Logo Container dynamically styled for the theme
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: isGradient
                                    ? Colors.black.withOpacity(0.25)
                                    : preset.primaryColor.withOpacity(
                                        isDark ? 0.50 : 0.35),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Brand Title
                        Text(
                          'Lovio',
                          style: GoogleFonts.poppins(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDarkSurface
                                ? Colors.white
                                : lovio.textPrimary,
                            shadows: [
                              Shadow(
                                color: (isDarkSurface
                                        ? (isGradient
                                            ? Colors.black.withOpacity(0.35)
                                            : preset.primaryColor)
                                        : preset.primaryColor)
                                    .withOpacity(isDarkSurface ? 0.45 : 0.22),
                                blurRadius: isDarkSurface ? 20 : 16,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineFadeAnimation,
                          child: Text(
                            'Create. Personalize. Share Love. ✨',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.caveat(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDarkSurface
                                  ? Colors.white.withOpacity(0.92)
                                  : preset.primaryColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Dynamic loading indicator matching theme
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _taglineFadeAnimation,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkSurface
                              ? Colors.white.withOpacity(0.85)
                              : preset.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

