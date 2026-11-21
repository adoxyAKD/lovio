import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/page_document.dart';

class PageAnimatedBackground extends StatefulWidget {
  final PageBackgroundConfig config;
  final Widget? child;

  const PageAnimatedBackground({
    super.key,
    required this.config,
    this.child,
  });

  @override
  State<PageAnimatedBackground> createState() => _PageAnimatedBackgroundState();
}

class _PageAnimatedBackgroundState extends State<PageAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    BoxDecoration decoration;
    if (config.type == PageBackgroundType.solid) {
      decoration = BoxDecoration(
        color: Color(config.solidColor),
      );
    } else {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradientColors.map((c) => Color(c)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    final hasAnimation = config.type == PageBackgroundType.animated ||
        config.animationEffect != BackgroundAnimationEffect.none;

    return Container(
      decoration: decoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasAnimation)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BackgroundParticlePainter(
                    effect: config.animationEffect,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double rotationSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.rotationSpeed,
  });
}

class _BackgroundParticlePainter extends CustomPainter {
  final BackgroundAnimationEffect effect;
  final double progress;

  static final List<_Particle> _petals = List.generate(24, (i) {
    final r = math.Random(i * 137);
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: 8.0 + r.nextDouble() * 10.0,
      speed: 0.6 + r.nextDouble() * 0.8,
      phase: r.nextDouble() * math.pi * 2,
      rotationSpeed: (r.nextDouble() - 0.5) * 2.5,
    );
  });

  static final List<_Particle> _stars = List.generate(36, (i) {
    final r = math.Random(i * 251);
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: 2.0 + r.nextDouble() * 4.0,
      speed: 0.2 + r.nextDouble() * 0.4,
      phase: r.nextDouble() * math.pi * 2,
      rotationSpeed: 0,
    );
  });

  static final List<_Particle> _hearts = List.generate(20, (i) {
    final r = math.Random(i * 311);
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: 10.0 + r.nextDouble() * 12.0,
      speed: 0.4 + r.nextDouble() * 0.6,
      phase: r.nextDouble() * math.pi * 2,
      rotationSpeed: (r.nextDouble() - 0.5) * 1.5,
    );
  });

  static final List<_Particle> _sparkles = List.generate(28, (i) {
    final r = math.Random(i * 409);
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: 3.0 + r.nextDouble() * 5.0,
      speed: 0.5 + r.nextDouble() * 0.7,
      phase: r.nextDouble() * math.pi * 2,
      rotationSpeed: (r.nextDouble() - 0.5) * 3,
    );
  });

  _BackgroundParticlePainter({
    required this.effect,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (effect) {
      case BackgroundAnimationEffect.floatingPetals:
        _paintPetals(canvas, size, const Color(0xFFFFB7C5));
        break;
      case BackgroundAnimationEffect.rosePetalDrift:
        _paintPetals(canvas, size, const Color(0xFFE53935));
        break;
      case BackgroundAnimationEffect.starryNight:
        _paintStars(canvas, size);
        break;
      case BackgroundAnimationEffect.pulsatingHearts:
        _paintHearts(canvas, size);
        break;
      case BackgroundAnimationEffect.glowingParticles:
        _paintSparkles(canvas, size);
        break;
      case BackgroundAnimationEffect.softGlow:
        _paintSoftGlow(canvas, size);
        break;
      case BackgroundAnimationEffect.auroraWaves:
        _paintAuroraWaves(canvas, size);
        break;
      case BackgroundAnimationEffect.floatingBubbles:
        _paintBubbles(canvas, size);
        break;
      case BackgroundAnimationEffect.confettiCelebration:
        _paintConfetti(canvas, size);
        break;
      case BackgroundAnimationEffect.snowfallRomance:
        _paintSnowfall(canvas, size);
        break;
      case BackgroundAnimationEffect.firefliesMagic:
        _paintFireflies(canvas, size);
        break;
      case BackgroundAnimationEffect.bokehShimmer:
        _paintBokeh(canvas, size);
        break;
      case BackgroundAnimationEffect.none:
        break;
    }
  }

  void _paintPetals(Canvas canvas, Size size, Color petalColor) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _petals) {
      final currentY = ((p.y + progress * p.speed) % 1.2) * size.height - 20;
      final sway = math.sin(progress * math.pi * 4 + p.phase) * 20.0;
      final currentX = ((p.x * size.width + sway) % size.width);
      final currentAngle = progress * math.pi * 2 * p.rotationSpeed + p.phase;

      paint.color = petalColor.withOpacity(0.55);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentAngle);

      final path = Path();
      path.moveTo(0, -p.size);
      path.quadraticBezierTo(p.size * 0.8, -p.size * 0.3, p.size * 0.5, p.size);
      path.quadraticBezierTo(0, p.size * 0.7, -p.size * 0.5, p.size);
      path.quadraticBezierTo(-p.size * 0.8, -p.size * 0.3, 0, -p.size);
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _paintSoftGlow(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.45;
    final pulse = 0.85 + 0.15 * math.sin(progress * math.pi * 2);
    final radius = math.max(size.width, size.height) * 0.55 * pulse;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.28),
          Colors.pinkAccent.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  void _paintAuroraWaves(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    for (int wave = 0; wave < 3; wave++) {
      final waveProgress = (progress + wave * 0.33) % 1.0;
      final waveY = h * 0.3 + wave * (h * 0.15);
      final path = Path()..moveTo(0, waveY);

      for (double x = 0; x <= w; x += 20) {
        final y = waveY +
            math.sin((x / w * 4 * math.pi) + (waveProgress * 2 * math.pi)) * 24;
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();

      paint.color = (wave == 0
              ? const Color(0xFF00F5D4)
              : wave == 1
                  ? const Color(0xFF7B2CBF)
                  : const Color(0xFFFF70A6))
          .withOpacity(0.08);

      canvas.drawPath(path, paint);
    }
  }

  void _paintBubbles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;

    for (final p in _hearts) {
      final currentY = (1.1 - ((p.y + progress * p.speed * 0.7) % 1.2)) * size.height;
      final sway = math.sin(progress * math.pi * 2 + p.phase) * 14.0;
      final currentX = ((p.x * size.width + sway) % size.width);
      final r = p.size * 0.9;

      paint.color = Colors.white.withOpacity(0.4);
      canvas.drawCircle(Offset(currentX, currentY), r, paint);

      // Bubble highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX - r * 0.35, currentY - r * 0.35), r * 0.22, highlightPaint);
    }
  }

  void _paintConfetti(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = [
      const Color(0xFFFF595E),
      const Color(0xFFFFCA3A),
      const Color(0xFF8AC926),
      const Color(0xFF1982C4),
      const Color(0xFF6A4C93),
    ];

    for (int i = 0; i < _sparkles.length; i++) {
      final p = _sparkles[i];
      final currentY = ((p.y + progress * p.speed * 1.4) % 1.2) * size.height - 20;
      final currentX = ((p.x * size.width + math.sin(progress * 6 + p.phase) * 18) % size.width);
      final rot = progress * math.pi * 4 * p.rotationSpeed + p.phase;

      paint.color = colors[i % colors.length].withOpacity(0.75);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rot);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size * 1.4, height: p.size * 0.7), paint);
      canvas.restore();
    }
  }

  void _paintSnowfall(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _stars) {
      final currentY = ((p.y + progress * p.speed * 0.8) % 1.2) * size.height - 10;
      final sway = math.sin(progress * math.pi * 3 + p.phase) * 12.0;
      final currentX = ((p.x * size.width + sway) % size.width);

      paint.color = Colors.white.withOpacity(0.65);
      canvas.drawCircle(Offset(currentX, currentY), p.size * 0.7, paint);
    }
  }

  void _paintFireflies(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _sparkles) {
      final swayX = math.sin(progress * 3 + p.phase) * 25.0;
      final swayY = math.cos(progress * 2 + p.phase) * 20.0;
      final currentX = ((p.x * size.width + swayX) % size.width);
      final currentY = ((p.y * size.height + swayY) % size.height);
      final glow = 0.4 + 0.6 * math.sin(progress * math.pi * 4 + p.phase).abs();

      paint.color = const Color(0xFFE2F952).withOpacity(glow * 0.8);
      canvas.drawCircle(Offset(currentX, currentY), p.size * 0.8, paint);

      final haloPaint = Paint()
        ..color = const Color(0xFFC7F464).withOpacity(glow * 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), p.size * 2.2, haloPaint);
    }
  }

  void _paintBokeh(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _hearts) {
      final currentY = (1.1 - ((p.y + progress * p.speed * 0.3) % 1.2)) * size.height;
      final currentX = p.x * size.width;
      final pulse = 0.15 + 0.12 * math.sin(progress * math.pi * 2 + p.phase);

      paint.color = Colors.white.withOpacity(pulse.clamp(0.05, 0.3));
      canvas.drawCircle(Offset(currentX, currentY), p.size * 2.5, paint);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _stars) {
      final opacity =
          ((math.sin(progress * math.pi * 6 + p.phase) + 1.0) / 2.0) * 0.7 +
              0.2;
      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));

      final x = p.x * size.width;
      final y = p.y * size.height;

      canvas.drawCircle(Offset(x, y), p.size / 2, paint);

      // Star sparkle cross
      if (p.size > 3.5) {
        final strokePaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.7)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
            Offset(x - p.size, y), Offset(x + p.size, y), strokePaint);
        canvas.drawLine(
            Offset(x, y - p.size), Offset(x, y + p.size), strokePaint);
      }
    }
  }

  void _paintHearts(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _hearts) {
      // Floating upwards
      final currentY =
          (1.1 - ((p.y + progress * p.speed) % 1.2)) * size.height;
      final sway = math.sin(progress * math.pi * 3 + p.phase) * 16.0;
      final currentX = ((p.x * size.width + sway) % size.width);
      final pulse = 1.0 + 0.15 * math.sin(progress * math.pi * 6 + p.phase);

      paint.color = const Color(0xFFFF6B8B).withOpacity(0.4);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.scale(pulse, pulse);

      final path = Path();
      final s = p.size;
      path.moveTo(0, s * 0.3);
      path.cubicTo(-s * 0.5, -s * 0.4, -s, s * 0.1, 0, s);
      path.cubicTo(s, s * 0.1, s * 0.5, -s * 0.4, 0, s * 0.3);
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _paintSparkles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _sparkles) {
      final currentY =
          (1.1 - ((p.y + progress * p.speed) % 1.2)) * size.height;
      final currentX =
          ((p.x * size.width + math.sin(progress * 4 + p.phase) * 12) %
              size.width);
      final opacity =
          ((math.sin(progress * math.pi * 8 + p.phase) + 1.0) / 2.0) * 0.75 +
              0.2;

      paint.color = const Color(0xFFFFD700).withOpacity(opacity.clamp(0.0, 0.9));

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(progress * math.pi * 2 * p.rotationSpeed);

      final r = p.size;
      final path = Path();
      path.moveTo(0, -r * 1.5);
      path.quadraticBezierTo(0, 0, r * 1.5, 0);
      path.quadraticBezierTo(0, 0, 0, r * 1.5);
      path.quadraticBezierTo(0, 0, -r * 1.5, 0);
      path.quadraticBezierTo(0, 0, 0, -r * 1.5);
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.effect != effect;
  }
}

