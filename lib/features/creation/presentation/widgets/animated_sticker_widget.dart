import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/page_document.dart';

class AnimatedStickerWidget extends StatefulWidget {
  final String symbol;
  final StickerAnimationEffect animation;
  final double size;

  const AnimatedStickerWidget({
    super.key,
    required this.symbol,
    this.animation = StickerAnimationEffect.none,
    this.size = 48,
  });

  @override
  State<AnimatedStickerWidget> createState() => _AnimatedStickerWidgetState();
}

class _AnimatedStickerWidgetState extends State<AnimatedStickerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationForEffect(widget.animation),
    );

    if (widget.animation != StickerAnimationEffect.none) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedStickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _controller.duration = _durationForEffect(widget.animation);
      if (widget.animation == StickerAnimationEffect.none) {
        _controller.stop();
        _controller.value = 0.0;
      } else {
        _controller.repeat();
      }
    }
  }

  Duration _durationForEffect(StickerAnimationEffect effect) {
    switch (effect) {
      case StickerAnimationEffect.floating:
        return const Duration(milliseconds: 2400);
      case StickerAnimationEffect.bouncing:
        return const Duration(milliseconds: 1200);
      case StickerAnimationEffect.rotating:
        return const Duration(milliseconds: 6000);
      case StickerAnimationEffect.sparkling:
        return const Duration(milliseconds: 1400);
      case StickerAnimationEffect.heartbeat:
        return const Duration(milliseconds: 1100);
      case StickerAnimationEffect.none:
        return const Duration(milliseconds: 1000);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textChild = Text(
      widget.symbol,
      style: TextStyle(
        fontSize: widget.size,
        height: 1.1,
      ),
      textAlign: TextAlign.center,
    );

    if (widget.animation == StickerAnimationEffect.none) {
      return textChild;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;

        switch (widget.animation) {
          case StickerAnimationEffect.floating:
            final dy = math.sin(val * math.pi * 2) * 8.0;
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );

          case StickerAnimationEffect.bouncing:
            final scale = 1.0 + 0.22 * math.sin(val * math.pi * 2).abs();
            return Transform.scale(
              scale: scale,
              child: child,
            );

          case StickerAnimationEffect.rotating:
            return Transform.rotate(
              angle: val * math.pi * 2,
              child: child,
            );

          case StickerAnimationEffect.sparkling:
            final scale = 0.9 + 0.25 * math.sin(val * math.pi * 2);
            final opacity = (0.55 + 0.45 * math.cos(val * math.pi * 2)).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );

          case StickerAnimationEffect.heartbeat:
            // Double beat simulation: thump-thump
            double scale = 1.0;
            if (val < 0.15) {
              scale = 1.0 + 0.25 * (val / 0.15);
            } else if (val < 0.3) {
              scale = 1.25 - 0.25 * ((val - 0.15) / 0.15);
            } else if (val < 0.45) {
              scale = 1.0 + 0.15 * ((val - 0.3) / 0.15);
            } else if (val < 0.6) {
              scale = 1.15 - 0.15 * ((val - 0.45) / 0.15);
            }
            return Transform.scale(
              scale: scale,
              child: child,
            );

          case StickerAnimationEffect.none:
            return child!;
        }
      },
      child: textChild,
    );
  }
}

