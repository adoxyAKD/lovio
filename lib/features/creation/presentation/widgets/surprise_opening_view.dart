import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/page_document.dart';

/// Interactive Full-Screen Surprise Envelope & Gift Box Reveal Experience
class SurpriseOpeningView extends StatefulWidget {
  final PageDocument document;
  final VoidCallback onRevealed;
  final VoidCallback onBack;

  const SurpriseOpeningView({
    super.key,
    required this.document,
    required this.onRevealed,
    required this.onBack,
  });

  @override
  State<SurpriseOpeningView> createState() => _SurpriseOpeningViewState();
}

class _SurpriseOpeningViewState extends State<SurpriseOpeningView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _revealController;
  late final AnimationController _ambientController;

  late final Animation<double> _flapAnimation;
  late final Animation<double> _cardRiseAnimation;
  late final Animation<double> _cardScaleAnimation;
  late final Animation<double> _fadeElementsAnimation;
  late final Animation<double> _burstAnimation;

  bool _isOpening = false;
  final List<_ParticleItem> _particles = [];
  final List<_AmbientParticleItem> _ambientParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 1. Gentle continuous pulse for the closed envelope / gift box
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 2. Continuous ambient floating particle animation (Never stops until opened)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // 3. Main reveal sequence controller (1400ms)
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Top flap opening (0.0 to 0.35)
    _flapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeInOutCubic),
      ),
    );

    // Confetti / particle burst (0.25 to 0.85)
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutQuad),
      ),
    );

    // Card slides up from inside envelope (0.35 to 0.80)
    _cardRiseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.35, 0.80, curve: Curves.easeOutBack),
      ),
    );

    // Card expands / scales to full screen (0.70 to 1.0)
    _cardScaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Fade out welcoming title & button (0.0 to 0.30)
    _fadeElementsAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    _revealController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRevealed();
      }
    });

    _generateBurstParticles();
    _generateAmbientParticles();
  }

  void _generateAmbientParticles() {
    final symbols = switch (widget.document.openingStyle) {
      OpeningRevealStyle.luxuryGiftBox => ['✨', '⭐', '🌟', '💖', '💛', '💎'],
      OpeningRevealStyle.floralSurprise => ['🌸', '🌺', '🌷', '✨', '🤍', '🍃'],
      OpeningRevealStyle.midnightStarlight => ['⭐', '✨', '🌟', '💫', '🌙'],
      OpeningRevealStyle.confettiCelebration => ['🎉', '✨', '🎈', '⭐', '🎊'],
      OpeningRevealStyle.secretHeartLock => ['❤️', '💖', '✨', '🔑', '💎'],
      OpeningRevealStyle.crystalGemMagic => ['💎', '✨', '🔮', '💠', '💜'],
      OpeningRevealStyle.cupidArrow => ['🏹', '💘', '❤️', '✨', '💖'],
      OpeningRevealStyle.polaroidMemoryString => ['✨', '💡', '💛', '🌸', '📸'],
      OpeningRevealStyle.elegantLetter => ['📜', '✨', '⚜️', '💌', '🕯️'],
      OpeningRevealStyle.minimalCard => ['✨', '💎', '🔷', '💠', '💫'],
      OpeningRevealStyle.classicEnvelope => ['✉️', '⚜️', '✨', '💌', '🤍'],
      OpeningRevealStyle.romanticPinkEnvelope => ['❤️', '💖', '💕', '✨', '🌸'],
    };

    _ambientParticles.clear();
    for (int i = 0; i < 18; i++) {
      _ambientParticles.add(
        _AmbientParticleItem(
          symbol: symbols[_random.nextInt(symbols.length)],
          initialX: _random.nextDouble(),
          initialY: _random.nextDouble(),
          speed: 0.4 + _random.nextDouble() * 0.8,
          size: 14.0 + _random.nextDouble() * 12.0,
          driftFrequency: 1.0 + _random.nextDouble() * 2.0,
          driftAmplitude: 15.0 + _random.nextDouble() * 25.0,
          opacity: 0.45 + _random.nextDouble() * 0.45,
        ),
      );
    }
  }

  void _generateBurstParticles() {
    final symbols = switch (widget.document.openingStyle) {
      OpeningRevealStyle.luxuryGiftBox => ['✨', '⭐', '🌟', '💖', '💛', '👑', '🎉', '💎'],
      OpeningRevealStyle.floralSurprise => ['🌸', '🌺', '🌷', '✨', '🤍', '🍃', '💕', '💐'],
      OpeningRevealStyle.midnightStarlight => ['⭐', '✨', '🌟', '💫', '🌌', '🌠', '🪐', '🌙'],
      OpeningRevealStyle.confettiCelebration => ['🎉', '🎊', '✨', '🎈', '🍾', '⭐', '🥳', '💥'],
      OpeningRevealStyle.secretHeartLock => ['🔐', '🔑', '❤️', '💖', '✨', '🔒', '💛', '💎'],
      OpeningRevealStyle.crystalGemMagic => ['💎', '✨', '🔮', '💠', '💍', '🌟', '💜', '🪄'],
      OpeningRevealStyle.cupidArrow => ['🏹', '💘', '❤️', '✨', '💖', '🕊️', '🌹', '🎯'],
      OpeningRevealStyle.polaroidMemoryString => ['📷', '✨', '💡', '🎞️', '💛', '🌸', '🪄', '📸'],
      OpeningRevealStyle.elegantLetter => ['📜', '🖋️', '✨', '⚜️', '🕯️', '💌', '👑', '🕊️'],
      OpeningRevealStyle.minimalCard => ['✨', '💎', '🔷', '💠', '💫', '🔹', '✨', '⚡'],
      OpeningRevealStyle.classicEnvelope => ['✉️', '⚜️', '✨', '📜', '🕊️', '💌', '🤍', '⭐'],
      OpeningRevealStyle.romanticPinkEnvelope => ['❤️', '💖', '💕', '✨', '💗', '🌸', '💌', '🌹'],
    };

    _particles.clear();
    for (int i = 0; i < 42; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final distance = 90.0 + _random.nextDouble() * 190.0;
      final symbol = symbols[_random.nextInt(symbols.length)];
      final size = 16.0 + _random.nextDouble() * 20.0;
      final rotation = (_random.nextDouble() - 0.5) * 5;

      _particles.add(_ParticleItem(
        symbol: symbol,
        dx: math.cos(angle) * distance,
        dy: math.sin(angle) * distance - 40,
        size: size,
        rotation: rotation,
      ));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ambientController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _openSurprise() {
    if (_isOpening) return;
    HapticFeedback.heavyImpact();

    // Check reduced motion accessibility
    if (MediaQuery.of(context).disableAnimations) {
      widget.onRevealed();
      return;
    }

    setState(() => _isOpening = true);
    _revealController.forward();
  }

  void _skipImmediately() {
    HapticFeedback.selectionClick();
    if (_revealController.isAnimating) {
      _revealController.value = 1.0;
    }
    widget.onRevealed();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.document.openingStyle;
    final title = widget.document.title.isNotEmpty
        ? widget.document.title
        : 'A Special Card';

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      body: Stack(
        children: [
          // 1. Ambient Background Glow & Gentle Starfield
          Positioned.fill(
            child: _buildAmbientBackground(style),
          ),

          // 2. Main Content Center Stage
          Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Welcoming Header (Fades during opening)
                    FadeTransition(
                      opacity: _fadeElementsAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.15),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  style.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Surprise for You',
                                  style: AppTextStyles.labelMedium(
                                    color: Colors.white.withOpacity(0.95),
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'You have a little surprise! ✨',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineMedium(
                              color: Colors.white,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Someone has created something special for you ❤️',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium(
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          if (title.isNotEmpty && title != 'A Special Card') ...[
                            const SizedBox(height: 4),
                            Text(
                              '“$title”',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall(
                                color: const Color(0xFFFF8DAE),
                              ).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 3. Central Interactive Envelope / Gift Box with continuous breathing float & 3D Reveal
                    GestureDetector(
                      onTap: _isOpening ? _skipImmediately : _openSurprise,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_revealController, _pulseController]),
                        builder: (context, child) {
                          final pulseScale = _isOpening
                              ? 1.0
                              : (1.0 + (_pulseController.value - 0.5) * 0.04);
                          final pulseRotation = _isOpening
                              ? 0.0
                              : ((_pulseController.value - 0.5) * 0.025);

                          return Transform.rotate(
                            angle: pulseRotation,
                            child: Transform.scale(
                              scale: pulseScale,
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // The Envelope or Gift Box Body
                                  _buildEnvelopeOrGiftBox(style),

                                  // Burst Confetti & Particles
                                  if (_isOpening) ..._buildBurstParticles(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 44),

                    // 4. Prominent Pulsing "Open Your Surprise" Button
                    FadeTransition(
                      opacity: _fadeElementsAnimation,
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.96, end: 1.04).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF4B8B).withOpacity(0.55),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isOpening ? null : _openSurprise,
                                icon: Text(
                                  style.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                label: const Text(
                                  'Open Your Surprise',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4B8B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subtle Skip Option
                          TextButton(
                            onPressed: _skipImmediately,
                            child: Text(
                              'Skip animation ➔',
                              style: AppTextStyles.labelMedium(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Minimal Top Left Back Button (To Lovio Home)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    tooltip: 'Back to Home',
                    onPressed: widget.onBack,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Particle Bursts ---
  List<Widget> _buildBurstParticles() {
    final progress = _burstAnimation.value;
    if (progress <= 0.0) return [];

    return _particles.map((p) {
      final currentX = p.dx * progress;
      final currentY = p.dy * progress;
      final currentOpacity = (1.0 - progress).clamp(0.0, 1.0);
      final currentScale = 0.5 + progress * 0.7;

      return Positioned(
        left: 140 + currentX,
        top: 90 + currentY,
        child: Opacity(
          opacity: currentOpacity,
          child: Transform.rotate(
            angle: p.rotation * progress,
            child: Transform.scale(
              scale: currentScale,
              child: Text(
                p.symbol,
                style: TextStyle(fontSize: p.size),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // --- Envelope / Gift Box Visual Engine ---
  Widget _buildEnvelopeOrGiftBox(OpeningRevealStyle style) {
    switch (style) {
      case OpeningRevealStyle.luxuryGiftBox:
        return _buildLuxuryGiftBoxWidget();
      case OpeningRevealStyle.floralSurprise:
        return _buildFloralSurpriseWidget();
      case OpeningRevealStyle.classicEnvelope:
        return _buildClassicParchmentEnvelopeWidget();
      case OpeningRevealStyle.elegantLetter:
        return _buildElegantScrollWidget();
      case OpeningRevealStyle.minimalCard:
        return _buildMinimalCardWidget();
      case OpeningRevealStyle.midnightStarlight:
        return _buildMidnightStarlightWidget();
      case OpeningRevealStyle.confettiCelebration:
        return _buildConfettiCelebrationWidget();
      case OpeningRevealStyle.secretHeartLock:
        return _buildSecretHeartLockWidget();
      case OpeningRevealStyle.crystalGemMagic:
        return _buildCrystalGemMagicWidget();
      case OpeningRevealStyle.cupidArrow:
        return _buildCupidArrowWidget();
      case OpeningRevealStyle.polaroidMemoryString:
        return _buildPolaroidGarlandWidget();
      case OpeningRevealStyle.romanticPinkEnvelope:
      default:
        return _buildRomanticPinkEnvelopeWidget();
    }
  }

  // 1. Romantic Pink Envelope
  Widget _buildRomanticPinkEnvelopeWidget() {
    final flapValue = _flapAnimation.value; // 0.0 to 1.0
    final flapAngle = flapValue * math.pi; // 0 to 180 degrees
    final cardOffset = -_cardRiseAnimation.value * 120.0;

    return SizedBox(
      width: 290,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Envelope Backing (Darker Pink inside)
          Container(
            width: 280,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFC74375),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          // Emerging Card Preview (Inside)
          Positioned(
            top: 20 + cardOffset,
            child: Transform.scale(
              scale: 0.92 + (_cardScaleAnimation.value - 0.65) * 0.2,
              child: Container(
                width: 250,
                height: 155,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF0F5), Color(0xFFFFD6E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💌', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      widget.document.title.isNotEmpty
                          ? widget.document.title
                          : 'A Special Message',
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF882D4B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Envelope Lower Pocket (Triangular fold)
          Positioned(
            bottom: 10,
            child: CustomPaint(
              size: const Size(280, 110),
              painter: _EnvelopePocketPainter(
                color: const Color(0xFFFF5C98),
                borderColor: const Color(0xFFFF85B3),
              ),
            ),
          ),

          // Top Flap with 3D Perspective Rotation
          Positioned(
            top: 10,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateX(-flapAngle),
              child: CustomPaint(
                size: const Size(280, 95),
                painter: _EnvelopeFlapPainter(
                  color: flapValue > 0.5
                      ? const Color(0xFFC74375)
                      : const Color(0xFFFF4B8B),
                  borderColor: const Color(0xFFFF75A0),
                  isUpsideDown: flapValue > 0.5,
                ),
              ),
            ),
          ),

          // Wax Heart Seal (Fades & scales down when flap opens)
          if (flapValue < 0.3)
            Positioned(
              top: 80,
              child: Opacity(
                opacity: (1.0 - flapValue * 3.3).clamp(0.0, 1.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFFFF1BD), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('❤️', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 2. Luxury Gift Box
  Widget _buildLuxuryGiftBoxWidget() {
    final lidOffset = -_flapAnimation.value * 110.0;
    final cardOffset = -_cardRiseAnimation.value * 100.0;

    return SizedBox(
      width: 260,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Emerging Card
          Positioned(
            top: 30 + cardOffset,
            child: Container(
              width: 210,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBF0), Color(0xFFFFE8B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
              ),
              child: const Center(
                child: Text('🎁 Special Gift',
                    style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4100))),
              ),
            ),
          ),

          // Box Base
          Positioned(
            bottom: 10,
            child: Container(
              width: 240,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF581C87), Color(0xFF3B0764)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vertical Golden Ribbon
                  Container(
                    width: 32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Box Lid (Translates up & rotates slightly)
          Positioned(
            top: 40 + lidOffset,
            child: Transform.rotate(
              angle: -_flapAnimation.value * 0.12,
              child: Container(
                width: 256,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF4C1D95)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 4))
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Horizontal Ribbon
                    Container(
                      height: 14,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                        ),
                      ),
                    ),
                    // Ribbon Bow on top
                    Positioned(
                      top: -18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Text('🎀', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Classic Parchment Envelope
  Widget _buildClassicParchmentEnvelopeWidget() {
    final flapAngle = _flapAnimation.value * math.pi;
    final cardOffset = -_cardRiseAnimation.value * 110.0;

    return SizedBox(
      width: 290,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 280,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFD7CCC8),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // Emerging Card
          Positioned(
            top: 20 + cardOffset,
            child: Container(
              width: 250,
              height: 155,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✉️', style: TextStyle(fontSize: 26)),
                  SizedBox(height: 6),
                  Text('A Cherished Letter',
                      style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723))),
                ],
              ),
            ),
          ),

          // Bottom Pocket
          Positioned(
            bottom: 10,
            child: CustomPaint(
              size: const Size(280, 110),
              painter: _EnvelopePocketPainter(
                color: const Color(0xFFEFEBE9),
                borderColor: const Color(0xFFD7CCC8),
              ),
            ),
          ),

          // Flap
          Positioned(
            top: 10,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateX(-flapAngle),
              child: CustomPaint(
                size: const Size(280, 95),
                painter: _EnvelopeFlapPainter(
                  color: _flapAnimation.value > 0.5
                      ? const Color(0xFFD7CCC8)
                      : const Color(0xFFF5F5F5),
                  borderColor: const Color(0xFFBCAAA4),
                  isUpsideDown: _flapAnimation.value > 0.5,
                ),
              ),
            ),
          ),

          // Crimson Wax Seal
          if (_flapAnimation.value < 0.3)
            Positioned(
              top: 80,
              child: Opacity(
                opacity: (1.0 - _flapAnimation.value * 3.3).clamp(0.0, 1.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⚜️', style: TextStyle(fontSize: 18, color: Colors.amber)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 4. Floral Blossom Surprise
  Widget _buildFloralSurpriseWidget() {
    final flapValue = _flapAnimation.value;
    return SizedBox(
      width: 290,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _buildRomanticPinkEnvelopeWidget(),
          // Encircling Blossom Accents that bloom open
          Positioned(
            left: -14 - (flapValue * 12),
            top: -14 - (flapValue * 12),
            child: Transform.rotate(
              angle: flapValue * 0.4,
              child: const Text('🌸', style: TextStyle(fontSize: 34)),
            ),
          ),
          Positioned(
            right: -14 - (flapValue * 12),
            top: -10 - (flapValue * 10),
            child: Transform.rotate(
              angle: -flapValue * 0.4,
              child: const Text('🌺', style: TextStyle(fontSize: 30)),
            ),
          ),
          Positioned(
            left: -10 - (flapValue * 10),
            bottom: -6 - (flapValue * 10),
            child: const Text('🌷', style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            right: -10 - (flapValue * 10),
            bottom: -6 - (flapValue * 10),
            child: const Text('💐', style: TextStyle(fontSize: 30)),
          ),
        ],
      ),
    );
  }

  // 5. Elegant Antique Royal Scroll
  Widget _buildElegantScrollWidget() {
    final scrollOpen = _flapAnimation.value; // 0.0 to 1.0
    final cardOffset = -_cardRiseAnimation.value * 115.0;

    return SizedBox(
      width: 280,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Emerging Message inside Scroll
          Positioned(
            top: 25 + cardOffset,
            child: Container(
              width: 240,
              height: 150,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF6EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 14, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📜', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Royal Letter',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3525),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Antique Parchment Body
          Container(
            width: 260,
            height: 120 + (scrollOpen * 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8D8C3), Color(0xFFD7C2A6), Color(0xFFE8D8C3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (scrollOpen < 0.3)
                  Opacity(
                    opacity: (1.0 - scrollOpen * 3.3).clamp(0.0, 1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚜️', style: TextStyle(fontSize: 24, color: Color(0xFF78350F))),
                        const SizedBox(height: 4),
                        Text(
                          'ROYAL MISSIVE',
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: const Color(0xFF5D4037).withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Top Wooden Roller Rod
          Positioned(
            top: 25 - (scrollOpen * 45),
            child: Container(
              width: 278,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF3E2723)],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
              ),
            ),
          ),

          // Bottom Wooden Roller Rod
          Positioned(
            bottom: 25 - (scrollOpen * 45),
            child: Container(
              width: 278,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF3E2723)],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
              ),
            ),
          ),

          // Crimson Ribbon & Seal (Dissolves when opened)
          if (scrollOpen < 0.25)
            Positioned(
              child: Opacity(
                opacity: (1.0 - scrollOpen * 4.0).clamp(0.0, 1.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF881337),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 6. Modern Minimal Origami Card
  Widget _buildMinimalCardWidget() {
    final flapValue = _flapAnimation.value;
    final cardOffset = -_cardRiseAnimation.value * 110.0;

    return SizedBox(
      width: 280,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Emerging Cyber-Glass Card
          Positioned(
            top: 20 + cardOffset,
            child: Container(
              width: 250,
              height: 155,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Special Reveal',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Modern Geometric Envelope Pocket
          Positioned(
            bottom: 10,
            child: Container(
              width: 270,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // Modern Geometric Flap
          Positioned(
            top: 20,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateX(-flapValue * math.pi),
              child: Container(
                width: 270,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                ),
                child: Center(
                  child: flapValue < 0.3
                      ? const Text('💎', style: TextStyle(fontSize: 22))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Midnight Constellation Starlight
  Widget _buildMidnightStarlightWidget() {
    final flapValue = _flapAnimation.value;
    final cardOffset = -_cardRiseAnimation.value * 115.0;

    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Stardust Constellation Ring (Pulse & Rotate)
          Transform.rotate(
            angle: _pulseController.value * math.pi * 0.1,
            child: Container(
              width: 270,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF38BDF8).withOpacity(0.35),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Emerging Starlight Card
          Positioned(
            top: 25 + cardOffset,
            child: Container(
              width: 245,
              height: 155,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.4),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌌', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Starbound Wish',
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Celestial Shell Back & Front (splits open)
          Positioned(
            bottom: 10,
            child: Container(
              width: 260,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(left: 18, top: 18, child: Text('✨', style: TextStyle(fontSize: 14))),
                  Positioned(right: 20, top: 26, child: Text('⭐', style: TextStyle(fontSize: 12))),
                  Positioned(left: 40, bottom: 20, child: Text('💫', style: TextStyle(fontSize: 13))),
                  Positioned(right: 36, bottom: 18, child: Text('🪐', style: TextStyle(fontSize: 15))),
                ],
              ),
            ),
          ),

          // Celestial Flap
          Positioned(
            top: 15,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateX(-flapValue * math.pi),
              child: Container(
                width: 260,
                height: 85,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                ),
                child: Center(
                  child: flapValue < 0.3
                      ? const Text('🌙', style: TextStyle(fontSize: 26))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 8. Confetti Celebration Blast Box
  Widget _buildConfettiCelebrationWidget() {
    final lidOffset = -_flapAnimation.value * 125.0;
    final cardOffset = -_cardRiseAnimation.value * 105.0;

    return SizedBox(
      width: 270,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Emerging Party Card
          Positioned(
            top: 30 + cardOffset,
            child: Container(
              width: 225,
              height: 145,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Celebration!',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF78350F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Party Box Body
          Positioned(
            bottom: 10,
            child: Container(
              width: 250,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gold Celebration Ribbon Strip
                  Container(
                    width: 36,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Jumping Party Lid
          Positioned(
            top: 40 + lidOffset,
            child: Transform.rotate(
              angle: -_flapAnimation.value * 0.2,
              child: Container(
                width: 266,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF87171), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 14)],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 14,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: -18,
                      child: Text('🎊', style: TextStyle(fontSize: 28)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 9. Secret Heart Padlock & Key
  Widget _buildSecretHeartLockWidget() {
    final flapValue = _flapAnimation.value;
    final cardOffset = -_cardRiseAnimation.value * 115.0;
    final keyRotation = flapValue * math.pi * 0.5; // 0 to 90 deg key turn
    final doorSwing = flapValue * math.pi * 0.45;

    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Padlock Shackle Loop (at the top)
          Positioned(
            top: 15 - (flapValue * 25),
            child: Container(
              width: 130,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(65)),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 14,
                ),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
              ),
            ),
          ),

          // Emerging Hidden Card
          Positioned(
            top: 30 + cardOffset,
            child: Container(
              width: 240,
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF43F5E), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 14)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔐', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Unlocked Secret',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF881337),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Golden Padlock Left Door (Swings open)
          Positioned(
            left: 20,
            bottom: 10,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(-doorSwing),
              child: Container(
                width: 120,
                height: 145,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 14)],
                ),
                child: const Center(
                  child: Text('❤️', style: TextStyle(fontSize: 26)),
                ),
              ),
            ),
          ),

          // Golden Padlock Right Door (Swings open)
          Positioned(
            right: 20,
            bottom: 10,
            child: Transform(
              alignment: Alignment.centerRight,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(doorSwing),
              child: Container(
                width: 120,
                height: 145,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFB45309)],
                  ),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 14)],
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ),

          // Golden Key in the center keyway (Turns and fades)
          if (flapValue < 0.5)
            Positioned(
              bottom: 60,
              child: Opacity(
                opacity: (1.0 - flapValue * 2.0).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: keyRotation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
                    ),
                    child: const Text('🔑', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 10. Crystal Prism Gemstone
  Widget _buildCrystalGemMagicWidget() {
    final flapValue = _flapAnimation.value;
    final cardOffset = -_cardRiseAnimation.value * 115.0;

    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Emerging Crystal Card
          Positioned(
            top: 25 + cardOffset,
            child: Container(
              width: 240,
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F2FE), Color(0xFFF3E8FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💎', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Crystal Gem',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C4A6E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Prismatic Gem Body
          Positioned(
            bottom: 10,
            child: Transform.scale(
              scale: 1.0 - (flapValue * 0.15),
              child: Container(
                width: 240,
                height: 145,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.7),
                      const Color(0xFFA855F7).withOpacity(0.7),
                      const Color(0xFFEC4899).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white70, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withOpacity(0.5),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: Center(
                  child: flapValue < 0.3
                      ? const Text('🔮', style: TextStyle(fontSize: 34))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 11. Cupid's Love Arrow
  Widget _buildCupidArrowWidget() {
    final flapValue = _flapAnimation.value;
    final cardOffset = -_cardRiseAnimation.value * 115.0;
    final arrowFlight = (1.0 - flapValue) * 160.0;

    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Emerging Message Card
          Positioned(
            top: 25 + cardOffset,
            child: Container(
              width: 245,
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF1F2), Color(0xFFFFD1DC)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE11D48), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 14)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💘', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Love Arrow',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F1239),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Winged Heart Shield Base
          Positioned(
            bottom: 10,
            child: Container(
              width: 255,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(left: 14, child: Text('🪽', style: TextStyle(fontSize: 34))),
                  Positioned(right: 14, child: Text('🪽', style: TextStyle(fontSize: 34))),
                  Text('❤️', style: TextStyle(fontSize: 42)),
                ],
              ),
            ),
          ),

          // Cupid's Golden Arrow flying across
          if (flapValue < 0.6)
            Positioned(
              left: 120 - arrowFlight,
              bottom: 65,
              child: Opacity(
                opacity: (1.0 - flapValue * 1.6).clamp(0.0, 1.0),
                child: const Text('🏹', style: TextStyle(fontSize: 34)),
              ),
            ),
        ],
      ),
    );
  }

  // 12. Fairy-Lit Polaroid Memory Garland
  Widget _buildPolaroidGarlandWidget() {
    final flapValue = _flapAnimation.value;
    final cardOffset = -_cardRiseAnimation.value * 115.0;
    final splitDistance = flapValue * 65.0;

    return SizedBox(
      width: 290,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Fairy Light Garland Twine Line
          Positioned(
            top: 25,
            child: Container(
              width: 280,
              height: 2,
              color: const Color(0xFFD97706),
            ),
          ),

          // Fairy Light Bulbs
          const Positioned(top: 15, left: 24, child: Text('💡', style: TextStyle(fontSize: 16))),
          const Positioned(top: 15, left: 100, child: Text('✨', style: TextStyle(fontSize: 16))),
          const Positioned(top: 15, right: 100, child: Text('💡', style: TextStyle(fontSize: 16))),
          const Positioned(top: 15, right: 24, child: Text('✨', style: TextStyle(fontSize: 16))),

          // Emerging Main Card
          Positioned(
            top: 30 + cardOffset,
            child: Container(
              width: 245,
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 14)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📷', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    widget.document.title.isNotEmpty ? widget.document.title : 'Captured Moment',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF78350F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Left Hanging Polaroid (Glides left on twine)
          Positioned(
            left: 20 - splitDistance,
            top: 28,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 100,
                height: 130,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 80,
                      color: const Color(0xFFFFD1DC),
                      child: const Center(child: Text('📸', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(height: 8),
                    const Text('Memories', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),

          // Right Hanging Polaroid (Glides right on twine)
          Positioned(
            right: 20 - splitDistance,
            top: 28,
            child: Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 100,
                height: 130,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 80,
                      color: const Color(0xFFFEF3C7),
                      child: const Center(child: Text('💛', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(height: 8),
                    const Text('With Love', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ambient Starfield & Glow Tailored to Chosen Style
  Widget _buildAmbientBackground(OpeningRevealStyle style) {
    final (baseColor, glowPrimary, glowSecondary) = switch (style) {
      OpeningRevealStyle.midnightStarlight => (
          const Color(0xFF04060F),
          const Color(0xFF38BDF8),
          const Color(0xFF6366F1)
        ),
      OpeningRevealStyle.secretHeartLock => (
          const Color(0xFF0F0407),
          const Color(0xFFE11D48),
          const Color(0xFFF59E0B)
        ),
      OpeningRevealStyle.crystalGemMagic => (
          const Color(0xFF050814),
          const Color(0xFF06B6D4),
          const Color(0xFFA855F7)
        ),
      OpeningRevealStyle.confettiCelebration => (
          const Color(0xFF0F0804),
          const Color(0xFFF59E0B),
          const Color(0xFFEF4444)
        ),
      OpeningRevealStyle.cupidArrow => (
          const Color(0xFF0F0407),
          const Color(0xFFF43F5E),
          const Color(0xFFFB7185)
        ),
      OpeningRevealStyle.polaroidMemoryString => (
          const Color(0xFF0D0A07),
          const Color(0xFFFBBF24),
          const Color(0xFFFB923C)
        ),
      OpeningRevealStyle.elegantLetter => (
          const Color(0xFF0D0B09),
          const Color(0xFFD97706),
          const Color(0xFF92400E)
        ),
      OpeningRevealStyle.floralSurprise => (
          const Color(0xFF0E050A),
          const Color(0xFFF472B6),
          const Color(0xFF34D399)
        ),
      OpeningRevealStyle.luxuryGiftBox => (
          const Color(0xFF0A0413),
          const Color(0xFF9333EA),
          const Color(0xFFF59E0B)
        ),
      OpeningRevealStyle.minimalCard => (
          const Color(0xFF040A14),
          const Color(0xFF38BDF8),
          const Color(0xFF818CF8)
        ),
      OpeningRevealStyle.classicEnvelope => (
          const Color(0xFF0E0A08),
          const Color(0xFFD97706),
          const Color(0xFFB45309)
        ),
      OpeningRevealStyle.romanticPinkEnvelope => (
          const Color(0xFF0E050A),
          const Color(0xFFFF4B8B),
          const Color(0xFF7C3AED)
        ),
    };

    return Stack(
      children: [
        Container(color: baseColor),
        Center(
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowPrimary.withOpacity(0.24),
                  glowSecondary.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Continuous ambient floating particles (Twinkles until opened)
        AnimatedBuilder(
          animation: _ambientController,
          builder: (context, _) {
            final t = _ambientController.value;
            final size = MediaQuery.of(context).size;
            return Stack(
              children: _ambientParticles.map((p) {
                final yPos = ((p.initialY - (t * p.speed)) % 1.0) * size.height;
                final xOffset = math.sin((t * 2 * math.pi * p.driftFrequency) + (p.initialX * 10)) * p.driftAmplitude;
                final xPos = (p.initialX * size.width + xOffset).clamp(0.0, math.max(0.0, size.width - 24));
                final currentOpacity = (p.opacity * (0.6 + 0.4 * math.sin(t * 2 * math.pi + p.initialX * 5))).clamp(0.1, 1.0);

                return Positioned(
                  left: xPos,
                  top: yPos,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: currentOpacity,
                      child: Text(
                        p.symbol,
                        style: TextStyle(fontSize: p.size),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AmbientParticleItem {
  final String symbol;
  final double initialX;
  final double initialY;
  final double speed;
  final double size;
  final double driftFrequency;
  final double driftAmplitude;
  final double opacity;

  _AmbientParticleItem({
    required this.symbol,
    required this.initialX,
    required this.initialY,
    required this.speed,
    required this.size,
    required this.driftFrequency,
    required this.driftAmplitude,
    required this.opacity,
  });
}

class _ParticleItem {
  final String symbol;
  final double dx;
  final double dy;
  final double size;
  final double rotation;

  _ParticleItem({
    required this.symbol,
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
  });
}

// Custom Painter for Envelope Pocket (Bottom & Sides)
class _EnvelopePocketPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _EnvelopePocketPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height * 0.58);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _EnvelopePocketPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderColor != borderColor;
}

// Custom Painter for Envelope Top Flap
class _EnvelopeFlapPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool isUpsideDown;

  _EnvelopeFlapPainter({
    required this.color,
    required this.borderColor,
    this.isUpsideDown = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (!isUpsideDown) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
      path.close();
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width / 2, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _EnvelopeFlapPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.isUpsideDown != isUpsideDown;
}
