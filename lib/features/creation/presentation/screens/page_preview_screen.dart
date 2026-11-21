import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/page_document.dart';
import '../view_models/page_editor_view_model.dart';
import '../widgets/animated_sticker_widget.dart';
import '../widgets/page_animated_background.dart';
import '../widgets/page_save_success_dialog.dart';
import '../widgets/page_share_sheet.dart';
import '../widgets/photo_shape_widget.dart';

class PagePreviewScreen extends ConsumerStatefulWidget {
  const PagePreviewScreen({super.key});

  @override
  ConsumerState<PagePreviewScreen> createState() => _PagePreviewScreenState();
}

class _PagePreviewScreenState extends ConsumerState<PagePreviewScreen> {
  bool _isSavingToLibrary = false;

  Color _resolveTextColor(PageElementModel elem, PageBackgroundConfig bg) {
    if (elem.textColor != null && elem.textColor != 0xFF49383B) {
      return Color(elem.textColor!);
    }
    if (bg.type == PageBackgroundType.solid) {
      final lum = Color(bg.solidColor).computeLuminance();
      if (lum < 0.45) return Colors.white;
      return const Color(0xFF0F172A);
    } else if (bg.gradientColors.isNotEmpty) {
      final firstColor = Color(bg.gradientColors.first);
      final lum = firstColor.computeLuminance();
      if (lum < 0.45) return Colors.white;
      // If blue/cyan tinted background (harmonize with blue card):
      if (firstColor.blue > 200 && firstColor.red < 190) {
        return const Color(0xFF1E3A8A); // Deep Royal Blue
      }
      return const Color(0xFF0F172A);
    }
    return const Color(0xFF0F172A);
  }

  TextStyle _resolveFontStyle(PageElementModel elem, PageBackgroundConfig bg) {
    TextStyle baseStyle;
    switch (elem.fontFamily) {
      case 'Great Vibes':
        baseStyle = GoogleFonts.greatVibes();
        break;
      case 'Dancing Script':
        baseStyle = GoogleFonts.dancingScript();
        break;
      case 'Caveat':
        baseStyle = GoogleFonts.caveat();
        break;
      case 'Poppins':
        baseStyle = GoogleFonts.poppins();
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat();
        break;
      case 'Cormorant Garamond':
        baseStyle = GoogleFonts.cormorantGaramond();
        break;
      case 'Parisienne':
        baseStyle = GoogleFonts.parisienne();
        break;
      case 'Cinzel':
        baseStyle = GoogleFonts.cinzel();
        break;
      case 'Sacramento':
        baseStyle = GoogleFonts.sacramento();
        break;
      case 'Pacifico':
        baseStyle = GoogleFonts.pacifico();
        break;
      case 'Satisfy':
        baseStyle = GoogleFonts.satisfy();
        break;
      case 'Alex Brush':
        baseStyle = GoogleFonts.alexBrush();
        break;
      case 'Marck Script':
        baseStyle = GoogleFonts.marckScript();
        break;
      case 'Lora':
        baseStyle = GoogleFonts.lora();
        break;
      case 'Playfair Display':
      default:
        baseStyle = GoogleFonts.playfairDisplay();
        break;
    }

    final resolvedColor = _resolveTextColor(elem, bg)
        .withOpacity(elem.textOpacity.clamp(0.1, 1.0));

    return baseStyle.copyWith(
      fontSize: elem.fontSize ?? 18,
      color: resolvedColor,
      fontWeight: elem.isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: elem.isItalic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: elem.letterSpacing,
      height: elem.lineHeight ?? 1.45,
      backgroundColor: elem.textBackgroundColor != null
          ? Color(elem.textBackgroundColor!)
          : null,
    );
  }

  TextAlign _resolveTextAlign(String? align) {
    switch (align) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
      default:
        return TextAlign.center;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final state = ref.watch(pageEditorProvider);
    final doc = state.document;

    return Scaffold(
      backgroundColor: lovio.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Clean Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back to Editor
                  Container(
                    decoration: BoxDecoration(
                      color: lovio.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.softCard,
                      border: Border.all(color: lovio.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      color: lovio.textPrimary,
                      tooltip: 'Back to Editor',
                      onPressed: () => context.pop(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title & Mode Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          doc.title.isNotEmpty
                              ? doc.title
                              : 'Cherished Page',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: lovio.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Recipient Live View ✨',
                          style: AppTextStyles.labelSmall(color: lovio.accent),
                        ),
                      ],
                    ),
                  ),

                  // Direct Home Button
                  Container(
                    decoration: BoxDecoration(
                      color: lovio.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.softCard,
                      border: Border.all(color: lovio.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.home_rounded, size: 20),
                      color: lovio.textPrimary,
                      tooltip: 'Go to Home',
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Framed Romantic Canvas Preview (Scrollable based on content up to 1,000 chars)
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppShadows.floating,
                    border: Border.all(
                      color: lovio.accent.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final viewportHeight = constraints.maxHeight;
                      final viewportWidth = constraints.maxWidth;

                      // Dynamically calculate canvas height based on all elements & long text
                      double calculatedHeight = viewportHeight;
                      for (final elem in doc.elements) {
                        double elemBottom = elem.y + 120;
                        if (elem.type == PageElementType.text) {
                          final textLen = (elem.text?.length ?? 0);
                          final linesEstimate =
                              math.max(1, (textLen / 22).ceil());
                          final fontSize = elem.fontSize ?? 18;
                          final textHeight =
                              linesEstimate * (fontSize * 1.5) * elem.scale;
                          elemBottom = elem.y + textHeight + 90;
                        } else if (elem.type == PageElementType.photo) {
                          elemBottom = elem.y + (elem.height * elem.scale) + 60;
                        } else if (elem.type == PageElementType.sticker) {
                          elemBottom = elem.y + (70 * elem.scale) + 40;
                        }
                        if (elemBottom > calculatedHeight) {
                          calculatedHeight = elemBottom;
                        }
                      }
                      final totalCanvasHeight =
                          math.max(viewportHeight, calculatedHeight + 70);

                      return InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 3.0,
                        clipBehavior: Clip.none,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            height: totalCanvasHeight,
                            width: viewportWidth,
                            child: PageAnimatedBackground(
                              config: doc.background,
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  ...doc.elements.map((elem) {
                                    return Positioned(
                                      left: elem.x,
                                      top: elem.y,
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(pageEditorProvider.notifier)
                                              .selectElement(elem.id);
                                          context.push(AppRoutes.createPageEditor);
                                        },
                                        child: Transform.rotate(
                                          angle: elem.rotation,
                                          child: Transform.scale(
                                            scale: elem.scale,
                                            child: _buildElementWidget(
                                                elem, viewportWidth, doc.background),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 3. Bottom Modern Action Bar (Save to Library at the very bottom, Edit & Share above)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lovio.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.floating,
                  border: Border.all(color: lovio.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Tier: Edit Canvas & Share Options
                    Row(
                      children: [
                        // Secondary Action: Edit Canvas
                        Expanded(
                          flex: 2,
                          child: AnimatedPressable(
                            onPressed: () =>
                                context.push(AppRoutes.createPageEditor),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: lovio.background,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: lovio.border),
                                boxShadow: AppShadows.softCard,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.brush_rounded,
                                      size: 16, color: lovio.accent),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Edit Canvas',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: lovio.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Secondary Action: Share
                        Expanded(
                          flex: 3,
                          child: AnimatedPressable(
                            onPressed: () => PageShareSheet.show(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF25D366)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.share_rounded,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Share Surprise ✨',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Bottom Tier: Save to Library (Prominent Primary Button at the very bottom)
                    AnimatedPressable(
                      onPressed: _isSavingToLibrary
                          ? null
                          : () async {
                              setState(() => _isSavingToLibrary = true);
                              try {
                                final ok = await ref
                                    .read(pageEditorProvider.notifier)
                                    .saveToLibrary(ref);
                                if (mounted) {
                                  setState(() => _isSavingToLibrary = false);
                                  if (ok) {
                                    PageSaveSuccessSheet.show(context, ref);
                                  }
                                }
                              } catch (_) {
                                if (mounted) {
                                  setState(() => _isSavingToLibrary = false);
                                }
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: lovio.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: lovio.glow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSavingToLibrary) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Saving to Library...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ] else ...[
                              const Icon(Icons.bookmark_add_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Save to My Library',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementWidget(
      PageElementModel elem, double canvasWidth, PageBackgroundConfig bg) {
    switch (elem.type) {
      case PageElementType.text:
        final maxW =
            math.max(220.0, canvasWidth - math.max(0.0, elem.x) - 24.0);
        return Container(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Text(
            elem.text ?? '',
            style: _resolveFontStyle(elem, bg),
            textAlign: _resolveTextAlign(elem.textAlign),
          ),
        );

      case PageElementType.photo:
        return PhotoShapeWidget(
          imagePath: elem.imagePath,
          shape: elem.photoShape,
          width: elem.width,
          height: elem.height,
          borderWidth: elem.borderWidth,
          borderColor: Color(elem.borderColor),
        );

      case PageElementType.sticker:
        return AnimatedStickerWidget(
          symbol: elem.stickerSymbol ?? '❤️',
          animation: elem.stickerAnimation,
          size: 72,
        );

      case PageElementType.decorative:
        return const SizedBox.shrink();
    }
  }
}
