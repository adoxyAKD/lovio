import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/page_document.dart';
import '../screens/shared_card_viewer_screen.dart';
import '../view_models/page_editor_view_model.dart';

class PageShareSheet extends ConsumerStatefulWidget {
  const PageShareSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PageShareSheet(),
    );
  }

  @override
  ConsumerState<PageShareSheet> createState() => _PageShareSheetState();
}

class _PageShareSheetState extends ConsumerState<PageShareSheet> {
  static const _channel = MethodChannel('app.lovio/native_share');
  bool _isCopied = false;
  bool _isFeedPosting = false;

  @override
  void initState() {
    super.initState();
    // Pre-sync page to cloud so recipients can immediately open it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pageEditorProvider.notifier).uploadForSharing();
    });
  }

  void _copyLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Link copied to clipboard! 📋✨'),
          ],
        ),
        backgroundColor: context.lovioColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _shareViaWhatsApp(PageDocument doc) async {
    // Ensure uploaded to cloud
    await ref.read(pageEditorProvider.notifier).uploadForSharing();

    final token = doc.shareToken;
    final title = doc.title.isNotEmpty ? doc.title : 'A Romantic Card for You';

    String preview = doc.writtenMessage.trim();
    if (preview.isEmpty) {
      for (final elem in doc.elements) {
        if (elem.type == PageElementType.text &&
            (elem.text?.trim().isNotEmpty ?? false)) {
          preview = elem.text!.trim();
          break;
        }
      }
    }
    if (preview.length > 120) {
      preview = '${preview.substring(0, 120)}...';
    }

    final webUrl = 'https://lovio-e5990.web.app/p/$token';
    final appDeepLink = 'lovio://p/$token';

    final message = '''
💌 *$title* ✨
${preview.isNotEmpty ? '\n"$preview"\n' : ''}
💖 You received a special card on Lovio!

👉 View Online (No app required):
$webUrl

📱 Or Open directly in Lovio App:
$appDeepLink
(Or enter Card Code: *$token* in Library ➔ Card Code 🔑)''';

    Clipboard.setData(ClipboardData(text: message));

    try {
      await _channel.invokeMethod('shareWhatsApp', {
        'text': message,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Sharing to WhatsApp... Message copied to clipboard! 💬'),
            backgroundColor: const Color(0xFF25D366),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  Future<void> _shareNative(PageDocument doc) async {
    await ref.read(pageEditorProvider.notifier).uploadForSharing();

    final token = doc.shareToken;
    final title = doc.title.isNotEmpty ? doc.title : 'A Special Card for You';

    final webUrl = 'https://lovio-e5990.web.app/p/$token';
    final appDeepLink = 'lovio://p/$token';

    final message = '''
💌 *$title* ✨
💖 You received a special card on Lovio!

👉 View Online:
$webUrl

📱 Or Open in Lovio App:
$appDeepLink
(Or enter Card Code: *$token* in Library ➔ Card Code 🔑)''';

    Clipboard.setData(ClipboardData(text: message));

    try {
      await _channel.invokeMethod('shareText', {
        'text': message,
        'title': 'Share Lovio Card',
      });
    } catch (_) {
      _copyLink(message);
    }
  }

  Future<void> _postToFeed() async {
    setState(() => _isFeedPosting = true);
    final success =
        await ref.read(pageEditorProvider.notifier).postToPublicFeed(ref);
    if (mounted) {
      setState(() => _isFeedPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Shared to Lovio Explore Feed! 🌟'
              : 'Failed to share to feed.'),
          backgroundColor: context.lovioColors.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  void _openWebViewerDemo() {
    final doc = ref.read(pageEditorProvider).document;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SharedCardViewerScreen(token: doc.shareToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final state = ref.watch(pageEditorProvider);
    final doc = state.document;
    final shareUrl = 'https://lovio-e5990.web.app/p/${doc.shareToken}';

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: lovio.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: lovio.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share & Publish Page',
                      style: AppTextStyles.headlineSmall(
                          color: lovio.textPrimary),
                    ),
                    Text(
                      'Anyone with the link can view with animations without logging in ✨',
                      style:
                          AppTextStyles.bodySmall(color: lovio.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Generated Link Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: lovio.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: lovio.border),
            ),
            child: Row(
              children: [
                Icon(Icons.link_rounded, color: lovio.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    shareUrl,
                    style: AppTextStyles.labelMedium(color: lovio.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedPressable(
                  onPressed: () => _copyLink(shareUrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isCopied
                          ? const Color(0xFF4CAF50)
                          : lovio.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCopied ? Icons.check : Icons.copy_rounded,
                          size: 14,
                          color: _isCopied ? Colors.white : lovio.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isCopied ? 'Copied' : 'Copy',
                          style: AppTextStyles.labelSmall(
                            color: _isCopied ? Colors.white : lovio.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Card Code Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: lovio.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lovio.border),
            ),
            child: Row(
              children: [
                Icon(Icons.key_rounded, color: lovio.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Card Code:',
                  style: AppTextStyles.labelSmall(color: lovio.textSecondary),
                ),
                const SizedBox(width: 6),
                Text(
                  doc.shareToken,
                  style: GoogleFonts.firaCode(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: lovio.accent,
                  ),
                ),
                const Spacer(),
                Text(
                  'Opens in Lovio app',
                  style: TextStyle(
                    fontSize: 11,
                    color: lovio.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Surprise Opening Style Selector (Visual, Playful & Interactive Card Carousel)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lovio.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lovio.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: lovio.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Surprise Opening Style',
                      style: AppTextStyles.labelMedium(color: lovio.textPrimary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: lovio.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${doc.openingStyle.emoji} ${doc.openingStyle.label}',
                        style: AppTextStyles.labelSmall(color: lovio.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: OpeningRevealStyle.values.map((style) {
                      final isSelected = style == doc.openingStyle;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: AnimatedPressable(
                          onPressed: () {
                            ref
                                .read(pageEditorProvider.notifier)
                                .setOpeningStyle(style);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
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
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            lovio.accent.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : AppShadows.softCard,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(style.emoji,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      style.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? lovio.accent
                                            : lovio.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isSelected ? 'Selected' : 'Interactive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? lovio.accent.withOpacity(0.8)
                                            : lovio.textSecondary
                                                .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Link Active Switch (Revoke Link Control)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: lovio.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lovio.border),
            ),
            child: Row(
              children: [
                Icon(
                  doc.isShareable
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  color: doc.isShareable
                      ? const Color(0xFF10B981)
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doc.isShareable
                        ? 'Link is Active (Publicly viewable)'
                        : 'Link Revoked (Private only to you)',
                    style:
                        AppTextStyles.labelMedium(color: lovio.textPrimary),
                  ),
                ),
                Switch.adaptive(
                  value: doc.isShareable,
                  activeColor: lovio.accent,
                  onChanged: (val) {
                    ref
                        .read(pageEditorProvider.notifier)
                        .toggleShareable(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Modern Sharing Cards Row
          Row(
            children: [
              Expanded(
                child: _ShareOptionTile(
                  icon: Icons.chat_bubble_rounded,
                  iconGradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  label: 'WhatsApp',
                  subtitle: 'Direct Chat',
                  badge: 'Instant',
                  onTap: () => _shareViaWhatsApp(doc),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShareOptionTile(
                  icon: Icons.share_rounded,
                  iconGradient: lovio.primaryGradient,
                  label: 'Share',
                  subtitle: 'Any App',
                  badge: 'All Apps',
                  onTap: () => _shareNative(doc),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShareOptionTile(
                  icon: Icons.travel_explore_rounded,
                  iconGradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  label: 'Explore',
                  subtitle: 'Public Feed',
                  badge: 'Community',
                  isLoading: _isFeedPosting,
                  onTap: _postToFeed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Simulated Web Viewer Demo Button
          SizedBox(
            width: double.infinity,
            child: AnimatedPressable(
              onPressed: _openWebViewerDemo,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: lovio.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: lovio.accent.withOpacity(0.5), width: 1.5),
                  boxShadow: AppShadows.softCard,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_browser_rounded,
                        color: lovio.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Preview Recipient Web Viewer 🌐',
                      style: AppTextStyles.labelLarge(color: lovio.accent),
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
}

class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final LinearGradient iconGradient;
  final String label;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;
  final bool isLoading;

  const _ShareOptionTile({
    required this.icon,
    required this.iconGradient,
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: lovio.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: lovio.border),
          boxShadow: AppShadows.softCard,
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                height: 36,
                width: 36,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: lovio.accent,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient.colors.first.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium(color: lovio.textPrimary)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: lovio.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

