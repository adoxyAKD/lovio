import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/avatar_helper.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../authentication/presentation/view_models/auth_view_model.dart';
import '../../../navigation/presentation/widgets/dashboard_top_actions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Feed posts state
  late List<_FeedPostData> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      _FeedPostData(
        id: 'post_1',
        authorName: 'Noah & Ava',
        authorHandle: 'noah_and_ava',
        authorInitial: 'N',
        authorGradient: null,
        location: 'Santorini, Greece • 2h ago',
        title: '500 Days of Adventure & Laughter 💕',
        caption:
            'Half a thousand days together and you still make my heart skip a beat every single morning ✨ Happy 500th day my love! #500Days #LovioStory #Anniversary',
        likeCount: 1284,
        commentCount: 38,
        isLiked: false,
        isSaved: false,
        postType: _PostType.photoCard,
        gradient: null,
        quoteText:
            '"In all the world, there is no heart for me like yours. In all the world, there is no love for you like mine." — Maya Angelou',
      ),
      _FeedPostData(
        id: 'post_2',
        authorName: 'Liam & Emma',
        authorHandle: 'liam_emma_adventures',
        authorInitial: 'L',
        authorGradient: null,
        location: 'Paris, France • 4h ago',
        title: 'A Handwritten Morning Surprise ☕💌',
        caption:
            'Surprised her with a digital letter before breakfast today ☕💌 She cried happy tears! Love this app so much. #LoveLetters #AnniversaryLove',
        likeCount: 3892,
        commentCount: 94,
        isLiked: true,
        isSaved: true,
        postType: _PostType.loveLetter,
        gradient: const LinearGradient(
          colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        ),
        quoteText:
            'Dearest Emma,\nIf I had a flower for every time I thought of you, I could walk through my garden forever.\nHappy 2nd Anniversary, my darling.',
      ),
      _FeedPostData(
        id: 'post_3',
        authorName: 'Lucas & Mia',
        authorHandle: 'lucas_and_mia',
        authorInitial: 'M',
        authorGradient: null,
        location: 'California Highway 1 • 6h ago',
        title: 'Our Pacific Coast Storybook 📖🌊',
        caption:
            'Exported and shared our memory book today! 📖 Every sunset and polaroid from our coastal roadtrip in one place. #RoadtripMemories #ShortBook',
        likeCount: 2140,
        commentCount: 52,
        isLiked: false,
        isSaved: false,
        postType: _PostType.storybook,
        gradient: null,
        quoteText:
            '18 Chapters • 42 Memories • Endless Sunsets along the Pacific Coast Highway 🚗✨',
      ),
      _FeedPostData(
        id: 'post_4',
        authorName: 'Oliver & Rose',
        authorHandle: 'oliver_and_rose',
        authorInitial: 'O',
        authorGradient: AppColors.emeraldRomanceGradient,
        location: 'Central Park, NY • 1d ago',
        title: 'From First Coffee to Saying YES 💍',
        caption:
            'One year ago today he asked on this bridge, and I said forever! ✨💍 Time flies when you are in love. #ProposalAnniversary #CoupleGoals',
        likeCount: 4912,
        commentCount: 120,
        isLiked: false,
        isSaved: false,
        postType: _PostType.photoCard,
        gradient: AppColors.emeraldRomanceGradient,
        quoteText:
            '"I choose you. And I\'ll choose you over and over and over. Without pause, without a doubt, in a heartbeat." 💕',
      ),
    ];
  }

  void _toggleLike(int index) {
    setState(() {
      final post = _posts[index];
      if (post.isLiked) {
        post.isLiked = false;
        post.likeCount--;
      } else {
        post.isLiked = true;
        post.likeCount++;
      }
    });
  }

  void _toggleSave(int index) {
    setState(() {
      _posts[index].isSaved = !_posts[index].isSaved;
    });
    final isSaved = _posts[index].isSaved;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved
              ? 'Saved to your Private Collection ✨'
              : 'Removed from Saved Collection',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sharePost(_FeedPostData post) {
    const channel = MethodChannel('app.lovio/native_share');
    final text =
        '💌 "${post.title}"\n${post.quoteText}\n\nShared via Lovio ✨\nhttps://lovio-e5990.web.app';
    try {
      channel.invokeMethod('shareText', {
        'text': text,
        'title': 'Share Story from Lovio',
      });
    } catch (_) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story copied to clipboard! 📋✨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCommentsSheet(BuildContext context, _FeedPostData post) {
    final commentController = TextEditingController();
    final lovio = context.lovioColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lovio.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comments (${post.commentCount})',
                    style:
                        AppTextStyles.headlineSmall(color: lovio.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: const [
                        _CommentTile(
                          author: 'sophia_rose',
                          avatarLetter: 'S',
                          comment:
                              'This literally brought tears to my eyes! So precious 🥹💕',
                          timeAgo: '1h ago',
                        ),
                        _CommentTile(
                          author: 'alex_wanderer',
                          avatarLetter: 'A',
                          comment:
                              'Couple goals for real! The colors on this card are stunning.',
                          timeAgo: '2h ago',
                        ),
                        _CommentTile(
                          author: 'charlotte_b',
                          avatarLetter: 'C',
                          comment:
                              'Happy Anniversary guys! Wishing you both a lifetime of happiness ✨',
                          timeAgo: '3h ago',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a sweet comment...',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: lovio.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: lovio.accent),
                        onPressed: () {
                          if (commentController.text.trim().isNotEmpty) {
                            setState(() {
                              post.commentCount++;
                            });
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment shared! 💕'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
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

  void _showPostDetailViewer(
      BuildContext context, _FeedPostData post, int postIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final lovio = context.lovioColors;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                children: [
                  // Top Drag handle & Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 14, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: lovio.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: lovio.textPrimary),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Content: Image + Formatted Text Below
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      children: [
                        // Author Info Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                gradient: post.authorGradient,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: lovio.surface,
                                child: Text(
                                  post.authorInitial,
                                  style: TextStyle(
                                    color: lovio.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: AppTextStyles.titleMedium(
                                        color: lovio.textPrimary),
                                  ),
                                  Text(
                                    post.location,
                                    style: AppTextStyles.bodySmall(
                                        color: lovio.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: lovio.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                post.postType == _PostType.loveLetter
                                    ? '💌 Love Letter'
                                    : post.postType == _PostType.storybook
                                        ? '📖 Storybook'
                                        : '📸 Photo Card',
                                style: AppTextStyles.labelSmall(
                                    color: lovio.accent),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // The Full Creation Image / Canvas
                        Container(
                          height: 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: post.gradient ?? lovio.primaryGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: lovio.glow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 52,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  post.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headlineMedium(
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post.quoteText,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.handwrittenLarge(
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Actions Row (Likes, Comments, Share, Save)
                        Row(
                          children: [
                            AnimatedPressable(
                              onPressed: () {
                                _toggleLike(postIndex);
                                setModalState(() {});
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    post.isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: post.isLiked
                                        ? lovio.accent
                                        : lovio.textPrimary,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${post.likeCount} Likes',
                                    style: AppTextStyles.labelLarge(
                                        color: lovio.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            AnimatedPressable(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _showCommentsSheet(context, post);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      color: lovio.textPrimary, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${post.commentCount} Comments',
                                    style: AppTextStyles.labelLarge(
                                        color: lovio.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            AnimatedPressable(
                              onPressed: () {
                                _toggleSave(postIndex);
                                setModalState(() {});
                              },
                              child: Icon(
                                post.isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: post.isSaved
                                    ? lovio.accent
                                    : lovio.textPrimary,
                                size: 26,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Divider(color: lovio.border),
                        const SizedBox(height: 14),

                        // Formatted Text Properly Below
                        Text(
                          'Full Story & Reflections',
                          style: AppTextStyles.titleMedium(
                              color: lovio.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lovio.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: lovio.border),
                          ),
                          child: Text(
                            post.caption,
                            style: AppTextStyles.bodyMedium(
                                    color: lovio.textPrimary)
                                .copyWith(height: 1.6),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Quick Comment Entry
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lovio.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _showCommentsSheet(context, post);
                          },
                          icon: const Icon(Icons.mode_comment_outlined, size: 20),
                          label: Text(
                              'View & Add Comments (${post.commentCount})'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStoryViewer(
      BuildContext context, String name, String subtitle, LinearGradient gradient) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: AppShadows.floating,
            ),
            child: Stack(
              children: [
                // Top Progress Bar & Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Text(
                              name[0],
                              style: const TextStyle(
                                color: AppColors.darkBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Center Story Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Celebrating 3 Years Together ✨',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displaySmall(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"Every moment with you is my favorite chapter." 💕',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.handwrittenLarge(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Reply Bar
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Send love to story...',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sent ❤️ to story!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: lovio.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar with Brand Title & Top-Right Dashboard Actions (Notifications + Profile Avatar)
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 76,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Lovio',
                      style:
                          AppTextStyles.displaySmall(color: lovio.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: lovio.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Share Love & Cherished Stories ✨',
                  style: AppTextStyles.handwrittenMedium(color: lovio.accent),
                ),
              ],
            ),
            // TOP-RIGHT ACTIONS: Bell Icon (Notifications) + User Profile Avatar
            actions: const [
              DashboardTopActions(),
            ],
          ),

          // 2. Stories Bar at the top of the social feed
          SliverToBoxAdapter(
            child: Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Current User "Your Story"
                  _YourStoryItem(
                    userName: currentUser?.displayName ?? 'You',
                    photoUrl: currentUser?.photoUrl,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add a new moment to Your Story ✨'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  // Other Users / Couples Stories
                  _StoryItem(
                    name: 'Sophia & Alex',
                    gradient: lovio.primaryGradient,
                    onTap: () => _showStoryViewer(
                      context,
                      'Sophia & Alex',
                      'Paris • 1h ago',
                      lovio.primaryGradient,
                    ),
                  ),
                  _StoryItem(
                    name: 'Liam & Emma',
                    gradient: lovio.secondaryGradient,
                    onTap: () => _showStoryViewer(
                      context,
                      'Liam & Emma',
                      'Venice • 3h ago',
                      lovio.secondaryGradient,
                    ),
                  ),
                  _StoryItem(
                    name: 'Noah & Ava',
                    gradient: lovio.primaryGradient,
                    onTap: () => _showStoryViewer(
                      context,
                      'Noah & Ava',
                      'Santorini • 5h ago',
                      lovio.primaryGradient,
                    ),
                  ),
                  _StoryItem(
                    name: 'Lucas & Mia',
                    gradient: AppColors.emeraldRomanceGradient,
                    onTap: () => _showStoryViewer(
                      context,
                      'Lucas & Mia',
                      'Kyoto • 8h ago',
                      AppColors.emeraldRomanceGradient,
                    ),
                  ),
                  _StoryItem(
                    name: 'Oliver & Rose',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB4A2), Color(0xFFE5989B)],
                    ),
                    onTap: () => _showStoryViewer(
                      context,
                      'Oliver & Rose',
                      'New York • 12h ago',
                      const LinearGradient(
                        colors: [Color(0xFFFFB4A2), Color(0xFFE5989B)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider below stories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Divider(color: lovio.border.withOpacity(0.6), height: 1),
            ),
          ),

          // 3. Instagram-Style Social Feed Posts List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = _posts[index];
                return _SocialFeedPostCard(
                  post: post,
                  onLike: () => _toggleLike(index),
                  onComment: () => _showCommentsSheet(context, post),
                  onSave: () => _toggleSave(index),
                  onShare: () => _sharePost(post),
                  onOpenDetail: () =>
                      _showPostDetailViewer(context, post, index),
                );
              },
              childCount: _posts.length,
            ),
          ),

          // Bottom padding for floating navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _SocialFeedPostCard extends StatefulWidget {
  final _FeedPostData post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onOpenDetail;

  const _SocialFeedPostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
    required this.onOpenDetail,
  });

  @override
  State<_SocialFeedPostCard> createState() => _SocialFeedPostCardState();
}

class _SocialFeedPostCardState extends State<_SocialFeedPostCard> {
  bool _showHeartAnimation = false;

  void _handleDoubleTap() {
    widget.onLike();
    setState(() => _showHeartAnimation = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.softCard,
        border: Border.all(color: lovio.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Post Header (Avatar, Author, Location, Options)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: post.authorGradient ?? lovio.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: lovio.surface,
                    child: Text(
                      post.authorInitial,
                      style: TextStyle(
                        color: lovio.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: AppTextStyles.titleMedium(
                          color: lovio.textPrimary,
                        ),
                      ),
                      Text(
                        post.location,
                        style:
                            AppTextStyles.bodySmall(color: lovio.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz_rounded,
                      color: lovio.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 2. Post Media / Canvas (with Tap to open full story & Double-Tap Heart)
          GestureDetector(
            onTap: widget.onOpenDetail,
            onDoubleTap: _handleDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: post.gradient ?? lovio.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (post.postType == _PostType.loveLetter) ...[
                          Icon(Icons.markunread_mailbox_rounded,
                              size: 36, color: lovio.accent),
                          const SizedBox(height: 12),
                          Text(
                            post.quoteText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.handwrittenLarge(
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: lovio.accent.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Sealed with Love 💕',
                              style: AppTextStyles.labelSmall(
                                color: lovio.accent,
                              ),
                            ),
                          ),
                        ] else if (post.postType == _PostType.storybook) ...[
                          const Icon(Icons.auto_stories_rounded,
                              size: 44, color: AppColors.darkBrown),
                          const SizedBox(height: 14),
                          Text(
                            post.title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineMedium(
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.quoteText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.darkBrown.withOpacity(0.85),
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.favorite_rounded,
                              size: 48, color: Colors.white),
                          const SizedBox(height: 14),
                          Text(
                            post.title,
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.headlineSmall(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.quoteText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.handwrittenMedium(
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Animated heart burst on double-tap
                if (_showHeartAnimation)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.2),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 90,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // 3. Action Buttons Row (Like, Comment, Share, Bookmark)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                AnimatedPressable(
                  onPressed: widget.onLike,
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color:
                            post.isLiked ? lovio.accent : lovio.textPrimary,
                        size: 26,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likeCount}',
                        style: AppTextStyles.labelMedium(
                          color: lovio.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                AnimatedPressable(
                  onPressed: widget.onComment,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: lovio.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentCount}',
                        style: AppTextStyles.labelMedium(
                          color: lovio.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                AnimatedPressable(
                  onPressed: widget.onShare,
                  child: Icon(
                    Icons.send_rounded,
                    color: lovio.textPrimary,
                    size: 22,
                  ),
                ),
                const Spacer(),
                AnimatedPressable(
                  onPressed: widget.onSave,
                  child: Icon(
                    post.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: post.isSaved ? lovio.accent : lovio.textPrimary,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // 4. Clean Footer: Tap to view full story & reflections (no bottom text clutter)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
            child: AnimatedPressable(
              onPressed: widget.onOpenDetail,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: lovio.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lovio.border.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_stories_rounded,
                        size: 16, color: lovio.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap to view full story & reflections ✨',
                        style: AppTextStyles.labelMedium(
                            color: lovio.textPrimary),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: lovio.textMuted),
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

class _YourStoryItem extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final VoidCallback onTap;

  const _YourStoryItem({
    required this.userName,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    final avatarImage = getAvatarImageProvider(photoUrl);

    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lovio.border,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: lovio.primary.withOpacity(0.3),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Icon(
                            Icons.person_rounded,
                            color: lovio.accent,
                            size: 28,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: lovio.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Your Story',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(color: lovio.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String name;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _StoryItem({
    required this.name,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: lovio.glow,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: lovio.surface,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: lovio.surface,
                  child: Text(
                    name.isNotEmpty ? name[0] : 'S',
                    style: TextStyle(
                      color: lovio.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(color: lovio.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String author;
  final String avatarLetter;
  final String comment;
  final String timeAgo;

  const _CommentTile({
    required this.author,
    required this.avatarLetter,
    required this.comment,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: lovio.primary.withOpacity(0.3),
            child: Text(
              avatarLetter,
              style: TextStyle(
                color: lovio.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall(color: lovio.textPrimary),
                    children: [
                      TextSpan(
                        text: '$author ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: AppTextStyles.labelSmall(color: lovio.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _PostType { photoCard, loveLetter, storybook }

class _FeedPostData {
  final String id;
  final String authorName;
  final String authorHandle;
  final String authorInitial;
  final LinearGradient? authorGradient;
  final String location;
  final String title;
  final String caption;
  int likeCount;
  int commentCount;
  bool isLiked;
  bool isSaved;
  final _PostType postType;
  final LinearGradient? gradient;
  final String quoteText;

  _FeedPostData({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.authorInitial,
    this.authorGradient,
    required this.location,
    required this.title,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isSaved,
    required this.postType,
    this.gradient,
    required this.quoteText,
  });
}
