import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/page_document.dart';
import '../../constants/page_editor_assets.dart';
import '../view_models/page_editor_view_model.dart';
import '../widgets/animated_sticker_widget.dart';
import '../widgets/page_animated_background.dart';
import '../widgets/page_save_success_dialog.dart';
import '../widgets/photo_shape_widget.dart';

enum _EditorTab { text, background, photos, stickers, layers }

enum _ElementToolMode { resize, rotate, position, style }

class AlignmentGuideLine {
  final double position;
  final bool isVertical;
  final String label;

  const AlignmentGuideLine({
    required this.position,
    required this.isVertical,
    required this.label,
  });
}

class _SmartGuides {
  final AlignmentGuideLine? vertical;
  final AlignmentGuideLine? horizontal;

  const _SmartGuides({this.vertical, this.horizontal});
}

class SmartGuidePainter extends CustomPainter {
  final AlignmentGuideLine? verticalGuide;
  final AlignmentGuideLine? horizontalGuide;
  final Color guideColor;

  SmartGuidePainter({
    this.verticalGuide,
    this.horizontalGuide,
    required this.guideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (verticalGuide == null && horizontalGuide == null) return;

    final linePaint = Paint()
      ..color = guideColor.withOpacity(0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = guideColor.withOpacity(0.35)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Draw vertical guide
    if (verticalGuide != null) {
      final x = verticalGuide!.position;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowPaint);
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, size.height), linePaint);
      _drawLabelBadge(canvas, Offset(x, 28), verticalGuide!.label);
    }

    // Draw horizontal guide
    if (horizontalGuide != null) {
      final y = horizontalGuide!.position;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), linePaint);
      _drawLabelBadge(canvas, Offset(size.width / 2, y - 14), horizontalGuide!.label);
    }

    // If both guides intersect, draw precision crosshair
    if (verticalGuide != null && horizontalGuide != null) {
      final center = Offset(verticalGuide!.position, horizontalGuide!.position);
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final ringPaint = Paint()
        ..color = guideColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, 7.0, ringPaint);
      canvas.drawCircle(center, 3.5, centerPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 6.0;
    const dashSpace = 4.0;
    final totalDist = (p2 - p1).distance;
    if (totalDist == 0) return;
    final dir = (p2 - p1) / totalDist;
    double currentDist = 0.0;
    while (currentDist < totalDist) {
      final start = p1 + dir * currentDist;
      final step = math.min(dashLength, totalDist - currentDist);
      final end = start + dir * step;
      canvas.drawLine(start, end, paint);
      currentDist += dashLength + dashSpace;
    }
  }

  void _drawLabelBadge(Canvas canvas, Offset position, String label) {
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 14;
    final badgeHeight = textPainter.height + 6;

    final badgeRect = Rect.fromCenter(
      center: position,
      width: badgeWidth,
      height: badgeHeight,
    );

    final bgPaint = Paint()..color = guideColor;
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.25);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          badgeRect.shift(const Offset(0, 1.5)), const Radius.circular(8)),
      shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(8)),
      bgPaint,
    );

    textPainter.paint(
      canvas,
      Offset(badgeRect.left + 7, badgeRect.top + 3),
    );
  }

  @override
  bool shouldRepaint(covariant SmartGuidePainter oldDelegate) {
    return oldDelegate.verticalGuide != verticalGuide ||
        oldDelegate.horizontalGuide != horizontalGuide ||
        oldDelegate.guideColor != guideColor;
  }
}

class PageEditorScreen extends ConsumerStatefulWidget {
  final bool initialPickImage;
  const PageEditorScreen({super.key, this.initialPickImage = false});

  @override
  ConsumerState<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends ConsumerState<PageEditorScreen> {
  _EditorTab _activeTab = _EditorTab.background;
  _ElementToolMode _elementToolMode = _ElementToolMode.resize;
  final ImagePicker _picker = ImagePicker();
  bool _isInteractingWithElement = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPickImage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage();
      });
    }
  }

  // Ultra-smooth guides notifier to prevent full screen rebuilds
  final ValueNotifier<_SmartGuides> _guidesNotifier =
      ValueNotifier(const _SmartGuides());
  bool _wasSnappedX = false;
  bool _wasSnappedY = false;

  // Presets & Assets loaded from PageEditorAssets for easy customization
  List<int> get _solidPalette => PageEditorAssets.solidColorPalette;
  List<PageGradientPreset> get _gradientPresets =>
      PageEditorAssets.gradientPresets;
  List<String> get _fonts => PageEditorAssets.availableFonts;
  List<int> get _textColors => PageEditorAssets.textColorPalette;
  Map<String, List<String>> get _stickerCategories =>
      PageEditorAssets.stickerCategories;

  @override
  void dispose() {
    _guidesNotifier.dispose();
    super.dispose();
  }

  void _onBack() {
    final state = ref.read(pageEditorProvider);
    if (!state.hasUnsavedChanges) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final lovio = context.lovioColors;
        return AlertDialog(
          backgroundColor: lovio.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Unsaved Changes',
              style: AppTextStyles.titleMedium(color: lovio.textPrimary)),
          content: Text(
            'Would you like to save your work before leaving?',
            style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final ok = await ref
                    .read(pageEditorProvider.notifier)
                    .saveToLibrary(ref);
                if (mounted && ok) {
                  PageSaveSuccessSheet.show(context, ref);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: lovio.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child:
                  const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage({PageElementModel? targetElement}) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = image.path.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64String';

        final notifier = ref.read(pageEditorProvider.notifier);
        final selected =
            targetElement ?? ref.read(pageEditorProvider).selectedElement;

        if (selected != null && selected.type == PageElementType.photo) {
          notifier.updateElement(
            selected.id,
            (e) => e.copyWith(imagePath: dataUri),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo updated successfully! ✨'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          notifier.addPhoto(
            dataUri,
            shape: PhotoShape.roundedRectangle,
          );
        }
        if (mounted) {
          setState(() {
            _activeTab = _EditorTab.photos;
            _elementToolMode = _ElementToolMode.style;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _addNewPhoto() async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = image.path.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64String';

        ref.read(pageEditorProvider.notifier).addPhoto(
              dataUri,
              shape: PhotoShape.roundedRectangle,
            );
        if (mounted) {
          setState(() {
            _activeTab = _EditorTab.photos;
            _elementToolMode = _ElementToolMode.style;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  void _showEditTextDialog(PageElementModel elem) {
    final controller = TextEditingController(text: elem.text ?? '');
    final notifier = ref.read(pageEditorProvider.notifier);
    final lovio = context.lovioColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppShadows.floating,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Message Words',
                      style: AppTextStyles.titleMedium(
                          color: lovio.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 5,
                autofocus: true,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 16, color: lovio.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type your message or poetry here...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newText = controller.text.trim();
                    notifier.updateElement(
                      elem.id,
                      (e) => e.copyWith(text: newText),
                    );
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lovio.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Update Text ✨',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getPhotoShapeIcon(PhotoShape shape) {
    switch (shape) {
      case PhotoShape.rectangle:
        return Icons.crop_square_rounded;
      case PhotoShape.circle:
        return Icons.circle_outlined;
      case PhotoShape.roundedRectangle:
        return Icons.rounded_corner_rounded;
      case PhotoShape.oval:
        return Icons.egg_outlined;
      case PhotoShape.heart:
        return Icons.favorite_rounded;
      case PhotoShape.star:
        return Icons.star_rounded;
      case PhotoShape.hexagon:
        return Icons.hexagon_outlined;
      case PhotoShape.diamond:
        return Icons.diamond_outlined;
      case PhotoShape.arch:
        return Icons.account_balance_outlined;
      case PhotoShape.polaroidFrame:
        return Icons.photo_size_select_actual_outlined;
      case PhotoShape.tornPaperFrame:
        return Icons.note_outlined;
      case PhotoShape.organicBlob:
        return Icons.bubble_chart_outlined;
      case PhotoShape.stampFrame:
        return Icons.local_post_office_outlined;
      case PhotoShape.ornateFrame:
        return Icons.filter_frames_outlined;
      case PhotoShape.vintageFrame:
        return Icons.crop_original_outlined;
      case PhotoShape.scallopedFrame:
        return Icons.wb_sunny_outlined;
      case PhotoShape.cloud:
        return Icons.cloud_outlined;
    }
  }

  void _showPhotoShapeSheet(PageElementModel elem) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final lovio = context.lovioColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final activeDoc = ref.watch(pageEditorProvider).document;
            final activeElem = activeDoc.elements.firstWhere(
              (e) => e.id == elem.id,
              orElse: () => elem,
            );

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: lovio.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_fix_high_rounded,
                              color: lovio.accent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Photo Shapes & Frames (17)',
                            style: AppTextStyles.titleMedium(
                                color: lovio.textPrimary),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _pickImage(targetElement: activeElem);
                    },
                    icon: const Icon(Icons.photo_library_rounded, size: 16),
                    label: const Text('Change Photo from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lovio.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: PhotoShape.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final shape = PhotoShape.values[index];
                        final isSelected = activeElem.photoShape == shape;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.updateElement(
                              activeElem.id,
                              (e) => e.copyWith(photoShape: shape),
                            );
                            setSheetState(() {});
                          },
                          child: Container(
                            width: 78,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? lovio.accent.withOpacity(0.12)
                                  : lovio.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? lovio.accent
                                    : lovio.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getPhotoShapeIcon(shape),
                                  color: isSelected
                                      ? lovio.accent
                                      : lovio.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  shape.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? lovio.accent
                                        : lovio.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Border (${activeElem.borderWidth.toInt()}px)',
                        style: AppTextStyles.labelSmall(
                            color: lovio.textSecondary),
                      ),
                      Expanded(
                        child: Slider(
                          value: activeElem.borderWidth.clamp(0.0, 14.0),
                          min: 0,
                          max: 14,
                          divisions: 14,
                          activeColor: lovio.accent,
                          onChanged: (val) {
                            notifier.updateElement(
                              activeElem.id,
                              (e) => e.copyWith(borderWidth: val),
                            );
                            setSheetState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStickerStyleSheet(PageElementModel elem) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final lovio = context.lovioColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final activeDoc = ref.watch(pageEditorProvider).document;
            final activeElem = activeDoc.elements.firstWhere(
              (e) => e.id == elem.id,
              orElse: () => elem,
            );

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: lovio.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: lovio.accent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Sticker Animations & Effects',
                            style: AppTextStyles.titleMedium(
                                color: lovio.textPrimary),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StickerAnimationEffect.values.map((effect) {
                      final isSelected = activeElem.stickerAnimation == effect;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.updateElement(
                            activeElem.id,
                            (e) => e.copyWith(stickerAnimation: effect),
                          );
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? lovio.accent.withOpacity(0.12)
                                : lovio.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? lovio.accent
                                  : lovio.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            effect.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? lovio.accent
                                  : lovio.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleQuickEdit(PageElementModel elem) {
    if (elem.type == PageElementType.text) {
      _showEditTextDialog(elem);
    } else if (elem.type == PageElementType.photo) {
      _pickImage(targetElement: elem);
    } else if (elem.type == PageElementType.sticker) {
      _showStickerStyleSheet(elem);
    }
  }

  void _confirmClearCanvas(
      PageEditorNotifier notifier, LovioColors lovio) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: lovio.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Canvas?'),
        content: const Text(
            'This will remove all elements from your page canvas. You can undo if needed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.clearCanvas();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Size _getElementDimensions(PageElementModel elem, double canvasWidth) {
    if (elem.type == PageElementType.text) {
      final text = elem.text ?? '';
      final fontSize = (elem.fontSize ?? 20.0) * elem.scale;
      final maxAllowedWidth =
          math.max(220.0, canvasWidth - math.max(0.0, elem.x) - 24.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: fontSize, height: elem.lineHeight ?? 1.45),
        ),
        textDirection: TextDirection.ltr,
        maxLines: null,
      )..layout(maxWidth: maxAllowedWidth);
      return Size(
        math.max(80.0, textPainter.width + 16.0),
        math.max(40.0, textPainter.height + 16.0),
      );
    } else if (elem.type == PageElementType.photo) {
      return Size(elem.width * elem.scale, elem.height * elem.scale);
    } else if (elem.type == PageElementType.sticker) {
      return Size(72.0 * elem.scale, 72.0 * elem.scale);
    }
    return const Size(100, 100);
  }

  void _updateGuidelinesForElement(double rawX, double rawY, double elemW,
      double elemH, double canvasWidth, double canvasHeight) {
    final elemCenterX = rawX + elemW / 2;
    final elemCenterY = rawY + elemH / 2;
    final elemLeft = rawX;
    final elemRight = rawX + elemW;

    const snapThreshold = 10.0;
    AlignmentGuideLine? newVGuide;
    AlignmentGuideLine? newHGuide;

    // 1. Horizontal Center Snap
    final canvasCenterX = canvasWidth / 2;
    if ((elemCenterX - canvasCenterX).abs() <= snapThreshold) {
      newVGuide = AlignmentGuideLine(
        position: canvasCenterX,
        isVertical: true,
        label: 'Center',
      );
    } else if ((elemLeft - 24.0).abs() <= snapThreshold) {
      newVGuide = const AlignmentGuideLine(
        position: 24.0,
        isVertical: true,
        label: 'Left Margin',
      );
    } else if ((elemRight - (canvasWidth - 24.0)).abs() <= snapThreshold) {
      newVGuide = AlignmentGuideLine(
        position: canvasWidth - 24.0,
        isVertical: true,
        label: 'Right Margin',
      );
    }

    // 2. Vertical Center Snap
    final canvasCenterY = canvasHeight / 2;
    if ((elemCenterY - canvasCenterY).abs() <= snapThreshold) {
      newHGuide = AlignmentGuideLine(
        position: canvasCenterY,
        isVertical: false,
        label: 'Middle',
      );
    }

    // 3. Align with other elements
    final doc = ref.read(pageEditorProvider).document;
    for (final other in doc.elements) {
      final otherDim = _getElementDimensions(other, canvasWidth);
      final otherCenterX = other.x + otherDim.width / 2;
      final otherCenterY = other.y + otherDim.height / 2;

      if (newVGuide == null) {
        if ((elemCenterX - otherCenterX).abs() <= snapThreshold) {
          newVGuide = AlignmentGuideLine(
            position: otherCenterX,
            isVertical: true,
            label: 'Aligned Center',
          );
        } else if ((elemLeft - other.x).abs() <= snapThreshold) {
          newVGuide = AlignmentGuideLine(
            position: other.x,
            isVertical: true,
            label: 'Aligned Left',
          );
        }
      }

      if (newHGuide == null) {
        if ((elemCenterY - otherCenterY).abs() <= snapThreshold) {
          newHGuide = AlignmentGuideLine(
            position: otherCenterY,
            isVertical: false,
            label: 'Aligned Middle',
          );
        }
      }
    }

    if (newVGuide != null && !_wasSnappedX) {
      HapticFeedback.selectionClick();
    }
    if (newHGuide != null && !_wasSnappedY) {
      HapticFeedback.selectionClick();
    }
    _wasSnappedX = newVGuide != null;
    _wasSnappedY = newHGuide != null;

    _guidesNotifier.value =
        _SmartGuides(vertical: newVGuide, horizontal: newHGuide);
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final editorState = ref.watch(pageEditorProvider);
    final notifier = ref.read(pageEditorProvider.notifier);
    final doc = editorState.document;
    final selected = editorState.selectedElement;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: lovio.background,
        appBar: AppBar(
          backgroundColor: lovio.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: lovio.textPrimary,
            onPressed: _onBack,
          ),
          title: Text(
            doc.title.isNotEmpty ? doc.title : 'Page Editor',
            style: AppTextStyles.titleMedium(color: lovio.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Undo
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              color: editorState.canUndo
                  ? lovio.textPrimary
                  : lovio.textSecondary.withOpacity(0.3),
              tooltip: 'Undo',
              onPressed: editorState.canUndo ? () => notifier.undo() : null,
            ),

            // Redo
            IconButton(
              icon: const Icon(Icons.redo_rounded),
              color: editorState.canRedo
                  ? lovio.textPrimary
                  : lovio.textSecondary.withOpacity(0.3),
              tooltip: 'Redo',
              onPressed: editorState.canRedo ? () => notifier.redo() : null,
            ),

            // Prominent Preview Button
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: AnimatedPressable(
                onPressed: () => context.push(AppRoutes.createPagePreview),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: lovio.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: lovio.glow,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Preview ✨',
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
        body: Column(
          children: [
            // Interactive Vertically Scrollable Canvas Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.floating,
                  border: Border.all(color: lovio.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportHeight = constraints.maxHeight;
                    final viewportWidth = constraints.maxWidth;

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
                        math.max(viewportHeight, calculatedHeight + 80);

                    return GestureDetector(
                      onTap: () => notifier.selectElement(null),
                      behavior: HitTestBehavior.translucent,
                      child: SingleChildScrollView(
                        physics: _isInteractingWithElement
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        child: SizedBox(
                          height: totalCanvasHeight,
                          width: viewportWidth,
                          child: PageAnimatedBackground(
                            config: doc.background,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Render Elements with advanced gestures & transforms
                                ...doc.elements.map((elem) {
                                  final isSelected = elem.id == selected?.id;
                                  return _CanvasElementWidget(
                                    key: ValueKey(elem.id),
                                    element: elem,
                                    canvasWidth: viewportWidth,
                                    totalCanvasHeight: totalCanvasHeight,
                                    isSelected: isSelected,
                                    backgroundConfig: doc.background,
                                    onInteractionChange: (interacting) {
                                      setState(() {
                                        _isInteractingWithElement = interacting;
                                      });
                                    },
                                    onSelect: () {
                                      notifier.selectElement(elem.id);
                                    },
                                    onDelete: () =>
                                        notifier.deleteElement(elem.id),
                                    onQuickEdit: () => _handleQuickEdit(elem),
                                    onPositionCommit: (newX, newY) {
                                      notifier.setElementExactPosition(
                                          elem.id, newX, newY);
                                      notifier.recordGestureCommit();
                                    },
                                    onScaleCommit: (newScale) {
                                      notifier.updateElementScaleLive(
                                          elem.id, newScale);
                                      notifier.recordGestureCommit();
                                    },
                                    onRotateCommit: (newRot) {
                                      notifier.updateElementRotationLive(
                                          elem.id, newRot);
                                      notifier.recordGestureCommit();
                                    },
                                    onDragUpdateGuidelines:
                                        (rawX, rawY, elemW, elemH) {
                                      _updateGuidelinesForElement(
                                        rawX,
                                        rawY,
                                        elemW,
                                        elemH,
                                        viewportWidth,
                                        totalCanvasHeight,
                                      );
                                    },
                                    onDragEndGuidelines: () {
                                      _guidesNotifier.value =
                                          const _SmartGuides(
                                              vertical: null,
                                              horizontal: null);
                                    },
                                  );
                                }),

                                // Smart Guidelines Overlay with isolated ValueListenableBuilder (zero frame lag)
                                ValueListenableBuilder<_SmartGuides>(
                                  valueListenable: _guidesNotifier,
                                  builder: (context, guides, _) {
                                    if (guides.vertical == null &&
                                        guides.horizontal == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Positioned.fill(
                                      child: IgnorePointer(
                                        child: CustomPaint(
                                          painter: SmartGuidePainter(
                                            verticalGuide: guides.vertical,
                                            horizontalGuide: guides.horizontal,
                                            guideColor: const Color(0xFFE11D48),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Empty canvas hint
                                if (doc.elements.isEmpty)
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.touch_app_rounded,
                                            size: 40,
                                            color: lovio.textSecondary
                                                .withOpacity(0.4)),
                                        const SizedBox(height: 8),
                                        Text(
                                          PageEditorAssets.emptyCanvasHint,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodyMedium(
                                            color: lovio.textSecondary
                                                .withOpacity(0.6),
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
                    );
                  },
                ),
              ),
            ),

            // Bottom Dock / Editing Tool Panels
            _buildBottomDock(context, lovio, selected),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDock(
      BuildContext context, LovioColors lovio, PageElementModel? selected) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final isElementSelected = selected != null;

    return Container(
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppShadows.floating,
        border: Border(top: BorderSide(color: lovio.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isElementSelected) ...[
              // 1. Header with element label and quick actions
              _buildSelectedElementHeader(lovio, selected, notifier),
              const Divider(height: 1),

              // 2. Element tool panel content
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: _buildElementToolContent(
                      context, lovio, selected, notifier),
                ),
              ),
              const Divider(height: 1),

              // 3. Dedicated Element Editing Toolbar
              _buildElementSubToolbar(lovio, selected, notifier),
            ] else ...[
              // Default Creation Tab Content
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildActiveTabContent(context, lovio, selected),
                ),
              ),
              const Divider(height: 1),

              // Default Tab Selector Row
              _buildDefaultTabSelector(lovio),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedElementHeader(
      LovioColors lovio, PageElementModel selected, PageEditorNotifier notifier) {
    String typeLabel = 'Element';
    IconData typeIcon = Icons.widgets_rounded;
    if (selected.type == PageElementType.text) {
      typeLabel = 'Text';
      typeIcon = Icons.title_rounded;
    } else if (selected.type == PageElementType.photo) {
      typeLabel = 'Photo';
      typeIcon = Icons.photo_library_rounded;
    } else if (selected.type == PageElementType.sticker) {
      typeLabel = 'Sticker';
      typeIcon = Icons.auto_awesome_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          // Scrollable Quick Tool Actions (Scrolls smoothly without overlapping Done button)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected.type == PageElementType.photo)
                    ActionChip(
                      avatar: const Icon(Icons.photo_library_rounded, size: 14),
                      label: const Text('Change Photo',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: lovio.accent.withOpacity(0.15),
                      side: BorderSide(color: lovio.accent.withOpacity(0.6)),
                      onPressed: () => _pickImage(targetElement: selected),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: lovio.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14, color: lovio.accent),
                          const SizedBox(width: 4),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: lovio.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Quick Center H
                  ActionChip(
                    avatar: const Icon(Icons.align_horizontal_center_rounded,
                        size: 14),
                    label: const Text('Center H',
                        style: TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      notifier.alignElementCenterHorizontal(
                          selected.id,
                          MediaQuery.of(context).size.width - 24,
                          180);
                    },
                  ),
                  const SizedBox(width: 6),

                  // Quick Center V
                  ActionChip(
                    avatar: const Icon(Icons.align_vertical_center_rounded,
                        size: 14),
                    label: const Text('Center V',
                        style: TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      notifier.alignElementCenterVertical(
                          selected.id,
                          MediaQuery.of(context).size.height * 0.5,
                          120);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Done Button - Firmly anchored, prominently accessible & never overlapped
          AnimatedPressable(
            onPressed: () => notifier.selectElement(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: lovio.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: lovio.primary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementSubToolbar(
      LovioColors lovio, PageElementModel selected, PageEditorNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _elementToolButton(
            mode: _ElementToolMode.resize,
            icon: Icons.aspect_ratio_rounded,
            label: 'Resize',
            lovio: lovio,
          ),
          _elementToolButton(
            mode: _ElementToolMode.rotate,
            icon: Icons.rotate_right_rounded,
            label: 'Rotate',
            lovio: lovio,
          ),
          _elementToolButton(
            mode: _ElementToolMode.position,
            icon: Icons.open_with_rounded,
            label: 'Position',
            lovio: lovio,
          ),
          _elementToolButton(
            mode: _ElementToolMode.style,
            icon: selected.type == PageElementType.text
                ? Icons.text_fields_rounded
                : selected.type == PageElementType.photo
                    ? Icons.auto_fix_high_rounded
                    : Icons.auto_awesome_rounded,
            label: 'Style',
            lovio: lovio,
          ),
          InkWell(
            onTap: () {
              notifier.deleteElement(selected.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Element removed (tap Undo at top to restore)'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 20, color: Colors.red),
                  SizedBox(height: 2),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _elementToolButton({
    required _ElementToolMode mode,
    required IconData icon,
    required String label,
    required LovioColors lovio,
  }) {
    final isActive = _elementToolMode == mode;
    return InkWell(
      onTap: () => setState(() => _elementToolMode = mode),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? lovio.accent : lovio.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? lovio.accent : lovio.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementToolContent(BuildContext context, LovioColors lovio,
      PageElementModel selected, PageEditorNotifier notifier) {
    switch (_elementToolMode) {
      case _ElementToolMode.resize:
        return _buildResizeToolPanel(lovio, selected, notifier);
      case _ElementToolMode.rotate:
        return _buildRotateToolPanel(lovio, selected, notifier);
      case _ElementToolMode.position:
        return _buildPositionToolPanel(lovio, selected, notifier);
      case _ElementToolMode.style:
        return _buildStyleToolPanel(context, lovio, selected);
    }
  }

  Widget _buildResizeToolPanel(LovioColors lovio, PageElementModel selected,
      PageEditorNotifier notifier) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scale (${(selected.scale * 100).round()}%)',
                style: AppTextStyles.labelMedium(color: lovio.textPrimary),
              ),
              Text(
                'Pinch with 2 fingers or drag handle',
                style: AppTextStyles.bodySmall(
                  color: lovio.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Scale Slider & Step buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                color: lovio.accent,
                onPressed: () {
                  final next = (selected.scale - 0.1).clamp(0.25, 4.0);
                  notifier.updateElementScaleLive(selected.id, next);
                },
              ),
              Expanded(
                child: Slider(
                  value: selected.scale.clamp(0.25, 4.0),
                  min: 0.25,
                  max: 4.0,
                  activeColor: lovio.accent,
                  onChanged: (val) =>
                      notifier.updateElementScaleLive(selected.id, val),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                color: lovio.accent,
                onPressed: () {
                  final next = (selected.scale + 0.1).clamp(0.25, 4.0);
                  notifier.updateElementScaleLive(selected.id, next);
                },
              ),
            ],
          ),

          // Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _scalePresetChip('50%', 0.5, selected, notifier, lovio),
                _scalePresetChip('75%', 0.75, selected, notifier, lovio),
                _scalePresetChip('100%', 1.0, selected, notifier, lovio),
                _scalePresetChip('125%', 1.25, selected, notifier, lovio),
                _scalePresetChip('150%', 1.5, selected, notifier, lovio),
                _scalePresetChip('200%', 2.0, selected, notifier, lovio),
              ],
            ),
          ),

          // If text element: provide direct Font Size controls too
          if (selected.type == PageElementType.text) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Font Size (${(selected.fontSize ?? 20).round()}pt)',
                  style: AppTextStyles.labelSmall(color: lovio.textSecondary),
                ),
                const SizedBox(width: 8),
                ...[16, 20, 26, 34, 44].map((sizeVal) {
                  final isCurr = (selected.fontSize ?? 20).round() == sizeVal;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () {
                        notifier.updateElement(
                          selected.id,
                          (e) => e.copyWith(fontSize: sizeVal.toDouble()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCurr
                              ? lovio.accent
                              : lovio.accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${sizeVal}p',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCurr ? Colors.white : lovio.accent,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Expanded(
                  child: Slider(
                    value: (selected.fontSize ?? 20).clamp(12.0, 56.0),
                    min: 12.0,
                    max: 56.0,
                    activeColor: lovio.accent,
                    onChanged: (val) {
                      notifier.updateElement(
                        selected.id,
                        (e) => e.copyWith(fontSize: val),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _scalePresetChip(String label, double scaleVal,
      PageElementModel selected, PageEditorNotifier notifier, LovioColors lovio) {
    final isSelected = (selected.scale - scaleVal).abs() < 0.05;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        selectedColor: lovio.accent.withOpacity(0.2),
        onSelected: (_) =>
            notifier.updateElementScaleLive(selected.id, scaleVal),
      ),
    );
  }

  Widget _buildRotateToolPanel(LovioColors lovio, PageElementModel selected,
      PageEditorNotifier notifier) {
    final degrees = (selected.rotation * 180 / math.pi).round() % 360;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rotation ($degrees°)',
                style: AppTextStyles.labelMedium(color: lovio.textPrimary),
              ),
              TextButton.icon(
                onPressed: () =>
                    notifier.updateElementRotationLive(selected.id, 0.0),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('0° Straighten',
                    style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Rotation Slider
          Slider(
            value: selected.rotation.clamp(-math.pi, math.pi),
            min: -math.pi,
            max: math.pi,
            activeColor: lovio.accent,
            onChanged: (val) =>
                notifier.updateElementRotationLive(selected.id, val),
          ),

          // Snap Angles & Fine Step buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  label: const Text('↺ -15°', style: TextStyle(fontSize: 11)),
                  onPressed: () => notifier.rotateElementStep(selected.id, -15),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('0°', style: TextStyle(fontSize: 11)),
                  onPressed: () =>
                      notifier.updateElementRotationLive(selected.id, 0.0),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('90°', style: TextStyle(fontSize: 11)),
                  onPressed: () =>
                      notifier.updateElementRotationLive(selected.id, math.pi / 2),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('180°', style: TextStyle(fontSize: 11)),
                  onPressed: () =>
                      notifier.updateElementRotationLive(selected.id, math.pi),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('270°', style: TextStyle(fontSize: 11)),
                  onPressed: () => notifier.updateElementRotationLive(
                      selected.id, 3 * math.pi / 2),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('↻ +15°', style: TextStyle(fontSize: 11)),
                  onPressed: () => notifier.rotateElementStep(selected.id, 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionToolPanel(LovioColors lovio, PageElementModel selected,
      PageEditorNotifier notifier) {
    final canvasW = MediaQuery.of(context).size.width - 24;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 4-Way Precision Nudge D-Pad
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: lovio.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lovio.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _nudgeIconButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      onTap: () => notifier.nudgeElement(selected.id, 0, -3),
                      tooltip: 'Up',
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _nudgeIconButton(
                          icon: Icons.keyboard_arrow_left_rounded,
                          onTap: () => notifier.nudgeElement(selected.id, -3, 0),
                          tooltip: 'Left',
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: Icon(Icons.drag_indicator_rounded,
                              size: 14, color: lovio.textSecondary),
                        ),
                        _nudgeIconButton(
                          icon: Icons.keyboard_arrow_right_rounded,
                          onTap: () => notifier.nudgeElement(selected.id, 3, 0),
                          tooltip: 'Right',
                        ),
                      ],
                    ),
                    _nudgeIconButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: () => notifier.nudgeElement(selected.id, 0, 3),
                      tooltip: 'Down',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Smart Alignment Grid
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Alignments',
                        style: AppTextStyles.labelSmall(
                            color: lovio.textSecondary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Icon(
                              Icons.align_horizontal_center_rounded,
                              size: 13),
                          label: const Text('Center H',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () => notifier.alignElementCenterHorizontal(
                              selected.id, canvasW, 180),
                        ),
                        ActionChip(
                          avatar: const Icon(
                              Icons.align_vertical_center_rounded,
                              size: 13),
                          label: const Text('Center V',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () => notifier.alignElementCenterVertical(
                              selected.id, 450, 120),
                        ),
                        ActionChip(
                          avatar: const Icon(
                              Icons.align_horizontal_left_rounded,
                              size: 13),
                          label: const Text('Left (24p)',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () => notifier.setElementExactPosition(
                              selected.id, 24.0, selected.y),
                        ),
                        ActionChip(
                          avatar: const Icon(
                              Icons.align_horizontal_right_rounded,
                              size: 13),
                          label: const Text('Right',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () => notifier.setElementExactPosition(
                              selected.id, canvasW - 204, selected.y),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.arrow_upward_rounded,
                              size: 13),
                          label: const Text('Bring Front',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () => notifier.bringToFront(selected.id),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.arrow_downward_rounded,
                              size: 13),
                          label: const Text('Send Back',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () => notifier.sendToBack(selected.id),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.copy_rounded, size: 13),
                          label: const Text('Duplicate',
                              style: TextStyle(fontSize: 10)),
                          onPressed: () =>
                              notifier.duplicateElement(selected.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nudgeIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildStyleToolPanel(
      BuildContext context, LovioColors lovio, PageElementModel selected) {
    if (selected.type == PageElementType.text) {
      return _buildTextPanel(lovio, selected);
    } else if (selected.type == PageElementType.photo) {
      return _buildPhotosPanel(lovio, selected);
    } else if (selected.type == PageElementType.sticker) {
      return _buildStickersPanel(lovio, selected);
    }
    return const SizedBox.shrink();
  }

  Widget _buildDefaultTabSelector(LovioColors lovio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _defaultTabButton(
            tab: _EditorTab.text,
            icon: Icons.title_rounded,
            label: 'Text',
            lovio: lovio,
          ),
          _defaultTabButton(
            tab: _EditorTab.background,
            icon: Icons.color_lens_rounded,
            label: 'Background',
            lovio: lovio,
          ),
          _defaultTabButton(
            tab: _EditorTab.photos,
            icon: Icons.photo_library_rounded,
            label: 'Photos',
            lovio: lovio,
          ),
          _defaultTabButton(
            tab: _EditorTab.stickers,
            icon: Icons.auto_awesome_rounded,
            label: 'Stickers',
            lovio: lovio,
          ),
          _defaultTabButton(
            tab: _EditorTab.layers,
            icon: Icons.layers_rounded,
            label: 'Layers',
            lovio: lovio,
          ),
        ],
      ),
    );
  }

  Widget _defaultTabButton({
    required _EditorTab tab,
    required IconData icon,
    required String label,
    required LovioColors lovio,
  }) {
    final isActive = _activeTab == tab;
    return InkWell(
      onTap: () {
        if (tab == _EditorTab.photos) {
          setState(() => _activeTab = _EditorTab.photos);
          _pickImage();
        } else {
          setState(() => _activeTab = tab);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? lovio.accent : lovio.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? lovio.accent : lovio.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(
      BuildContext context, LovioColors lovio, PageElementModel? selected) {
    switch (_activeTab) {
      case _EditorTab.text:
        return _buildTextPanel(lovio, selected);
      case _EditorTab.background:
        return _buildBackgroundPanel(lovio);
      case _EditorTab.photos:
        return _buildPhotosPanel(lovio, selected);
      case _EditorTab.stickers:
        return _buildStickersPanel(lovio, selected);
      case _EditorTab.layers:
        return _buildLayersPanel(lovio, selected);
    }
  }

  Widget _buildElementActionsRow(
      LovioColors lovio, PageElementModel selected, PageEditorNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.arrow_upward_rounded, size: 14),
            label: const Text('Bring Front', style: TextStyle(fontSize: 11)),
            onPressed: () => notifier.bringToFront(selected.id),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.arrow_downward_rounded, size: 14),
            label: const Text('Send Back', style: TextStyle(fontSize: 11)),
            onPressed: () => notifier.sendToBack(selected.id),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.copy_rounded, size: 14),
            label: const Text('Duplicate', style: TextStyle(fontSize: 11)),
            onPressed: () => notifier.duplicateElement(selected.id),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.delete_outline_rounded,
                size: 14, color: Colors.red),
            label: const Text('Delete',
                style: TextStyle(fontSize: 11, color: Colors.red)),
            side: const BorderSide(color: Colors.red),
            onPressed: () => notifier.deleteElement(selected.id),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleSliderRow(
      LovioColors lovio, PageElementModel selected, PageEditorNotifier notifier) {
    return Row(
      children: [
        Text(
          'Size (${(selected.scale * 100).round()}%)',
          style: AppTextStyles.labelSmall(color: lovio.textSecondary),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
          color: lovio.accent,
          tooltip: 'Smaller',
          onPressed: () {
            final next = (selected.scale - 0.1).clamp(0.25, 4.0);
            notifier.updateElementScaleLive(selected.id, next);
          },
        ),
        Expanded(
          child: Slider(
            value: selected.scale.clamp(0.25, 4.0),
            min: 0.25,
            max: 4.0,
            activeColor: lovio.accent,
            onChanged: (val) =>
                notifier.updateElementScaleLive(selected.id, val),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          color: lovio.accent,
          tooltip: 'Larger',
          onPressed: () {
            final next = (selected.scale + 0.1).clamp(0.25, 4.0);
            notifier.updateElementScaleLive(selected.id, next);
          },
        ),
      ],
    );
  }

  Widget _buildRotationSliderRow(
      LovioColors lovio, PageElementModel selected, PageEditorNotifier notifier) {
    final degrees = (selected.rotation * 180 / math.pi).round();
    return Row(
      children: [
        Text(
          'Rotate ($degrees°)',
          style: AppTextStyles.labelSmall(color: lovio.textSecondary),
        ),
        TextButton(
          onPressed: () =>
              notifier.updateElementRotationLive(selected.id, 0.0),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('0° Reset', style: TextStyle(fontSize: 11)),
        ),
        Expanded(
          child: Slider(
            value: selected.rotation.clamp(-math.pi, math.pi),
            min: -math.pi,
            max: math.pi,
            activeColor: lovio.accent,
            onChanged: (val) =>
                notifier.updateElementRotationLive(selected.id, val),
          ),
        ),
      ],
    );
  }

  // 1. Text Panel
  Widget _buildTextPanel(LovioColors lovio, PageElementModel? selected) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final isTextSelected =
        selected != null && selected.type == PageElementType.text;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => notifier.addText(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lovio.accent,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(width: 8),
                if (isTextSelected) ...[
                  OutlinedButton.icon(
                    onPressed: () => _showEditTextDialog(selected),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Edit Words'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: lovio.accent,
                      side: BorderSide(color: lovio.accent),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.format_bold_rounded,
                      color:
                          selected.isBold ? lovio.accent : lovio.textSecondary,
                    ),
                    tooltip: 'Bold',
                    onPressed: () => notifier.updateElement(
                      selected.id,
                      (e) => e.copyWith(isBold: !e.isBold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.format_italic_rounded,
                      color:
                          selected.isItalic ? lovio.accent : lovio.textSecondary,
                    ),
                    tooltip: 'Italic',
                    onPressed: () => notifier.updateElement(
                      selected.id,
                      (e) => e.copyWith(isItalic: !e.isItalic),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      selected.textAlign == 'center'
                          ? Icons.format_align_center_rounded
                          : selected.textAlign == 'right'
                              ? Icons.format_align_right_rounded
                              : Icons.format_align_left_rounded,
                      color: lovio.accent,
                    ),
                    tooltip: 'Alignment',
                    onPressed: () {
                      final nextAlign = selected.textAlign == 'center'
                          ? 'right'
                          : selected.textAlign == 'right'
                              ? 'left'
                              : 'center';
                      notifier.updateElement(
                        selected.id,
                        (e) => e.copyWith(textAlign: nextAlign),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Fonts Picker
          if (isTextSelected) ...[
            Text('Font Style (16 Google Fonts with Live Preview)',
                style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _fonts.map((f) {
                  final isCurr = selected.fontFamily == f;
                  final fontStyle = _resolveGoogleFontStyle(f);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        f,
                        style: fontStyle.copyWith(
                          fontSize: 13,
                          fontWeight:
                              isCurr ? FontWeight.bold : FontWeight.normal,
                          color: isCurr ? lovio.accent : lovio.textPrimary,
                        ),
                      ),
                      selected: isCurr,
                      selectedColor: lovio.accent.withOpacity(0.18),
                      onSelected: (val) {
                        notifier.updateElement(
                          selected.id,
                          (e) => e.copyWith(fontFamily: f),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Color Selector
            Text('Text Color (16 Colors)',
                style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _textColors.map((color) {
                  final isSelected = selected.textColor == color;
                  return GestureDetector(
                    onTap: () {
                      notifier.updateElement(
                        selected.id,
                        (e) => e.copyWith(textColor: color),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? lovio.accent : lovio.border,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: color == 0xFFFFFFFF
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Letter Spacing Slider
            Row(
              children: [
                Text(
                  'Spacing (${selected.letterSpacing.toStringAsFixed(1)})',
                  style: AppTextStyles.labelSmall(color: lovio.textSecondary),
                ),
                Expanded(
                  child: Slider(
                    value: selected.letterSpacing.clamp(-1.0, 6.0),
                    min: -1.0,
                    max: 6.0,
                    divisions: 14,
                    activeColor: lovio.accent,
                    onChanged: (val) {
                      notifier.updateElement(
                        selected.id,
                        (e) => e.copyWith(letterSpacing: val),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Line Height Slider
            Row(
              children: [
                Text(
                  'Line Height (${(selected.lineHeight ?? 1.45).toStringAsFixed(2)})',
                  style: AppTextStyles.labelSmall(color: lovio.textSecondary),
                ),
                Expanded(
                  child: Slider(
                    value: (selected.lineHeight ?? 1.45).clamp(1.0, 2.4),
                    min: 1.0,
                    max: 2.4,
                    divisions: 14,
                    activeColor: lovio.accent,
                    onChanged: (val) {
                      notifier.updateElement(
                        selected.id,
                        (e) => e.copyWith(lineHeight: val),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Text Background Highlights
            Row(
              children: [
                Text('Background Highlight',
                    style:
                        AppTextStyles.labelSmall(color: lovio.textSecondary)),
                const SizedBox(width: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => notifier.updateElement(
                          selected.id,
                          (e) => e.copyWith(textBackgroundColor: null),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: lovio.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('None',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      ...[
                        0xB3FFFFFF, // Soft White
                        0xB3FFFBEB, // Soft Cream
                        0xB3FCE7F3, // Soft Rose
                        0xB3EFF6FF, // Soft Ice
                        0xB31E293B, // Slate Charcoal
                      ].map((bgCol) {
                        return GestureDetector(
                          onTap: () => notifier.updateElement(
                            selected.id,
                            (e) => e.copyWith(textBackgroundColor: bgCol),
                          ),
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Color(bgCol),
                              shape: BoxShape.circle,
                              border: Border.all(color: lovio.border),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildRotationSliderRow(lovio, selected, notifier),
            const SizedBox(height: 10),
            _buildElementActionsRow(lovio, selected, notifier),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Select any text on canvas to change its font, color, and size ✨',
              style: AppTextStyles.bodySmall(
                color: lovio.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. Background Panel
  Widget _buildBackgroundPanel(LovioColors lovio) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final doc = ref.watch(pageEditorProvider).document;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Animation Effects',
              style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BackgroundAnimationEffect.values.map((eff) {
                final isSelected = doc.background.animationEffect == eff;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(eff.label),
                    selected: isSelected,
                    selectedColor: lovio.accent.withOpacity(0.25),
                    onSelected: (val) {
                      notifier.setBackground(
                        doc.background.copyWith(
                          type: PageBackgroundType.animated,
                          animationEffect: eff,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Text('Color Palette & Gradients',
              style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._gradientPresets.map((preset) {
                  return GestureDetector(
                    onTap: () {
                      notifier.setBackground(
                        doc.background.copyWith(
                          type: PageBackgroundType.gradient,
                          gradientColors: preset.colors,
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: preset.gradient,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: AppShadows.softCard,
                      ),
                    ),
                  );
                }),
                ..._solidPalette.map((col) {
                  return GestureDetector(
                    onTap: () {
                      notifier.setBackground(
                        doc.background.copyWith(
                          type: PageBackgroundType.solid,
                          solidColor: col,
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(col),
                        border: Border.all(color: lovio.border, width: 1.5),
                        boxShadow: AppShadows.softCard,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Photos Panel
  Widget _buildPhotosPanel(LovioColors lovio, PageElementModel? selected) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final isPhotoSelected =
        selected != null && selected.type == PageElementType.photo;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPhotoSelected) ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImage(targetElement: selected),
                  icon: const Icon(Icons.change_circle_rounded, size: 18),
                  label: const Text('Change Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lovio.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _addNewPhoto,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: const Text('Add Another'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: lovio.accent,
                    side: BorderSide(color: lovio.accent),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: const Text('Select Photo from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lovio.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          if (isPhotoSelected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Photo Frame & Shape (17 Options)',
                    style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
                TextButton.icon(
                  onPressed: () => _showPhotoShapeSheet(selected),
                  icon: const Icon(Icons.grid_view_rounded, size: 14),
                  label: const Text('View All', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: lovio.accent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PhotoShape.values.map((shape) {
                  final isCurr = selected.photoShape == shape;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(shape.label),
                      selected: isCurr,
                      selectedColor: lovio.accent.withOpacity(0.2),
                      onSelected: (val) {
                        notifier.updateElement(
                          selected.id,
                          (e) => e.copyWith(photoShape: shape),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Text(
                  'Border (${selected.borderWidth.round()}px)',
                  style: AppTextStyles.labelSmall(color: lovio.textSecondary),
                ),
                Expanded(
                  child: Slider(
                    value: selected.borderWidth.clamp(0.0, 14.0),
                    min: 0.0,
                    max: 14.0,
                    divisions: 14,
                    activeColor: lovio.accent,
                    onChanged: (val) {
                      notifier.updateElement(
                        selected.id,
                        (e) => e.copyWith(borderWidth: val),
                      );
                    },
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Text('Border Color',
                    style:
                        AppTextStyles.labelSmall(color: lovio.textSecondary)),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _textColors.map((color) {
                        final isSel = selected.borderColor == color;
                        return GestureDetector(
                          onTap: () {
                            notifier.updateElement(
                              selected.id,
                              (e) => e.copyWith(borderColor: color),
                            );
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? lovio.accent : lovio.border,
                                width: isSel ? 2.5 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildScaleSliderRow(lovio, selected, notifier),
            const SizedBox(height: 6),
            _buildRotationSliderRow(lovio, selected, notifier),
            const SizedBox(height: 10),
            _buildElementActionsRow(lovio, selected, notifier),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Select any photo on canvas to switch its shape across 16 creative frames, customize borders, and resize ✨',
              style: AppTextStyles.bodySmall(
                color: lovio.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4. Stickers Panel
  Widget _buildStickersPanel(LovioColors lovio, PageElementModel? selected) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final isStickerSelected =
        selected != null && selected.type == PageElementType.sticker;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isStickerSelected) ...[
            Text('Sticker Animation',
                style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: StickerAnimationEffect.values.map((eff) {
                  final isCurr = selected.stickerAnimation == eff;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(eff.label),
                      selected: isCurr,
                      selectedColor: lovio.accent.withOpacity(0.2),
                      onSelected: (val) {
                        notifier.updateElement(
                          selected.id,
                          (e) => e.copyWith(stickerAnimation: eff),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            _buildScaleSliderRow(lovio, selected, notifier),
            const SizedBox(height: 6),
            _buildRotationSliderRow(lovio, selected, notifier),
            const SizedBox(height: 10),
            _buildElementActionsRow(lovio, selected, notifier),
            const Divider(height: 14),
          ],

          Text('Tap Sticker to Add',
              style: AppTextStyles.labelSmall(color: lovio.textSecondary)),
          const SizedBox(height: 6),
          ..._stickerCategories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: lovio.textSecondary),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: entry.value.map((symbol) {
                      return GestureDetector(
                        onTap: () {
                          notifier.addSticker(symbol);
                          setState(
                              () => _elementToolMode = _ElementToolMode.style);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: lovio.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: lovio.border),
                          ),
                          child: Text(symbol,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // 5. Layers Panel
  Widget _buildLayersPanel(LovioColors lovio, PageElementModel? selected) {
    final notifier = ref.read(pageEditorProvider.notifier);
    final doc = ref.watch(pageEditorProvider).document;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Canvas Layers (${doc.elements.length})',
                style: AppTextStyles.labelMedium(color: lovio.textPrimary),
              ),
              if (doc.elements.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClearCanvas(notifier, lovio),
                  icon: const Icon(Icons.delete_sweep_rounded,
                      size: 16, color: Colors.red),
                  label: const Text('Clear All',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (doc.elements.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                PageEditorAssets.emptyLayersHint,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(color: lovio.textSecondary),
              ),
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: doc.elements.reversed.map((elem) {
                  final isSelected = elem.id == selected?.id;
                  String typeLabel = 'Element';
                  IconData typeIcon = Icons.widgets_rounded;
                  String previewText = '';

                  if (elem.type == PageElementType.text) {
                    typeLabel = 'Text';
                    typeIcon = Icons.title_rounded;
                    previewText = elem.text ?? '';
                  } else if (elem.type == PageElementType.photo) {
                    typeLabel = 'Photo';
                    typeIcon = Icons.photo_rounded;
                    previewText = elem.photoShape.label;
                  } else if (elem.type == PageElementType.sticker) {
                    typeLabel = 'Sticker';
                    typeIcon = Icons.auto_awesome_rounded;
                    previewText = elem.stickerSymbol ?? '❤️';
                  }

                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? lovio.accent.withOpacity(0.08)
                          : lovio.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? lovio.accent
                            : lovio.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: AppShadows.softCard,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => notifier.selectElement(elem.id),
                          child: Row(
                            children: [
                              Icon(typeIcon,
                                  size: 16,
                                  color: isSelected
                                      ? lovio.accent
                                      : lovio.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  typeLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? lovio.accent
                                        : lovio.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: lovio.accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Selected',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => notifier.selectElement(elem.id),
                          child: Text(
                            previewText,
                            style: AppTextStyles.bodySmall(
                                color: lovio.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => notifier.bringToFront(elem.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: lovio.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: lovio.border),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_upward_rounded,
                                        size: 12),
                                    SizedBox(width: 2),
                                    Text('Top',
                                        style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => notifier.sendToBack(elem.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: lovio.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: lovio.border),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_downward_rounded,
                                        size: 12),
                                    SizedBox(width: 2),
                                    Text('Bottom',
                                        style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  notifier.duplicateElement(elem.id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: lovio.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: lovio.border),
                                ),
                                child: const Icon(Icons.copy_rounded,
                                    size: 14),
                              ),
                            ),
                            InkWell(
                              onTap: () => notifier.deleteElement(elem.id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 14,
                                    color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle _resolveGoogleFontStyle(String fontName) {
  switch (fontName) {
    case 'Great Vibes':
      return GoogleFonts.greatVibes();
    case 'Dancing Script':
      return GoogleFonts.dancingScript();
    case 'Caveat':
      return GoogleFonts.caveat();
    case 'Poppins':
      return GoogleFonts.poppins();
    case 'Montserrat':
      return GoogleFonts.montserrat();
    case 'Cormorant Garamond':
      return GoogleFonts.cormorantGaramond();
    case 'Parisienne':
      return GoogleFonts.parisienne();
    case 'Cinzel':
      return GoogleFonts.cinzel();
    case 'Sacramento':
      return GoogleFonts.sacramento();
    case 'Pacifico':
      return GoogleFonts.pacifico();
    case 'Satisfy':
      return GoogleFonts.satisfy();
    case 'Alex Brush':
      return GoogleFonts.alexBrush();
    case 'Marck Script':
      return GoogleFonts.marckScript();
    case 'Lora':
      return GoogleFonts.lora();
    case 'Inter':
      return GoogleFonts.inter();
    case 'Playfair Display':
    default:
      return GoogleFonts.playfairDisplay();
  }
}

/// Canvas Element Widget with Advanced, Silky-Smooth Touch Gestures:
/// - True element center tracking with dedicated GlobalKey (exact rotate and resize)
/// - Counter-scaled and counter-rotated corner controls with generous 44x44 touch targets
/// - Two-finger pinch-to-resize & twist-to-rotate with pointer transition guard (no jumps)
/// - Single-finger drag with non-locking magnetic smart guidelines
/// - Active, responsive Bottom-Left Quick Edit handle for all element types
class _CanvasElementWidget extends StatefulWidget {
  final PageElementModel element;
  final double canvasWidth;
  final double totalCanvasHeight;
  final bool isSelected;
  final PageBackgroundConfig backgroundConfig;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final VoidCallback onQuickEdit;
  final void Function(double x, double y) onPositionCommit;
  final void Function(double scale) onScaleCommit;
  final void Function(double rotation) onRotateCommit;
  final void Function(double rawX, double rawY, double elemW, double elemH)
      onDragUpdateGuidelines;
  final VoidCallback onDragEndGuidelines;
  final ValueChanged<bool>? onInteractionChange;

  const _CanvasElementWidget({
    super.key,
    required this.element,
    required this.canvasWidth,
    required this.totalCanvasHeight,
    required this.isSelected,
    required this.backgroundConfig,
    this.onInteractionChange,
    required this.onSelect,
    required this.onDelete,
    required this.onQuickEdit,
    required this.onPositionCommit,
    required this.onScaleCommit,
    required this.onRotateCommit,
    required this.onDragUpdateGuidelines,
    required this.onDragEndGuidelines,
  });

  @override
  State<_CanvasElementWidget> createState() => _CanvasElementWidgetState();
}

class _CanvasElementWidgetState extends State<_CanvasElementWidget> {
  final GlobalKey _elementBoxKey = GlobalKey();

  late double _localX;
  late double _localY;
  late double _localScale;
  late double _localRotation;

  bool _isInteracting = false;

  // Single-finger drag tracking
  double _dragStartFingerX = 0;
  double _dragStartFingerY = 0;
  double _dragStartLocalX = 0;
  double _dragStartLocalY = 0;

  // Two-finger pinch tracking
  int _lastPointerCount = 0;
  double _pinchStartScale = 1.0;
  double _pinchStartRotation = 0.0;
  double _gestureStartScaleRatio = 1.0;
  double _gestureStartRotationDelta = 0.0;

  // Handle drag tracking
  Offset _elementCenterGlobal = Offset.zero;
  double _resizeStartDistance = 1.0;
  double _resizeStartScale = 1.0;
  double _rotateStartAngle = 0.0;
  double _rotateStartElemAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _localX = widget.element.x;
    _localY = widget.element.y;
    _localScale = widget.element.scale;
    _localRotation = widget.element.rotation;
  }

  @override
  void didUpdateWidget(_CanvasElementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInteracting) {
      _localX = widget.element.x;
      _localY = widget.element.y;
      _localScale = widget.element.scale;
      _localRotation = widget.element.rotation;
    }
  }

  Offset? _getElementCenter() {
    final box = _elementBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(box.size.center(Offset.zero));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final elem = widget.element;
    final isSelected = widget.isSelected;
    final lovio = context.lovioColors;

    final counterScale = (1.0 / _localScale).clamp(0.4, 2.5);
    const double handleInset = 22.0;

    return Positioned(
      left: _localX - handleInset,
      top: _localY - handleInset,
      child: Transform.rotate(
        angle: _localRotation,
        child: Transform.scale(
          scale: _localScale,
          child: Container(
            padding: const EdgeInsets.all(handleInset),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Core Element Container with smooth pinch & drag gestures
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSelect,
                  onDoubleTap: widget.onQuickEdit,
                  onScaleStart: (details) {
                    widget.onSelect();
                    widget.onInteractionChange?.call(true);
                    _isInteracting = true;
                    _lastPointerCount = details.pointerCount;
                    _dragStartFingerX = details.focalPoint.dx;
                    _dragStartFingerY = details.focalPoint.dy;
                    _dragStartLocalX = _localX;
                    _dragStartLocalY = _localY;
                    _pinchStartScale = _localScale;
                    _pinchStartRotation = _localRotation;
                    _gestureStartScaleRatio = 1.0;
                    _gestureStartRotationDelta = 0.0;
                  },
                  onScaleUpdate: (details) {
                    if (details.pointerCount > 1) {
                      // Two-finger pinch-to-resize & twist-to-rotate
                      if (_lastPointerCount <= 1) {
                        _lastPointerCount = details.pointerCount;
                        _pinchStartScale = _localScale;
                        _pinchStartRotation = _localRotation;
                        _gestureStartScaleRatio = details.scale;
                        _gestureStartRotationDelta = details.rotation;
                        return;
                      }
                      _lastPointerCount = details.pointerCount;

                      final scaleRatio = details.scale / _gestureStartScaleRatio;
                      final newScale =
                          (_pinchStartScale * scaleRatio).clamp(0.25, 4.0);
                      final rotationDelta =
                          details.rotation - _gestureStartRotationDelta;
                      final newRotation =
                          (_pinchStartRotation + rotationDelta) % (2 * math.pi);

                      setState(() {
                        _localScale = newScale;
                        _localRotation = newRotation;
                      });
                    } else {
                      // Single-finger drag with magnetic guidelines
                      if (_lastPointerCount > 1) {
                        _lastPointerCount = 1;
                        _dragStartFingerX = details.focalPoint.dx;
                        _dragStartFingerY = details.focalPoint.dy;
                        _dragStartLocalX = _localX;
                        _dragStartLocalY = _localY;
                        return;
                      }
                      _lastPointerCount = 1;

                      final deltaX = details.focalPoint.dx - _dragStartFingerX;
                      final deltaY = details.focalPoint.dy - _dragStartFingerY;
                      final rawX = (_dragStartLocalX + deltaX)
                          .clamp(-40.0, widget.canvasWidth + 40.0);
                      final rawY = (_dragStartLocalY + deltaY)
                          .clamp(-40.0, widget.totalCanvasHeight + 40.0);

                      final box = _elementBoxKey.currentContext?.findRenderObject()
                          as RenderBox?;
                      final elemW = box?.size.width ?? 180.0;
                      final elemH = box?.size.height ?? 180.0;

                      widget.onDragUpdateGuidelines(rawX, rawY, elemW, elemH);

                      setState(() {
                        _localX = rawX;
                        _localY = rawY;
                      });
                    }
                  },
                  onScaleEnd: (_) {
                    _isInteracting = false;
                    widget.onInteractionChange?.call(false);
                    widget.onDragEndGuidelines();
                    widget.onPositionCommit(_localX, _localY);
                    if (_localScale != widget.element.scale) {
                      widget.onScaleCommit(_localScale);
                    }
                    if (_localRotation != widget.element.rotation) {
                      widget.onRotateCommit(_localRotation);
                    }
                  },
                  child: Container(
                    key: _elementBoxKey,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: lovio.accent.withOpacity(0.04),
                            border: Border.all(
                              color: lovio.accent.withOpacity(0.9),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    padding: isSelected
                        ? const EdgeInsets.all(6)
                        : EdgeInsets.zero,
                    child: _buildElementInner(
                        elem, widget.canvasWidth, widget.backgroundConfig),
                  ),
                ),

              // 2. Corner interactive controls around selected element (Inside hit-test box!)
              if (isSelected) ...[
                // Top-Right: Delete Handle (Red Close)
                Positioned(
                  top: -12,
                  right: -12,
                  child: Transform.scale(
                    scale: counterScale,
                    child: Transform.rotate(
                      angle: -_localRotation,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onDelete();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.softCard,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.red, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-Left: Rotate Handle (Orbiting with true element center via raw Pointer events)
                Positioned(
                  top: -12,
                  left: -12,
                  child: Transform.scale(
                    scale: counterScale,
                    child: Transform.rotate(
                      angle: -_localRotation,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          widget.onSelect();
                          _isInteracting = true;
                          final center = _getElementCenter();
                          if (center != null) {
                            _elementCenterGlobal = center;
                            _rotateStartAngle = math.atan2(
                              e.position.dy - center.dy,
                              e.position.dx - center.dx,
                            );
                            _rotateStartElemAngle = _localRotation;
                          }
                        },
                        onPointerMove: (e) {
                          if (!_isInteracting) return;
                          final currentAngle = math.atan2(
                            e.position.dy - _elementCenterGlobal.dy,
                            e.position.dx - _elementCenterGlobal.dx,
                          );
                          final delta = currentAngle - _rotateStartAngle;
                          var newRot =
                              (_rotateStartElemAngle + delta) % (2 * math.pi);
                          if (newRot < 0) newRot += 2 * math.pi;

                          // Cardinal snap (0°, 90°, 180°, 270°)
                          const snap = 0.06;
                          if (newRot < snap || newRot > 2 * math.pi - snap) {
                            newRot = 0.0;
                          } else if ((newRot - math.pi / 2).abs() < snap) {
                            newRot = math.pi / 2;
                          } else if ((newRot - math.pi).abs() < snap) {
                            newRot = math.pi;
                          } else if ((newRot - 3 * math.pi / 2).abs() <
                              snap) {
                            newRot = 3 * math.pi / 2;
                          }

                          setState(() {
                            _localRotation = newRot;
                          });
                        },
                        onPointerUp: (e) {
                          _isInteracting = false;
                          widget.onRotateCommit(_localRotation);
                        },
                        onPointerCancel: (e) {
                          _isInteracting = false;
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.softCard,
                              border: Border.all(
                                  color: const Color(0xFF4361EE), width: 2),
                            ),
                            child: const Icon(Icons.rotate_right_rounded,
                                color: Color(0xFF4361EE), size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom-Right: Distance-Based Scale/Resize Handle via raw Pointer events
                Positioned(
                  bottom: -12,
                  right: -12,
                  child: Transform.scale(
                    scale: counterScale,
                    child: Transform.rotate(
                      angle: -_localRotation,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          widget.onSelect();
                          _isInteracting = true;
                          final center = _getElementCenter();
                          if (center != null) {
                            _elementCenterGlobal = center;
                            _resizeStartDistance =
                                (e.position - center).distance;
                            _resizeStartScale = _localScale;
                          }
                        },
                        onPointerMove: (e) {
                          if (!_isInteracting) return;
                          final currentDistance =
                              (e.position - _elementCenterGlobal).distance;
                          if (_resizeStartDistance > 10.0) {
                            final factor =
                                currentDistance / _resizeStartDistance;
                            final newScale =
                                (_resizeStartScale * factor).clamp(0.25, 4.0);
                            setState(() {
                              _localScale = newScale;
                            });
                          }
                        },
                        onPointerUp: (e) {
                          _isInteracting = false;
                          widget.onScaleCommit(_localScale);
                        },
                        onPointerCancel: (e) {
                          _isInteracting = false;
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.softCard,
                              border: Border.all(
                                  color: const Color(0xFF10B981), width: 2),
                            ),
                            child: const Icon(Icons.aspect_ratio_rounded,
                                color: Color(0xFF10B981), size: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom-Left: Quick Edit / Style Handle (Active for Text, Photos & Stickers)
                Positioned(
                  bottom: -12,
                  left: -12,
                  child: Transform.scale(
                    scale: counterScale,
                    child: Transform.rotate(
                      angle: -_localRotation,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onQuickEdit();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.softCard,
                              border: Border.all(
                                  color: const Color(0xFF7C3AED), width: 2),
                            ),
                            child: Icon(
                              elem.type == PageElementType.text
                                  ? Icons.edit_note_rounded
                                  : elem.type == PageElementType.photo
                                      ? Icons.auto_fix_high_rounded
                                      : Icons.auto_awesome_rounded,
                              color: const Color(0xFF7C3AED),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildElementInner(
      PageElementModel elem, double canvasWidth, PageBackgroundConfig bg) {
    switch (elem.type) {
      case PageElementType.text:
        final style =
            _resolveGoogleFontStyle(elem.fontFamily ?? 'Playfair Display');

        TextAlign align;
        switch (elem.textAlign) {
          case 'left':
            align = TextAlign.left;
            break;
          case 'right':
            align = TextAlign.right;
            break;
          case 'center':
          default:
            align = TextAlign.center;
            break;
        }

        final maxW =
            math.max(220.0, canvasWidth - math.max(0.0, elem.x) - 24.0);

        // Resolve text color with contrast matching for background
        Color resolvedColor = Color(elem.textColor ?? 0xFF0F172A);
        if (elem.textColor == null || elem.textColor == 0xFF49383B) {
          if (bg.type == PageBackgroundType.solid) {
            final lum = Color(bg.solidColor).computeLuminance();
            if (lum < 0.45) resolvedColor = Colors.white;
          } else if (bg.gradientColors.isNotEmpty) {
            final firstColor = Color(bg.gradientColors.first);
            if (firstColor.computeLuminance() < 0.45) {
              resolvedColor = Colors.white;
            } else if (firstColor.blue > 200 && firstColor.red < 190) {
              resolvedColor =
                  const Color(0xFF1E3A8A); // Deep Royal Blue for blue cards
            }
          }
        }

        final finalColor =
            resolvedColor.withOpacity(elem.textOpacity.clamp(0.1, 1.0));

        // IntrinsicWidth ensures the container fits the text closely rather than spanning full width
        return Container(
          constraints: BoxConstraints(maxWidth: maxW),
          decoration: elem.textBackgroundColor != null
              ? BoxDecoration(
                  color: Color(elem.textBackgroundColor!),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          padding: elem.textBackgroundColor != null
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : EdgeInsets.zero,
          child: IntrinsicWidth(
            child: Text(
              elem.text ?? '',
              textAlign: align,
              style: style.copyWith(
                fontSize: elem.fontSize ?? 20,
                fontWeight: elem.isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: elem.isItalic ? FontStyle.italic : FontStyle.normal,
                color: finalColor,
                letterSpacing: elem.letterSpacing,
                height: elem.lineHeight ?? 1.45,
              ),
            ),
          ),
        );

      case PageElementType.photo:
        return PhotoShapeWidget(
          imagePath: elem.imagePath,
          shape: elem.photoShape,
          width: elem.width,
          height: elem.height,
          borderColor: Color(elem.borderColor),
          borderWidth: elem.borderWidth,
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
