import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import 'animated_pressable.dart';

/// Branded empty state component
class LovioEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? customIllustration;

  const LovioEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIllustration ??
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: lovio.primary.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lovio.accent.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 40,
                      color: lovio.accent,
                    ),
                  ),
                ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium(color: lovio.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              AnimatedPressable(
                onPressed: onActionPressed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: lovio.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: lovio.accent.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.labelLarge(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Branded animated loading pulse widget
class LovioLoadingIndicator extends StatefulWidget {
  final double size;
  final String? message;

  const LovioLoadingIndicator({
    super.key,
    this.size = 56.0,
    this.message,
  });

  @override
  State<LovioLoadingIndicator> createState() => _LovioLoadingIndicatorState();
}

class _LovioLoadingIndicatorState extends State<LovioLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: lovio.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: lovio.accent.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
