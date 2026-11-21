import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../navigation/presentation/widgets/dashboard_top_actions.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '🔥 Trending';

  final List<String> _categories = [
    '🔥 Trending',
    '💌 Love Letters',
    '📖 Storybooks',
    '🎂 Anniversaries',
    '✨ Aesthetic Quotes',
    '📸 Memory Collages',
    '🎨 Scrapbooks',
    '🎁 Gift Cards',
  ];

  final List<_ExploreCardData> _inspirationItems = [
    _ExploreCardData(
      id: 'e1',
      title: 'Vintage Parchment Letter',
      category: 'Love Letters',
      creator: '@sophia_rose',
      likes: '14.2k',
      height: 220,
      gradient: null,
      snippet: '"In every lifetime, I will always choose you."',
      icon: Icons.markunread_mailbox_rounded,
    ),
    _ExploreCardData(
      id: 'e2',
      title: 'Our First 365 Days Book',
      category: 'Storybooks',
      creator: '@alex_wanderer',
      likes: '9.8k',
      height: 270,
      gradient: AppColors.lavenderBlushGradient,
      snippet: '12 Chapters • Interactive cover • Flip sound',
      icon: Icons.auto_stories_rounded,
    ),
    _ExploreCardData(
      id: 'e3',
      title: 'Romantic Sunset Polaroid',
      category: 'Memory Collages',
      creator: '@noah_and_ava',
      likes: '18.4k',
      height: 240,
      gradient: AppColors.primaryGradient,
      snippet: 'Double exposure frame with animated grain effect',
      icon: Icons.photo_library_rounded,
    ),
    _ExploreCardData(
      id: 'e4',
      title: 'Golden Hour Anniversary Card',
      category: 'Anniversaries',
      creator: '@oliver_rose',
      likes: '7.1k',
      height: 210,
      gradient: AppColors.emeraldRomanceGradient,
      snippet: '3D Folding card with gold leaf ribbon',
      icon: Icons.card_giftcard_rounded,
    ),
    _ExploreCardData(
      id: 'e5',
      title: 'Midnight Velvet Poetry',
      category: 'Aesthetic Quotes',
      creator: '@poetry_love',
      likes: '12.6k',
      height: 260,
      gradient: const LinearGradient(
        colors: [Color(0xFF2C223B), Color(0xFF533B6C)],
      ),
      snippet: '"You are my today and all of my tomorrows."',
      icon: Icons.brush_rounded,
    ),
    _ExploreCardData(
      id: 'e6',
      title: 'Roadtrip Scrapbook Canvas',
      category: 'Scrapbooks',
      creator: '@mia_travels',
      likes: '8.3k',
      height: 230,
      gradient: const LinearGradient(
        colors: [Color(0xFFFFB4A2), Color(0xFFE5989B)],
      ),
      snippet: 'Stickers, ticket stubs, and GPS route overlay',
      icon: Icons.map_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showInspirationPreview(BuildContext context, _ExploreCardData item) {
    final lovio = context.lovioColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: AppShadows.floating,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: lovio.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Visual Preview
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: item.gradient ?? lovio.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.softCard,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 44, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineSmall(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.snippet,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.handwrittenMedium(
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Creator & Stats
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: lovio.primary.withOpacity(0.3),
                    child: Text(
                      item.creator[1].toUpperCase(),
                      style: TextStyle(
                        color: lovio.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created by ${item.creator}',
                        style: AppTextStyles.titleMedium(
                          color: lovio.textPrimary,
                        ),
                      ),
                      Text(
                        '${item.likes} people used this template',
                        style: AppTextStyles.bodySmall(
                          color: lovio.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lovio.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.category,
                      style: AppTextStyles.labelSmall(color: lovio.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to personalize this with your own photos, heartfelt words, and dynamic animations.',
                style: AppTextStyles.bodyMedium(color: lovio.textSecondary),
              ),
              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Template saved to your ideas! 💡'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Save Idea'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lovio.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Opening canvas with this template... ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Use Template'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Scaffold(
      backgroundColor: lovio.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar with Explore Title & Top-Right Actions (Bell Icon + Profile Avatar)
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 76,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: AppTextStyles.displaySmall(color: lovio.textPrimary),
                ),
                Text(
                  'Discover creative prompts & inspiration ✨',
                  style: AppTextStyles.handwrittenMedium(color: lovio.accent),
                ),
              ],
            ),
            // TOP-RIGHT DASHBOARD ACTIONS
            actions: const [
              DashboardTopActions(),
            ],
          ),

          // 2. Modern Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: GlassContainer(
                blur: 16,
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: lovio.textSecondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style:
                            AppTextStyles.bodyMedium(color: lovio.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search templates, letters, stories...',
                          hintStyle:
                              AppTextStyles.bodyMedium(color: lovio.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 18, color: lovio.textMuted),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lovio.primary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune_rounded,
                          size: 18, color: lovio.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Category Filter Chips (Horizontal Scroll)
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedPressable(
                      onPressed: () {
                        setState(() => _selectedCategory = category);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: isSelected ? lovio.primaryGradient : null,
                          color: isSelected ? null : lovio.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : lovio.border,
                          ),
                          boxShadow: isSelected
                              ? lovio.glow
                              : AppShadows.softCard,
                        ),
                        child: Text(
                          category,
                          style: AppTextStyles.labelMedium(
                            color:
                                isSelected ? Colors.white : lovio.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 4. Trending Inspiration Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: lovio.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: lovio.glow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'TRENDING TEMPLATE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Our Anniversary Scrapbook',
                          style: AppTextStyles.headlineSmall(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '18.4k couples used this layout this week ✨',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: lovio.accent,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Creative Inspirations',
                    style:
                        AppTextStyles.headlineSmall(color: lovio.textPrimary),
                  ),
                  Text(
                    'Featured',
                    style: AppTextStyles.labelSmall(color: lovio.accent),
                  ),
                ],
              ),
            ),
          ),

          // 5. Masonry/Staggered Discovery Grid (Two Columns)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _inspirationItems[index];
                  return AnimatedPressable(
                    onPressed: () => _showInspirationPreview(context, item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: lovio.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppShadows.softCard,
                        border: Border.all(color: lovio.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Graphic / Thumbnail
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: item.gradient ?? lovio.primaryGradient,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      item.icon,
                                      size: 38,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.favorite_rounded,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.likes,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
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

                          // Metadata
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleSmall(
                                    color: lovio.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      item.creator,
                                      style: AppTextStyles.labelSmall(
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
                },
                childCount: _inspirationItems.length,
              ),
            ),
          ),

          // Bottom spacing for floating navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _ExploreCardData {
  final String id;
  final String title;
  final String category;
  final String creator;
  final String likes;
  final double height;
  final LinearGradient? gradient;
  final String snippet;
  final IconData icon;

  _ExploreCardData({
    required this.id,
    required this.title,
    required this.category,
    required this.creator,
    required this.likes,
    required this.height,
    this.gradient,
    required this.snippet,
    required this.icon,
  });
}
