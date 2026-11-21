enum PageElementType {
  text,
  photo,
  sticker,
  decorative;

  String get name => toString().split('.').last;
}

enum PhotoShape {
  rectangle,
  circle,
  roundedRectangle,
  oval,
  heart,
  star,
  hexagon,
  diamond,
  arch,
  polaroidFrame,
  tornPaperFrame,
  organicBlob,
  stampFrame,
  ornateFrame,
  vintageFrame,
  scallopedFrame,
  cloud;

  String get label {
    switch (this) {
      case PhotoShape.rectangle:
        return 'Square / Rect';
      case PhotoShape.circle:
        return 'Circular';
      case PhotoShape.roundedRectangle:
        return 'Rounded';
      case PhotoShape.oval:
        return 'Oval Frame';
      case PhotoShape.heart:
        return 'Heart';
      case PhotoShape.star:
        return 'Star Frame';
      case PhotoShape.hexagon:
        return 'Hexagon';
      case PhotoShape.diamond:
        return 'Diamond';
      case PhotoShape.arch:
        return 'Romantic Arch';
      case PhotoShape.polaroidFrame:
        return 'Polaroid';
      case PhotoShape.tornPaperFrame:
        return 'Torn Paper Frame';
      case PhotoShape.organicBlob:
        return 'Organic / Blob';
      case PhotoShape.stampFrame:
        return 'Post Stamp';
      case PhotoShape.ornateFrame:
        return 'Ornate Frame';
      case PhotoShape.vintageFrame:
        return 'Vintage Frame';
      case PhotoShape.scallopedFrame:
        return 'Scalloped';
      case PhotoShape.cloud:
        return 'Cloud Frame';
    }
  }

  String get name => toString().split('.').last;
}

enum StickerAnimationEffect {
  none,
  floating,
  bouncing,
  rotating,
  sparkling,
  heartbeat;

  String get label {
    switch (this) {
      case StickerAnimationEffect.none:
        return 'Static';
      case StickerAnimationEffect.floating:
        return 'Floating ☁️';
      case StickerAnimationEffect.bouncing:
        return 'Bouncing 🎈';
      case StickerAnimationEffect.rotating:
        return 'Rotating 💫';
      case StickerAnimationEffect.sparkling:
        return 'Sparkling ✨';
      case StickerAnimationEffect.heartbeat:
        return 'Heartbeat 💓';
    }
  }

  String get name => toString().split('.').last;
}

enum BackgroundAnimationEffect {
  none,
  floatingPetals,
  starryNight,
  pulsatingHearts,
  glowingParticles,
  softGlow,
  auroraWaves,
  floatingBubbles,
  confettiCelebration,
  rosePetalDrift,
  snowfallRomance,
  firefliesMagic,
  bokehShimmer;

  String get label {
    switch (this) {
      case BackgroundAnimationEffect.none:
        return 'Static';
      case BackgroundAnimationEffect.floatingPetals:
        return 'Falling Petals 🌸';
      case BackgroundAnimationEffect.starryNight:
        return 'Starry Night ✨';
      case BackgroundAnimationEffect.pulsatingHearts:
        return 'Floating Hearts 💕';
      case BackgroundAnimationEffect.glowingParticles:
        return 'Golden Sparkles 🌟';
      case BackgroundAnimationEffect.softGlow:
        return 'Soft Warm Glow 💡';
      case BackgroundAnimationEffect.auroraWaves:
        return 'Aurora Waves 🌊';
      case BackgroundAnimationEffect.floatingBubbles:
        return 'Pastel Bubbles 🫧';
      case BackgroundAnimationEffect.confettiCelebration:
        return 'Celebration Confetti 🎉';
      case BackgroundAnimationEffect.rosePetalDrift:
        return 'Red Rose Drift 🌹';
      case BackgroundAnimationEffect.snowfallRomance:
        return 'Soft Snowfall ❄️';
      case BackgroundAnimationEffect.firefliesMagic:
        return 'Magical Fireflies 💫';
      case BackgroundAnimationEffect.bokehShimmer:
        return 'Dreamy Bokeh 🔮';
    }
  }

  String get name => toString().split('.').last;
}

enum PageBackgroundType {
  solid,
  gradient,
  animated;

  String get name => toString().split('.').last;
}

/// Multiple Immersive Opening Styles for Surprise Envelopes, Gift Boxes & Interactive Reveals
enum OpeningRevealStyle {
  classicEnvelope,
  romanticPinkEnvelope,
  luxuryGiftBox,
  floralSurprise,
  elegantLetter,
  minimalCard,
  midnightStarlight,
  confettiCelebration,
  secretHeartLock,
  crystalGemMagic,
  cupidArrow,
  polaroidMemoryString;

  String get id => name;

  String get label {
    switch (this) {
      case OpeningRevealStyle.classicEnvelope:
        return 'Classic Wax-Seal Envelope';
      case OpeningRevealStyle.romanticPinkEnvelope:
        return 'Romantic Pink Envelope';
      case OpeningRevealStyle.luxuryGiftBox:
        return 'Luxury Golden Gift Box';
      case OpeningRevealStyle.floralSurprise:
        return 'Enchanted Blossom Bloom';
      case OpeningRevealStyle.elegantLetter:
        return 'Antique Royal Scroll';
      case OpeningRevealStyle.minimalCard:
        return 'Modern Origami Unfold';
      case OpeningRevealStyle.midnightStarlight:
        return 'Midnight Constellation';
      case OpeningRevealStyle.confettiCelebration:
        return 'Celebration Confetti Blast';
      case OpeningRevealStyle.secretHeartLock:
        return 'Secret Heart Key & Lock';
      case OpeningRevealStyle.crystalGemMagic:
        return 'Crystal Prism Gemstone';
      case OpeningRevealStyle.cupidArrow:
        return "Cupid's Love Arrow";
      case OpeningRevealStyle.polaroidMemoryString:
        return 'Fairy-Lit Memory Garland';
    }
  }

  String get emoji {
    switch (this) {
      case OpeningRevealStyle.classicEnvelope:
        return '✉️';
      case OpeningRevealStyle.romanticPinkEnvelope:
        return '💌';
      case OpeningRevealStyle.luxuryGiftBox:
        return '🎁';
      case OpeningRevealStyle.floralSurprise:
        return '🌸';
      case OpeningRevealStyle.elegantLetter:
        return '📜';
      case OpeningRevealStyle.minimalCard:
        return '✨';
      case OpeningRevealStyle.midnightStarlight:
        return '🌌';
      case OpeningRevealStyle.confettiCelebration:
        return '🎉';
      case OpeningRevealStyle.secretHeartLock:
        return '🔐';
      case OpeningRevealStyle.crystalGemMagic:
        return '💎';
      case OpeningRevealStyle.cupidArrow:
        return '🏹';
      case OpeningRevealStyle.polaroidMemoryString:
        return '📷';
    }
  }

  String get description {
    switch (this) {
      case OpeningRevealStyle.classicEnvelope:
        return 'Timeless vintage envelope with wax seal cracking';
      case OpeningRevealStyle.romanticPinkEnvelope:
        return 'Blushing pink envelope with ribbon & glowing hearts';
      case OpeningRevealStyle.luxuryGiftBox:
        return 'Golden ribboned luxury gift box with lid reveal';
      case OpeningRevealStyle.floralSurprise:
        return 'Blooming floral petals & soft spring aesthetics';
      case OpeningRevealStyle.elegantLetter:
        return 'Parchment scroll unrolling with handwritten charm';
      case OpeningRevealStyle.minimalCard:
        return 'Modern clean folding card with sleek 3D unfold';
      case OpeningRevealStyle.midnightStarlight:
        return 'Constellation connect with shooting stardust explosion';
      case OpeningRevealStyle.confettiCelebration:
        return 'Party popper explosion with ribbons & colorful confetti';
      case OpeningRevealStyle.secretHeartLock:
        return 'Gilded heart lock turning with magical key & glowing doors';
      case OpeningRevealStyle.crystalGemMagic:
        return 'Sparkling diamond prism refracting rainbow light rays';
      case OpeningRevealStyle.cupidArrow:
        return 'Golden arrow flying with spark trail striking heart target';
      case OpeningRevealStyle.polaroidMemoryString:
        return 'Glowing fairy-light string with memories parting open';
    }
  }

  String get name => toString().split('.').last;
}

class PageBackgroundConfig {
  final PageBackgroundType type;
  final int solidColor;
  final List<int> gradientColors;
  final BackgroundAnimationEffect animationEffect;

  const PageBackgroundConfig({
    this.type = PageBackgroundType.gradient,
    this.solidColor = 0xFFFFF9F5,
    this.gradientColors = const [0xFFF6B8C8, 0xFFEC8FA8],
    this.animationEffect = BackgroundAnimationEffect.floatingPetals,
  });

  PageBackgroundConfig copyWith({
    PageBackgroundType? type,
    int? solidColor,
    List<int>? gradientColors,
    BackgroundAnimationEffect? animationEffect,
  }) {
    return PageBackgroundConfig(
      type: type ?? this.type,
      solidColor: solidColor ?? this.solidColor,
      gradientColors: gradientColors ?? this.gradientColors,
      animationEffect: animationEffect ?? this.animationEffect,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'solidColor': solidColor,
        'gradientColors': gradientColors,
        'animationEffect': animationEffect.toString().split('.').last,
      };

  factory PageBackgroundConfig.fromJson(Map<String, dynamic> json) {
    return PageBackgroundConfig(
      type: PageBackgroundType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PageBackgroundType.gradient,
      ),
      solidColor: json['solidColor'] as int? ?? 0xFFFFF9F5,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [0xFFF6B8C8, 0xFFEC8FA8],
      animationEffect: BackgroundAnimationEffect.values.firstWhere(
        (e) => e.toString().split('.').last == json['animationEffect'],
        orElse: () => BackgroundAnimationEffect.none,
      ),
    );
  }
}

class PageElementModel {
  final String id;
  final PageElementType type;
  final double x; // Horizontal offset relative to 360 width canvas
  final double y; // Vertical offset relative to 560 height canvas
  final double scale;
  final double rotation; // Radians
  final int zIndex;

  // Text Properties
  final String? text;
  final String? fontFamily;
  final double? fontSize;
  final int? textColor;
  final String? textAlign;
  final bool isBold;
  final bool isItalic;
  final double letterSpacing;
  final double? lineHeight;
  final int? textBackgroundColor;
  final double textOpacity;

  // Photo Properties
  final String? imagePath;
  final PhotoShape photoShape;
  final double borderWidth;
  final int borderColor;
  final double width;
  final double height;

  // Sticker Properties
  final String? stickerSymbol;
  final StickerAnimationEffect stickerAnimation;

  // Decorative Elements
  final String? decorativeType;

  const PageElementModel({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
    this.text,
    this.fontFamily = 'Playfair Display',
    this.fontSize = 18.0,
    this.textColor = 0xFF49383B,
    this.textAlign = 'center',
    this.isBold = false,
    this.isItalic = false,
    this.letterSpacing = 0.5,
    this.lineHeight = 1.45,
    this.textBackgroundColor,
    this.textOpacity = 1.0,
    this.imagePath,
    this.photoShape = PhotoShape.roundedRectangle,
    this.borderWidth = 3.0,
    this.borderColor = 0xFFFFFFFF,
    this.width = 160.0,
    this.height = 160.0,
    this.stickerSymbol,
    this.stickerAnimation = StickerAnimationEffect.none,
    this.decorativeType,
  });

  PageElementModel copyWith({
    String? id,
    PageElementType? type,
    double? x,
    double? y,
    double? scale,
    double? rotation,
    int? zIndex,
    String? text,
    String? fontFamily,
    double? fontSize,
    int? textColor,
    String? textAlign,
    bool? isBold,
    bool? isItalic,
    double? letterSpacing,
    double? lineHeight,
    int? textBackgroundColor,
    double? textOpacity,
    String? imagePath,
    PhotoShape? photoShape,
    double? borderWidth,
    int? borderColor,
    double? width,
    double? height,
    String? stickerSymbol,
    StickerAnimationEffect? stickerAnimation,
    String? decorativeType,
  }) {
    return PageElementModel(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      textBackgroundColor: textBackgroundColor ?? this.textBackgroundColor,
      textOpacity: textOpacity ?? this.textOpacity,
      imagePath: imagePath ?? this.imagePath,
      photoShape: photoShape ?? this.photoShape,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      width: width ?? this.width,
      height: height ?? this.height,
      stickerSymbol: stickerSymbol ?? this.stickerSymbol,
      stickerAnimation: stickerAnimation ?? this.stickerAnimation,
      decorativeType: decorativeType ?? this.decorativeType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'x': x,
        'y': y,
        'scale': scale,
        'rotation': rotation,
        'zIndex': zIndex,
        'text': text,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'textColor': textColor,
        'textAlign': textAlign,
        'isBold': isBold,
        'isItalic': isItalic,
        'letterSpacing': letterSpacing,
        'lineHeight': lineHeight,
        'textBackgroundColor': textBackgroundColor,
        'textOpacity': textOpacity,
        'imagePath': imagePath,
        'photoShape': photoShape.toString().split('.').last,
        'borderWidth': borderWidth,
        'borderColor': borderColor,
        'width': width,
        'height': height,
        'stickerSymbol': stickerSymbol,
        'stickerAnimation': stickerAnimation.toString().split('.').last,
        'decorativeType': decorativeType,
      };

  factory PageElementModel.fromJson(Map<String, dynamic> json) {
    return PageElementModel(
      id: json['id'] as String,
      type: PageElementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PageElementType.text,
      ),
      x: (json['x'] as num?)?.toDouble() ?? 50.0,
      y: (json['y'] as num?)?.toDouble() ?? 50.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      zIndex: (json['zIndex'] as int?) ?? 0,
      text: json['text'] as String?,
      fontFamily: json['fontFamily'] as String? ?? 'Playfair Display',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18.0,
      textColor: json['textColor'] as int? ?? 0xFF0F172A,
      textAlign: json['textAlign'] as String? ?? 'center',
      isBold: (json['isBold'] as bool?) ?? false,
      isItalic: (json['isItalic'] as bool?) ?? false,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.5,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.45,
      textBackgroundColor: json['textBackgroundColor'] as int?,
      textOpacity: (json['textOpacity'] as num?)?.toDouble() ?? 1.0,
      imagePath: json['imagePath'] as String?,
      photoShape: PhotoShape.values.firstWhere(
        (e) => e.toString().split('.').last == json['photoShape'],
        orElse: () => PhotoShape.roundedRectangle,
      ),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 3.0,
      borderColor: json['borderColor'] as int? ?? 0xFFFFFFFF,
      width: (json['width'] as num?)?.toDouble() ?? 160.0,
      height: (json['height'] as num?)?.toDouble() ?? 160.0,
      stickerSymbol: json['stickerSymbol'] as String?,
      stickerAnimation: StickerAnimationEffect.values.firstWhere(
        (e) => e.toString().split('.').last == json['stickerAnimation'],
        orElse: () => StickerAnimationEffect.none,
      ),
      decorativeType: json['decorativeType'] as String?,
    );
  }
}

/// Structured, versioned Page Document for Lovio
class PageDocument {
  final String id;
  final String title;
  final String writtenMessage;
  final PageBackgroundConfig background;
  final List<PageElementModel> elements;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String shareToken;
  final bool isShareable;
  final bool isPostedToFeed;
  final int viewsCount;
  final OpeningRevealStyle openingStyle;

  PageDocument({
    required this.id,
    required this.title,
    this.writtenMessage = '',
    this.background = const PageBackgroundConfig(),
    this.elements = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.shareToken,
    this.isShareable = true,
    this.isPostedToFeed = false,
    this.viewsCount = 1,
    this.openingStyle = OpeningRevealStyle.romanticPinkEnvelope,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get shareUrl => 'https://lovio-e5990.web.app/p/$shareToken';

  PageDocument copyWith({
    String? id,
    String? title,
    String? writtenMessage,
    PageBackgroundConfig? background,
    List<PageElementModel>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shareToken,
    bool? isShareable,
    bool? isPostedToFeed,
    int? viewsCount,
    OpeningRevealStyle? openingStyle,
  }) {
    return PageDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      writtenMessage: writtenMessage ?? this.writtenMessage,
      background: background ?? this.background,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shareToken: shareToken ?? this.shareToken,
      isShareable: isShareable ?? this.isShareable,
      isPostedToFeed: isPostedToFeed ?? this.isPostedToFeed,
      viewsCount: viewsCount ?? this.viewsCount,
      openingStyle: openingStyle ?? this.openingStyle,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'writtenMessage': writtenMessage,
        'background': background.toJson(),
        'elements': elements.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'shareToken': shareToken,
        'isShareable': isShareable,
        'isPostedToFeed': isPostedToFeed,
        'viewsCount': viewsCount,
        'openingStyle': openingStyle.toString().split('.').last,
      };

  factory PageDocument.fromJson(Map<String, dynamic> json) {
    return PageDocument(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Page',
      writtenMessage: json['writtenMessage'] as String? ?? '',
      background: json['background'] != null
          ? PageBackgroundConfig.fromJson(
              json['background'] as Map<String, dynamic>)
          : const PageBackgroundConfig(),
      elements: (json['elements'] as List<dynamic>?)
              ?.map(
                  (e) => PageElementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      shareToken: json['shareToken'] as String? ?? 'p_token',
      isShareable: (json['isShareable'] as bool?) ?? true,
      isPostedToFeed: (json['isPostedToFeed'] as bool?) ?? false,
      viewsCount: (json['viewsCount'] as int?) ?? 1,
      openingStyle: OpeningRevealStyle.values.firstWhere(
        (e) => e.toString().split('.').last == json['openingStyle'],
        orElse: () => OpeningRevealStyle.romanticPinkEnvelope,
      ),
    );
  }
}

