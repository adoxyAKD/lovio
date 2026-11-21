import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../constants/page_editor_assets.dart';
import '../view_models/page_editor_view_model.dart';

class PageContentWriteScreen extends ConsumerStatefulWidget {
  const PageContentWriteScreen({super.key});

  @override
  ConsumerState<PageContentWriteScreen> createState() =>
      _PageContentWriteScreenState();
}

class _PageContentWriteScreenState
    extends ConsumerState<PageContentWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _hasDraft = false;

  List<Map<String, String>> get _prompts =>
      PageEditorAssets.inspirationPrompts;

  @override
  void initState() {
    super.initState();
    _checkDraft();
  }

  Future<void> _checkDraft() async {
    final notifier = ref.read(pageEditorProvider.notifier);
    final hasDraft = await notifier.loadDraftIfExists();
    if (hasDraft && mounted) {
      setState(() {
        _hasDraft = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    ref.read(pageEditorProvider.notifier).startNewPage(
          title: title.isNotEmpty ? title : 'Cherished Memory',
          message: message,
        );

    context.push(AppRoutes.createPageEditor);
  }

  void _resumeDraft() {
    context.push(AppRoutes.createPageEditor);
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: lovio.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Write Content',
          style: AppTextStyles.titleMedium(color: lovio.textPrimary),
        ),
        actions: [
          // Quick Jump Directly to Canvas Studio
          TextButton.icon(
            onPressed: () {
              ref.read(pageEditorProvider.notifier).startNewPage(
                    title: _titleController.text.trim().isNotEmpty
                        ? _titleController.text.trim()
                        : 'Cherished Memory',
                    message: _messageController.text.trim(),
                  );
              context.push(AppRoutes.createPageEditor);
            },
            icon: Icon(Icons.brush_rounded, size: 16, color: lovio.accent),
            label: Text(
              'Canvas',
              style: AppTextStyles.labelMedium(color: lovio.accent),
            ),
          ),

          // Single smartly designed prominent Next button at the top
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: AnimatedPressable(
              onPressed: _onNext,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: lovio.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: lovio.glow,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resume Draft Alert
              if (_hasDraft)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: lovio.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: lovio.accent.withOpacity(0.25), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note_rounded,
                          color: lovio.accent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Unsaved draft found from earlier session',
                          style: AppTextStyles.labelMedium(
                              color: lovio.textPrimary),
                        ),
                      ),
                      TextButton(
                        onPressed: _resumeDraft,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Resume',
                          style: AppTextStyles.labelLarge(
                              color: lovio.accent),
                        ),
                      ),
                    ],
                  ),
                ),

              // Title Input Card (Fixed spacing & no overlapping)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: lovio.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppShadows.softCard,
                  border: Border.all(color: lovio.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bookmark_rounded,
                            color: lovio.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Page Title',
                          style: AppTextStyles.labelMedium(
                              color: lovio.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: lovio.textPrimary,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        hintText: PageEditorAssets.defaultWriteTitleHint,
                        hintStyle: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: lovio.textSecondary.withOpacity(0.45),
                          height: 1.35,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Romantic Inspiration Section
              Text(
                'Romantic Inspiration',
                style: AppTextStyles.labelLarge(color: lovio.textSecondary),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _prompts.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(p['label']!),
                        labelStyle: AppTextStyles.labelSmall(
                          color: lovio.textPrimary,
                        ),
                        backgroundColor: lovio.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: lovio.border),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_titleController.text.trim().isEmpty) {
                              _titleController.text = p['title']!;
                            }
                            _messageController.text = p['body']!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Message Writing Canvas (Dynamic Card Height adapting intelligently to content & viewport)
              Builder(
                builder: (context) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final textLength = _messageController.text.length;
                  // Standard card baseline proportion (~45% of viewport height or at least 380)
                  final baseCardHeight = math.min(520.0, math.max(380.0, screenHeight * 0.44));
                  final estimatedLines = math.max(6, (textLength / 28).ceil());
                  final dynamicContentHeight = 130.0 + (estimatedLines * 30.0);
                  final computedCardHeight = math.max(baseCardHeight, dynamicContentHeight);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    constraints: BoxConstraints(minHeight: computedCardHeight),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lovio.surface,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: AppShadows.softCard,
                      border: Border.all(color: lovio.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Editor Card Header with Live Character Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note_rounded,
                                color: lovio.accent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Your Heartfelt Message',
                              style: AppTextStyles.labelMedium(
                                  color: lovio.textSecondary),
                            ),
                          ],
                        ),
                        ListenableBuilder(
                          listenable: _messageController,
                          builder: (context, _) {
                            final length = _messageController.text.length;
                            final isNearLimit = length > 900;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isNearLimit
                                    ? Colors.orange.withOpacity(0.12)
                                    : lovio.accent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$length / 1000 characters',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isNearLimit
                                      ? Colors.orange
                                      : lovio.accent,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Multiline Text Area supporting up to 1,000 characters
                    TextField(
                      controller: _messageController,
                      maxLines: null,
                      maxLength: 1000,
                      buildCounter: (_,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null, // Clean live counter shown above
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1000),
                      ],
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        height: 1.65,
                        color: lovio.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: PageEditorAssets.defaultWriteMessageHint,
                        hintStyle: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          height: 1.65,
                          color: lovio.textSecondary.withOpacity(0.48),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
            ],
          ),
        ),
      ),
    );
  }
}
