import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../creation/domain/entities/creation_document.dart';
import '../../../creation/domain/entities/creation_item.dart';
import '../../../creation/domain/entities/page_document.dart';
import '../../../creation/presentation/view_models/creations_view_model.dart';
import '../../../creation/presentation/view_models/page_editor_view_model.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PageDocument? _unsavedDraft;

  final List<String> _tabs = [
    'All',
    'Pages',
    'Saved on Device',
    'Drafts',
    'Synced to Cloud',
    'Books & Cards',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _loadUnsavedDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboardForCardCode();
    });
  }

  String? _lastCheckedClipboardToken;

  Future<void> _checkClipboardForCardCode() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) return;

      String? extractedToken;
      final codeMatch =
          RegExp(r'Card Code:\s*\*?([a-zA-Z0-9_-]{6,32})\*?').firstMatch(text);
      if (codeMatch != null) {
        extractedToken = codeMatch.group(1);
      } else if (text.contains('/p/')) {
        extractedToken =
            text.split('/p/').last.split('?').first.split('\n').first.trim();
      } else if (RegExp(r'^[a-zA-Z0-9_-]{8,16}$').hasMatch(text)) {
        extractedToken = text;
      }

      if (extractedToken != null &&
          extractedToken.isNotEmpty &&
          extractedToken != _lastCheckedClipboardToken &&
          mounted) {
        _lastCheckedClipboardToken = extractedToken;
        final token = extractedToken;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Found Card Code: $token',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'OPEN ✨',
              textColor: Colors.amberAccent,
              onPressed: () {
                context.push('/p/$token');
              },
            ),
            backgroundColor: context.lovioColors.accent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadUnsavedDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftStr = prefs.getString('lovio_page_draft_v1');
      if (draftStr != null && draftStr.isNotEmpty) {
        final map = jsonDecode(draftStr) as Map<String, dynamic>;
        setState(() {
          _unsavedDraft = PageDocument.fromJson(map);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  LinearGradient _getGradientForDoc(BuildContext context, CreationDocument doc) {
    final lovio = context.lovioColors;
    if (doc.type == CreationType.page && doc.content.isNotEmpty) {
      try {
        final pageDoc = PageDocument.fromJson(doc.content);
        if (pageDoc.background.type == PageBackgroundType.gradient &&
            pageDoc.background.gradientColors.isNotEmpty) {
          return LinearGradient(
            colors: pageDoc.background.gradientColors.map((c) => Color(c)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        } else if (pageDoc.background.type == PageBackgroundType.solid) {
          final c = Color(pageDoc.background.solidColor);
          return LinearGradient(colors: [c, c]);
        }
      } catch (_) {}
    }

    switch (doc.coverGradientKey) {
      case 'sunset':
      case 'theme_primary':
      case 'primary':
        return lovio.primaryGradient;
      case 'lavender':
      case 'secondary':
        return lovio.secondaryGradient;
      case 'letter':
        return LinearGradient(
          colors: [lovio.surface, lovio.primary.withOpacity(0.15)],
        );
      default:
        return lovio.primaryGradient;
    }
  }

  void _openCreation(CreationDocument doc) {
    if (doc.type == CreationType.page && doc.content.isNotEmpty) {
      try {
        final pageDoc = PageDocument.fromJson(doc.content);
        ref.read(pageEditorProvider.notifier).loadDocument(pageDoc);

        final lovio = context.lovioColors;
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: lovio.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: AppShadows.floating,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: lovio.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pageDoc.title.isNotEmpty ? pageDoc.title : 'Cherished Page',
                  style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Edit Page Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push(AppRoutes.createPageEditor);
                    },
                    icon: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Edit in Studio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lovio.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Preview Page Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push(AppRoutes.createPagePreview);
                    },
                    icon: Icon(Icons.visibility_rounded,
                        color: lovio.accent, size: 18),
                    label: Text(
                      'View Preview',
                      style: TextStyle(
                        color: lovio.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: lovio.accent.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      } catch (_) {}
    }
    // Generic viewer / preview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening "${doc.title}"...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resumeDraft(PageDocument draft) {
    ref.read(pageEditorProvider.notifier).loadDocument(draft);
    context.push(AppRoutes.createPageEditor);
  }

  List<CreationDocument> _filterItems(List<CreationDocument> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((d) {
      final titleMatch = d.title.toLowerCase().contains(_searchQuery);
      final typeMatch = d.type.name.toLowerCase().contains(_searchQuery);
      return titleMatch || typeMatch;
    }).toList();
  }

  void _showOpenCardByCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    final lovio = context.lovioColors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: lovio.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.mail_lock_rounded, color: lovio.accent, size: 24),
            const SizedBox(width: 10),
            Text('Open Shared Card',
                style: AppTextStyles.titleMedium(color: lovio.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the Card Code or paste the link received from your loved one:',
              style: AppTextStyles.bodySmall(color: lovio.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: AppTextStyles.bodyMedium(color: lovio.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. 5642b9f35c or link',
                prefixIcon:
                    Icon(Icons.link_rounded, color: lovio.accent, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: lovio.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final raw = controller.text.trim();
              if (raw.isEmpty) return;

              final token =
                  DeepLinkService.instance.extractToken(raw) ?? raw;

              Navigator.of(ctx).pop();
              context.push('/p/$token');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lovio.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Open Card ✨'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final creationsState = ref.watch(creationsProvider);
    final allItems = _filterItems(creationsState.items);

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Library',
          style: AppTextStyles.headlineMedium(color: lovio.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_read_rounded, color: lovio.accent),
            tooltip: 'Open Shared Card by Code',
            onPressed: () => _showOpenCardByCodeDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: lovio.textPrimary),
            tooltip: 'Refresh Library',
            onPressed: () {
              ref.read(creationsProvider.notifier).loadCreations();
              _loadUnsavedDraft();
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: lovio.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: lovio.border),
                    boxShadow: AppShadows.softCard,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: lovio.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyles.bodyMedium(
                              color: lovio.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search saved creations & pages...',
                            hintStyle: AppTextStyles.bodySmall(
                              color: lovio.textSecondary.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: Icon(Icons.clear_rounded,
                              color: lovio.textSecondary, size: 18),
                        )
                      else
                        InkWell(
                          onTap: () => _showOpenCardByCodeDialog(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: lovio.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.key_rounded,
                                    size: 13, color: lovio.accent),
                                const SizedBox(width: 4),
                                Text(
                                  'Card Code',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: lovio.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Category Tabs
              Container(
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  physics: const BouncingScrollPhysics(),
                  labelColor: Colors.white,
                  unselectedLabelColor: lovio.textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: lovio.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: lovio.glow,
                  ),
                  labelStyle: AppTextStyles.labelMedium(),
                  unselectedLabelStyle: AppTextStyles.bodySmall(),
                  tabAlignment: TabAlignment.start,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: creationsState.isLoading && creationsState.items.isEmpty
          ? const Center(
              child: LovioLoadingIndicator(
                message: 'Loading your creative collection...',
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. All
                _buildCreationsGrid(allItems, showDraftCard: true),

                // 2. Pages
                _buildCreationsGrid(
                  allItems
                      .where((d) => d.type == CreationType.page)
                      .toList(),
                  showDraftCard: true,
                ),

                // 3. Saved on Device
                _buildCreationsGrid(
                  allItems
                      .where((d) => d.syncStatus == SyncStatus.localOnly)
                      .toList(),
                ),

                // 4. Drafts (Unsaved Drafts)
                _buildDraftsView(),

                // 5. Synced to Cloud
                _buildCreationsGrid(
                  allItems
                      .where((d) => d.syncStatus == SyncStatus.synced)
                      .toList(),
                ),

                // 6. Books & Cards
                _buildCreationsGrid(
                  allItems
                      .where((d) =>
                          d.type == CreationType.shortBook ||
                          d.type == CreationType.card ||
                          d.type == CreationType.loveLetter)
                      .toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildDraftsView() {
    final lovio = context.lovioColors;

    if (_unsavedDraft == null) {
      return LovioEmptyState(
        icon: Icons.edit_note_rounded,
        title: 'No Active Drafts',
        subtitle:
            'When you begin creating a page, any unsaved work is automatically preserved here as a draft.',
        actionLabel: 'Start New Page ✨',
        onActionPressed: () => context.push(AppRoutes.createPageWrite),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: lovio.accent.withOpacity(0.4), width: 1.5),
            boxShadow: AppShadows.softCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lovio.accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_note_rounded,
                        color: lovio.accent, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _unsavedDraft!.title.isNotEmpty
                              ? _unsavedDraft!.title
                              : 'Unsaved Page Draft',
                          style: AppTextStyles.titleMedium(
                              color: lovio.textPrimary),
                        ),
                        Text(
                          'Autosaved on device • Resume anytime',
                          style: AppTextStyles.labelSmall(
                              color: lovio.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Draft',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (_unsavedDraft!.writtenMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _unsavedDraft!.writtenMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _resumeDraft(_unsavedDraft!),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Resume Editing ✨'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lovio.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red),
                    tooltip: 'Discard Draft',
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('lovio_page_draft_v1');
                      setState(() => _unsavedDraft = null);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreationsGrid(List<CreationDocument> items,
      {bool showDraftCard = false}) {
    if (items.isEmpty && (!showDraftCard || _unsavedDraft == null)) {
      return LovioEmptyState(
        icon: Icons.auto_stories_rounded,
        title: 'No Creations Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No creations match "$_searchQuery". Try searching a different title.'
            : 'Start a new page, book, card, or letter. It will be saved securely on your device first.',
        actionLabel: 'Create Something Special ✨',
        onActionPressed: () => context.push(AppRoutes.create),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Optional Draft Banner
        if (showDraftCard && _unsavedDraft != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.lovioColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: context.lovioColors.accent.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded,
                    color: context.lovioColors.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Draft in progress: "${_unsavedDraft!.title}"',
                    style: AppTextStyles.labelMedium(
                        color: context.lovioColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => _resumeDraft(_unsavedDraft!),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Resume',
                    style: AppTextStyles.labelLarge(
                        color: context.lovioColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Grid of creations
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final doc = items[index];
            return _CreationDocumentCard(
              doc: doc,
              gradient: _getGradientForDoc(context, doc),
              onTap: () => _openCreation(doc),
              onUploadPressed: () async {
                await ref
                    .read(creationsProvider.notifier)
                    .uploadToCloud(doc.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Synced "${doc.title}" to Firebase Cloud! ☁️'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onDeletePressed: () {
                ref.read(creationsProvider.notifier).deleteCreation(doc.id);
              },
            );
          },
        ),
      ],
    );
  }
}

class _CreationDocumentCard extends StatelessWidget {
  final CreationDocument doc;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final VoidCallback onUploadPressed;
  final VoidCallback onDeletePressed;

  const _CreationDocumentCard({
    required this.doc,
    required this.gradient,
    required this.onTap,
    required this.onUploadPressed,
    required this.onDeletePressed,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }

  String _getTypeLabel(CreationType type) {
    switch (type) {
      case CreationType.page:
        return 'Page ✨';
      case CreationType.shortBook:
        return 'Short Book 📖';
      case CreationType.card:
        return 'Card 💌';
      case CreationType.loveLetter:
        return 'Letter 📜';
    }
  }

  Color _resolveContrastColor(LinearGradient grad) {
    if (grad.colors.isEmpty) return const Color(0xFF2D1B22);
    final first = grad.colors.first;
    // Blue / indigo / deep violet cards -> sharp pure white
    if (first.blue > 190 && first.red < 160) {
      return Colors.white;
    }
    double totalLum = 0.0;
    for (final c in grad.colors) {
      totalLum += c.computeLuminance();
    }
    final avgLum = totalLum / grad.colors.length;
    return avgLum < 0.48 ? Colors.white : const Color(0xFF2D1B22);
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final titleColor = _resolveContrastColor(gradient);
    final isWhite = titleColor == Colors.white;

    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lovio.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.softCard,
          border: Border.all(color: lovio.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover representation
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          doc.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSmall(
                            color: titleColor,
                          ).copyWith(
                            shadows: isWhite
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sync status indicator pill
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _SyncStatusBadge(
                      status: doc.syncStatus,
                      onUploadTap: onUploadPressed,
                    ),
                  ),

                  // Context Menu
                  Positioned(
                    top: 14,
                    right: 14,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.more_vert_rounded,
                            size: 16, color: Color(0xFF2D1B22)),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onSelected: (value) {
                        switch (value) {
                          case 'upload':
                            onUploadPressed();
                            break;
                          case 'delete':
                            onDeletePressed();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (doc.syncStatus != SyncStatus.synced)
                          const PopupMenuItem(
                            value: 'upload',
                            child: Row(
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 18, color: AppColors.roseAccent),
                                SizedBox(width: 8),
                                Text('Upload to Cloud'),
                              ],
                            ),
                          ),
                        if (doc.syncStatus == SyncStatus.synced)
                          const PopupMenuItem(
                            value: 'upload',
                            child: Row(
                              children: [
                                Icon(Icons.cloud_sync_rounded,
                                    size: 18, color: AppColors.roseAccent),
                                SizedBox(width: 8),
                                Text('Re-sync to Cloud'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Info Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge(color: lovio.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTypeLabel(doc.type),
                        style: AppTextStyles.bodySmall(
                          color: lovio.accent,
                        ),
                      ),
                      Text(
                        _formatDate(doc.updatedAt),
                        style: AppTextStyles.bodySmall(
                          color: lovio.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback onUploadTap;

  const _SyncStatusBadge({
    required this.status,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSynced = status == SyncStatus.synced;

    return GestureDetector(
      onTap: isSynced ? null : onUploadTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSynced ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
              size: 13,
              color: isSynced ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
            ),
            const SizedBox(width: 4),
            Text(
              isSynced ? 'Synced' : 'On Device',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSynced
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE57373),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
