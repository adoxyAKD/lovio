import 'package:flutter/material.dart';

/// Lovio Page Editor Assets & Customization Configuration
///
/// Easily add, remove, or modify items in this file:
/// - [stickerCategories]: Emojis and stickers organized by occasion
/// - [inspirationPrompts]: Romantic prompt chips & templates
/// - [gradientPresets]: Two-color gradient presets for backgrounds (16 options)
/// - [solidColorPalette]: Solid color background options (16 options)
/// - [textColorPalette]: Text color choices (16 options)
/// - [availableFonts]: Supported Google font families (15 options)
/// - [editorDefaults]: Default titles, placeholders, and texts
class PageEditorAssets {
  PageEditorAssets._();

  // ===========================================================================
  // 1. STICKERS & EMOJIS (10 Occasion-Based Categories, 18-20 per category)
  // ===========================================================================
  static const Map<String, List<String>> stickerCategories = {
    'Hearts & Love': [
      '❤️', '💖', '💕', '💓', '💘', '💝', '💗', '💞', '💌', '🤍',
      '🥰', '😍', '😘', '👩‍❤️‍👨', '💑', '👩‍❤️‍💋‍👨', '🫂', '💋', '❣️', '🫀',
    ],
    'Anniversary & Wedding': [
      '💍', '🥂', '🍾', '👰‍♀️', '🤵‍♂️', '💒', '💐', '🔔', '🕯️', '🕊️',
      '💎', '🎉', '🎊', '🍰', '🧁', '👑', '🌹', '✨', '🤍', '📜',
    ],
    'Birthday & Party': [
      '🎂', '🎉', '🎁', '🎈', '🎊', '🥳', '🧁', '🍰', '🎇', '🎆',
      '🍭', '🍬', '🍫', '🪅', '🪩', '🎵', '🎶', '🪄', '⭐', '✨',
    ],
    'Roses & Flowers': [
      '🌹', '🌸', '🌺', '🌷', '🌻', '💐', '🌼', '🥀', '🌿', '🌱',
      '🍀', '🌾', '🪻', '💮', '🏵️', '🪴', '🍃', '🍂', '🍁', '🍄',
    ],
    'Teddies & Hugs': [
      '🧸', '🐻', '🐼', '🐨', '🐱', '🐶', '🐰', '🦊', '🐣', '🐥',
      '🦢', '🕊️', '🦦', '🦥', '🦭', '🐿️', '🐇', '🐾', '🫂', '🤗',
    ],
    'Cute Pets & Chibi': [
      '😻', '😽', '🐶', '🐱', '🐹', '🐰', '🐭', '🐨', '🦄', '🐝',
      '🐞', '🦋', '🐳', '🐬', '🦩', '🐧', '🦉', '✨', '🌟', '💖',
    ],
    'Butterflies & Stars': [
      '🦋', '✨', '⭐', '🌟', '💫', '🌙', '🪄', '🎆', '☀️', '🌈',
      '☁️', '🪐', '☄️', '🌌', '⚡', '🔮', '🫧', '💎', '❄️', '🔥',
    ],
    'Dates, Food & Drinks': [
      '☕', '🍵', '🥂', '🍷', '🍸', '🍹', '🍕', '🍝', '🍣', '🍓',
      '🍫', '🍰', '🍦', '🍩', '🥐', '🥞', '🥨', '🍪', '🍿', '🧁',
    ],
    'Travel & Adventures': [
      '✈️', '🏖️', '🏝️', '🌅', '🌄', '🏔️', '⛺', '🚗', '🗺️', '🗼',
      '🎡', '🎢', '⛵', '🛶', '🚂', '📸', '🎞️', '🌌', '🧭', '🧳',
    ],
    'Bows, Rings & Keepsakes': [
      '🎀', '🎁', '💍', '👑', '🕊️', '💌', '📮', '🗝️', '🔐', '🔒',
      '🪞', '🪡', '🧵', '📿', '💎', '🕯️', '🧸', '📜', '🎨', '✒️',
    ],
  };

  // ===========================================================================
  // 2. ROMANTIC INSPIRATION PROMPTS (Write Screen Templates)
  // ===========================================================================
  static const List<Map<String, String>> inspirationPrompts = [
    {
      'label': '💌 Vows & Promises',
      'title': 'My Vow To You',
      'body':
          'In your eyes, I found my home, and in your heart, I found my love. I promise to cherish every second we share together, through every season of life.',
    },
    {
      'label': '🌹 Happy Anniversary',
      'title': 'Happy Anniversary My Love',
      'body':
          'Another year of laughing at silly jokes, creating unforgettable memories, and falling in love with you all over again every single morning.',
    },
    {
      'label': '✨ Why I Love You',
      'title': 'Reasons I Adore You',
      'body':
          'I love the way your eyes crinkle when you laugh, the warmth of your embrace, and the silent understanding we share without speaking a single word.',
    },
    {
      'label': '🌅 When We First Met',
      'title': 'The Day We Met',
      'body':
          'I still remember the exact moment our eyes first met. The noise around us faded away, and right then I knew my life was about to change forever.',
    },
    {
      'label': '💫 Just Thinking of You',
      'title': 'Thinking of You Always',
      'body':
          'Just a little reminder today: you are my favorite thought, my deepest comfort, and the sweetest part of every single day.',
    },
    {
      'label': '🕊️ Forever & Always',
      'title': 'Forever Beside You',
      'body':
          'Wherever this journey leads, I am grateful that my hand is in yours. You make every day warmer, kinder, and infinitely more beautiful.',
    },
  ];

  // ===========================================================================
  // 3. BACKGROUND GRADIENT PRESETS (16 Gorgeous Gradients)
  // ===========================================================================
  static const List<PageGradientPreset> gradientPresets = [
    PageGradientPreset(
      name: 'Sunset Love',
      colors: [0xFFF6B8C8, 0xFFEC8FA8],
    ),
    PageGradientPreset(
      name: 'Indigo Dream',
      colors: [0xFF4361EE, 0xFF3F37C9],
    ),
    PageGradientPreset(
      name: 'Ocean Breeze',
      colors: [0xFFA1C4FD, 0xFFC2E9FB],
    ),
    PageGradientPreset(
      name: 'Lavender Mist',
      colors: [0xFFFDE8E9, 0xFFE9D8FD],
    ),
    PageGradientPreset(
      name: 'Romance Rose',
      colors: [0xFFFF9A9E, 0xFFFAD0C4],
    ),
    PageGradientPreset(
      name: 'Pastel Dawn',
      colors: [0xFFFFD1FF, 0xFFFAD0C4],
    ),
    PageGradientPreset(
      name: 'Mint Garden',
      colors: [0xFFD4FC79, 0xFF96E6A1],
    ),
    PageGradientPreset(
      name: 'Midnight Starlight',
      colors: [0xFF1F1C2C, 0xFF928DAB],
    ),
    PageGradientPreset(
      name: 'Velvet Night',
      colors: [0xFF2C3E50, 0xFF000000],
    ),
    PageGradientPreset(
      name: 'Mystic Teal',
      colors: [0xFF2C3E50, 0xFF4CA1AF],
    ),
    PageGradientPreset(
      name: 'Golden Radiance',
      colors: [0xFFFFE259, 0xFFFFA751],
    ),
    PageGradientPreset(
      name: 'Cosmic Aurora',
      colors: [0xFF00C6FF, 0xFF0072FF],
    ),
    PageGradientPreset(
      name: 'Peach Sorbet',
      colors: [0xFFFFECD2, 0xFFFCB69F],
    ),
    PageGradientPreset(
      name: 'Neon Love',
      colors: [0xFFFF0844, 0xFFFFB199],
    ),
    PageGradientPreset(
      name: 'Royal Amethyst',
      colors: [0xFF654EA3, 0xFFEAAFC8],
    ),
    PageGradientPreset(
      name: 'Emerald Luxury',
      colors: [0xFF134E5E, 0xFF71B280],
    ),
  ];

  // ===========================================================================
  // 4. SOLID BACKGROUND COLOR PALETTE (16 Curated Hex Tints)
  // ===========================================================================
  static const List<int> solidColorPalette = [
    0xFFFFF9F5, // Warm Cream
    0xFFFDE8E9, // Blush Tint
    0xFFEFF6FF, // Soft Ice Blue
    0xFFEEF2FF, // Indigo Tint
    0xFFF3E8FF, // Soft Lilac
    0xFFE6FFFA, // Soft Mint
    0xFFF0FDF4, // Sage Green
    0xFFFFFBEB, // Warm Vanilla
    0xFFFFEDD5, // Peach Puff
    0xFFFCE7F3, // Cotton Candy Pink
    0xFFE0E7FF, // Periwinkle Blue
    0xFF2D252E, // Velvet Dark
    0xFF1E293B, // Slate Charcoal
    0xFF1E1B4B, // Midnight Indigo
    0xFF0F172A, // Deep Midnight
    0xFFFFFFFF, // Pure Snow White
  ];

  // ===========================================================================
  // 5. TEXT COLOR PALETTE (16 High-Contrast Colors)
  // ===========================================================================
  static const List<int> textColorPalette = [
    0xFF0F172A, // Midnight Navy (Sharp & Modern)
    0xFFFFFFFF, // Pure White (Perfect for dark / blue cards)
    0xFF4361EE, // Indigo Accent Blue
    0xFF1E3A8A, // Deep Royal Blue
    0xFF49383B, // Warm Charcoal Brown
    0xFF8E2A49, // Romantic Burgundy
    0xFFDC2626, // Crimson Red
    0xFFE57373, // Rose Coral
    0xFFDB2777, // Vibrant Blush Pink
    0xFF7C3AED, // Royal Violet
    0xFF059669, // Forest Emerald
    0xFFD97706, // Amber Gold
    0xFFD4AF37, // Vintage Champagne Gold
    0xFF0284C7, // Sky Cyan
    0xFFFFFBEB, // Soft Cream
    0xFF475569, // Neutral Slate
  ];

  // ===========================================================================
  // 6. AVAILABLE FONT FAMILIES (15 Romantic & Modern Google Fonts)
  // ===========================================================================
  static const List<String> availableFonts = [
    'Playfair Display',
    'Great Vibes',
    'Dancing Script',
    'Caveat',
    'Poppins',
    'Montserrat',
    'Cormorant Garamond',
    'Parisienne',
    'Cinzel',
    'Sacramento',
    'Pacifico',
    'Satisfy',
    'Alex Brush',
    'Marck Script',
    'Lora',
    'Inter',
  ];

  // ===========================================================================
  // 7. DEFAULT TEXTS, TITLES & PLACEHOLDERS
  // ===========================================================================
  static const String defaultPageTitle = 'My Cherished Page';
  static const String defaultWriteTitleHint = 'e.g. Forever With You 💕';
  static const String defaultWriteMessageHint =
      'Write your poetry, vows, letter, or cherished memories here...\n\nYou can customize fonts, photos, stickers, and animated backgrounds on the next screen ✨';
  static const String defaultNewTextElement = 'Tap to edit message ✨';
  static const String emptyCanvasHint =
      'Canvas is clear\nTap tools below to add elements ✨';
  static const String emptyLayersHint =
      'No elements on canvas yet.\nAdd text, photos, or stickers from the tabs below! ✨';
}

/// Helper model for named gradient presets
class PageGradientPreset {
  final String name;
  final List<int> colors;

  const PageGradientPreset({
    required this.name,
    required this.colors,
  });

  LinearGradient get gradient => LinearGradient(
        colors: colors.map((c) => Color(c)).toList(),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
