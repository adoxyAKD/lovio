import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/data_sources/remote/firebase_creations_remote_data_source.dart';
import '../../domain/entities/creation_document.dart';
import '../../domain/entities/creation_item.dart';
import '../../domain/entities/page_document.dart';
import '../view_models/creations_view_model.dart';
import '../view_models/page_editor_view_model.dart';
import '../widgets/animated_sticker_widget.dart';
import '../widgets/page_animated_background.dart';
import '../widgets/photo_shape_widget.dart';
import '../widgets/surprise_opening_view.dart';

class SharedCardViewerScreen extends ConsumerStatefulWidget {
  final String token;

  const SharedCardViewerScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<SharedCardViewerScreen> createState() =>
      _SharedCardViewerScreenState();
}

class _SharedCardViewerScreenState extends ConsumerState<SharedCardViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  PageDocument? _pageDocument;
  bool _isSavedToLibrary = false;
  bool _isSurpriseRevealed = false;

  late final AnimationController _revealController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutCubic,
      ),
    );
    _revealController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {});
      }
    });

    _fetchSharedCard();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _fetchSharedCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = widget.token.trim();

      // 1. Check if token matches active editor document
      final activeDoc = ref.read(pageEditorProvider).document;
      if (activeDoc.shareToken == token || activeDoc.id == token) {
        if (mounted) {
          setState(() {
            _pageDocument = activeDoc;
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Check local creations repository
      final creationsState = ref.read(creationsProvider);
      for (final item in creationsState.items) {
        if (item.content.isNotEmpty) {
          try {
            final doc = PageDocument.fromJson(item.content);
            if (doc.shareToken == token || doc.id == token) {
              if (mounted) {
                setState(() {
                  _pageDocument = doc;
                  _isLoading = false;
                });
              }
              return;
            }
          } catch (_) {}
        }
      }

      // 3. Fetch from Firebase Realtime Database
      try {
        final rtdbUrl = Uri.parse(
            '${FirebaseCreationsRemoteDataSource.rtdbBaseUrl}/shared_pages/$token.json');
        final response =
            await http.get(rtdbUrl).timeout(const Duration(seconds: 8));
        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.body != 'null' &&
            response.body.isNotEmpty) {
          final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
          final doc = PageDocument.fromJson(jsonMap);
          if (mounted) {
            setState(() {
              _pageDocument = doc;
              _isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        debugPrint('RTDB fetch shared page notice: $e');
      }

      // 4. Fetch from Cloud Firestore
      try {
        final firestore = FirebaseFirestore.instance;
        final snapshot = await firestore
            .collection('shared_pages')
            .doc(token)
            .get()
            .timeout(const Duration(seconds: 8));

        if (snapshot.exists && snapshot.data() != null) {
          final doc = PageDocument.fromJson(snapshot.data()!);
          if (mounted) {
            setState(() {
              _pageDocument = doc;
              _isLoading = false;
            });
          }
          return;
        }

        final querySnap = await firestore
            .collection('creations')
            .where('shareToken', isEqualTo: token)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 8));

        if (querySnap.docs.isNotEmpty) {
          final data = querySnap.docs.first.data();
          final contentMap = data['content'] as Map<String, dynamic>? ?? data;
          final doc = PageDocument.fromJson(contentMap);
          if (mounted) {
            setState(() {
              _pageDocument = doc;
              _isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        debugPrint('Firestore fetch shared page notice: $e');
      }

      // Not found
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'This card could not be found or may have expired.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load card: $e';
        });
      }
    }
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _saveToMyLibrary() async {
    if (_pageDocument == null) return;
    final doc = _pageDocument!;

    try {
      final creationDoc = CreationDocument(
        id: doc.id,
        title: doc.title.isNotEmpty ? doc.title : 'Received Card',
        type: CreationType.page,
        content: doc.toJson(),
        createdAt: doc.createdAt,
        updatedAt: DateTime.now(),
        pageCount: 1,
        coverGradientKey: 'primary',
        syncStatus: SyncStatus.localOnly,
      );

      final repo = ref.read(creationsRepositoryProvider);
      await repo.saveCreationLocally(creationDoc);
      await ref.read(creationsProvider.notifier).loadCreations();

      if (mounted) {
        setState(() => _isSavedToLibrary = true);
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.bookmark_added_rounded,
                    color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Saved to your Lovio Library! 📚✨'),
              ],
            ),
            backgroundColor: context.lovioColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCardActionsSheet(BuildContext context, PageDocument doc) {
    final lovio = context.lovioColors;
    final shareUrl = 'https://lovio-e5990.web.app/p/${doc.shareToken}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 14, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: lovio.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Card Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: lovio.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title.isNotEmpty ? doc.title : 'Shared Card',
                          style: AppTextStyles.titleMedium(
                              color: lovio.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Created with Love on Lovio ✨',
                          style: AppTextStyles.labelSmall(color: lovio.accent),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: lovio.textSecondary,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // 1. Copy Link
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lovio.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.link_rounded,
                      color: lovio.accent, size: 20),
                ),
                title: const Text('Copy Card Link',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(shareUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12, color: lovio.textSecondary)),
                trailing: const Icon(Icons.copy_rounded, size: 18),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Clipboard.setData(ClipboardData(text: shareUrl));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('Card link copied to clipboard! 📋✨'),
                      backgroundColor: lovio.accent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // 2. Copy Code
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.key_rounded,
                      color: Color(0xFF7C3AED), size: 20),
                ),
                title: const Text('Card Code',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(doc.shareToken,
                    style: GoogleFonts.firaCode(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C3AED))),
                trailing: const Icon(Icons.copy_rounded, size: 18),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Clipboard.setData(ClipboardData(text: doc.shareToken));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Card Code "${doc.shareToken}" copied! 🔑✨'),
                      backgroundColor: const Color(0xFF7C3AED),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // 3. Save to Library
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isSavedToLibrary
                        ? Icons.bookmark_added_rounded
                        : Icons.bookmark_add_rounded,
                    color: const Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                title: Text(
                    _isSavedToLibrary
                        ? 'Saved in Library'
                        : 'Save to My Library',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                    _isSavedToLibrary
                        ? 'Available offline in Library'
                        : 'Keep this card forever in your Lovio library',
                    style:
                        TextStyle(fontSize: 12, color: lovio.textSecondary)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _saveToMyLibrary();
                },
              ),

              // 4. Create Your Own Card
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.orange, size: 20),
                ),
                title: const Text('Create a Card Like This',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Express your heart with animated cards',
                    style:
                        TextStyle(fontSize: 12, color: lovio.textSecondary)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(AppRoutes.createPageWrite);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
      if (firstColor.blue > 200 && firstColor.red < 190) {
        return const Color(0xFF1E3A8A);
      }
      return const Color(0xFF0F172A);
    }
    return const Color(0xFF0F172A);
  }

  TextStyle _resolveFontStyle(
      PageElementModel elem, PageBackgroundConfig bg) {
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
      case 'Inter':
        baseStyle = GoogleFonts.inter();
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

  Widget _buildFrostedCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required LovioColors lovio,
    bool showGlow = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.28),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.5,
            ),
            boxShadow: showGlow ? lovio.glow : AppShadows.softCard,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: Center(
                child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: lovio.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: lovio.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: lovio.glow,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 24),
              Text(
                'Opening Cherished Creation...',
                style: AppTextStyles.titleMedium(color: lovio.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Connecting to Lovio Cloud ✨',
                style: AppTextStyles.bodySmall(color: lovio.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _pageDocument == null) {
      return Scaffold(
        backgroundColor: lovio.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: lovio.textPrimary,
            onPressed: _onBack,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sentiment_dissatisfied_rounded,
                    size: 64, color: lovio.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Card Not Available',
                  style:
                      AppTextStyles.headlineSmall(color: lovio.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ??
                      'This card could not be found or the link has expired.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(
                      color: lovio.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Lovio Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lovio.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final doc = _pageDocument!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Dedicated Full-Screen Edge-to-Edge Animated Card Canvas
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (_revealController.isAnimating) {
                    _revealController.value = 1.0;
                  }
                },
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final viewportHeight = constraints.maxHeight;
                        final viewportWidth = constraints.maxWidth;
                        final topHeaderOffset =
                            MediaQuery.of(context).padding.top + 76.0;

                        double calculatedHeight = viewportHeight;
                        for (final elem in doc.elements) {
                          double elemBottom = elem.y + topHeaderOffset + 120;
                          if (elem.type == PageElementType.text) {
                            final textLen = (elem.text?.length ?? 0);
                            final linesEstimate =
                                math.max(1, (textLen / 22).ceil());
                            final fontSize = elem.fontSize ?? 18;
                            final textHeight =
                                linesEstimate * (fontSize * 1.5) * elem.scale;
                            elemBottom =
                                elem.y + topHeaderOffset + textHeight + 90;
                          } else if (elem.type == PageElementType.photo) {
                            elemBottom = elem.y +
                                topHeaderOffset +
                                (elem.height * elem.scale) +
                                60;
                          } else if (elem.type == PageElementType.sticker) {
                            elemBottom = elem.y +
                                topHeaderOffset +
                                (70 * elem.scale) +
                                40;
                          }
                          if (elemBottom > calculatedHeight) {
                            calculatedHeight = elemBottom;
                          }
                        }
                        final totalCanvasHeight =
                            math.max(viewportHeight, calculatedHeight + 80);

                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 2.5,
                          clipBehavior: Clip.none,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: SizedBox(
                              height: totalCanvasHeight,
                              width: viewportWidth,
                              child: PageAnimatedBackground(
                                config: doc.background,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ...doc.elements.map((elem) {
                                      return Positioned(
                                        left: elem.x,
                                        top: elem.y + topHeaderOffset,
                                        child: Transform.rotate(
                                          angle: elem.rotation,
                                          child: Transform.scale(
                                            scale: elem.scale,
                                            child: _buildElementWidget(
                                                elem,
                                                viewportWidth,
                                                doc.background),
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
            ),

            // 2. Modern Frosted Glass Top Navigation Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.of(context).padding.top + 6,
                        16,
                        10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.32),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.12),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildFrostedCircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Go to Home',
                            onTap: _onBack,
                            lovio: lovio,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  doc.title.isNotEmpty
                                      ? doc.title
                                      : 'A Romantic Card',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF4B8B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Interactive Card • Lovio ✨',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildFrostedCircleButton(
                            icon: Icons.auto_awesome_rounded,
                            tooltip: 'Card Actions & Info',
                            onTap: () => _showCardActionsSheet(context, doc),
                            lovio: lovio,
                            showGlow: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Initial Surprise Opening Experience Overlay (Smooth Continuous Transition)
            if (!_isSurpriseRevealed || _revealController.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _isSurpriseRevealed,
                  child: AnimatedOpacity(
                    opacity: _isSurpriseRevealed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: SurpriseOpeningView(
                      document: doc,
                      onRevealed: () {
                        setState(() => _isSurpriseRevealed = true);
                        _revealController.forward(from: 0.0);
                      },
                      onBack: _onBack,
                    ),
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

        return Container(
          constraints: BoxConstraints(maxWidth: maxW),
          child: IntrinsicWidth(
            child: Text(
              elem.text ?? '',
              style: _resolveFontStyle(elem, bg),
              textAlign: align,
            ),
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
