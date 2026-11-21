import 'dart:ui';
import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// Translucent frosted glass container with smooth borders and blur
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.gradient,
    this.border,
    this.padding,
    this.margin,
    this.shadows,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final isDark = context.isDarkMode;

    final defaultGradient = gradient ??
        (color == null
            ? (isDark ? lovio.cardGlassGradient : lovio.cardGlassGradient)
            : null);

    final defaultBorder = border ??
        Border.all(
          color: (isDark ? Colors.white : Colors.white)
              .withOpacity(isDark ? 0.08 : 0.6),
          width: 1.2,
        );

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        gradient: defaultGradient,
        borderRadius: borderRadius,
        border: defaultBorder,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (blur <= 0) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );
  }
}
