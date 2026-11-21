import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../navigation/presentation/widgets/dashboard_top_actions.dart';

class MomentsScreen extends ConsumerStatefulWidget {
  const MomentsScreen({super.key});

  @override
  ConsumerState<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends ConsumerState<MomentsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    '❤️ Anniversaries',
    '🎂 Birthdays',
    '☕ First Met',
    '✨ Milestones',
    '👨‍👩‍👧 Family',
    '🕊️ Memorial Days',
  ];

  late List<_MomentItem> _moments;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _moments = [
      _MomentItem(
        id: 'm1',
        title: 'Our 1st Official Anniversary',
        category: '❤️ Anniversaries',
        date: now.add(const Duration(days: 4)),
        note:
            'One full year of laughter, growth, and endless love. Planning a surprise dinner and memory book 💕',
        isUpcoming: true,
        daysCount: 4,
        gradient: null,
        icon: Icons.favorite_rounded,
      ),
      _MomentItem(
        id: 'm2',
        title: "Sophia's 25th Birthday",
        category: '🎂 Birthdays',
        date: now.add(const Duration(days: 24)),
        note:
            'Order the strawberry shortcake and frame the Paris travel polaroids 🎂✨',
        isUpcoming: true,
        daysCount: 24,
        gradient: null,
        icon: Icons.cake_rounded,
      ),
      _MomentItem(
        id: 'm3',
        title: 'The Rainy Day We First Met at Café Bloom',
        category: '☕ First Met',
        date: DateTime(now.year - 1, now.month - 2, 14),
        note:
            'You spilled your latte, we both laughed, and you shared your umbrella. Best rainy day ever ☕☔',
        isUpcoming: false,
        daysCount: 420,
        gradient: null,
        icon: Icons.coffee_rounded,
      ),
      _MomentItem(
        id: 'm4',
        title: 'Moved Into Our First Apartment Together',
        category: '✨ Milestones',
        date: DateTime(now.year, now.month - 4, 1),
        note:
            'Surrounded by cardboard boxes eating takeout pizza on the floor. It already felt like home 🏡🍕',
        isUpcoming: false,
        daysCount: 120,
        gradient: null,
        icon: Icons.home_rounded,
      ),
      _MomentItem(
        id: 'm5',
        title: "Grandma Rose's Remembrance Day",
        category: '🕊️ Memorial Days',
        date: DateTime(now.year, now.month + 2, 20),
        note:
            'Planting white roses in the garden in loving memory of her gentle heart 🕊️🤍',
        isUpcoming: true,
        daysCount: 65,
        gradient: const LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
        ),
        icon: Icons.spa_rounded,
      ),
    ];
  }

  void _showAddMomentSheet(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String selectedCat = '❤️ Anniversaries';
    bool reminderEnabled = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final lovio = context.lovioColors;

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: lovio.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: AppShadows.floating,
              ),
              child: SingleChildScrollView(
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
                    const SizedBox(height: 16),
                    Text(
                      'Add Special Date & Memory',
                      style:
                          AppTextStyles.headlineSmall(color: lovio.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Never miss an anniversary, birthday, or personal milestone',
                      style:
                          AppTextStyles.bodySmall(color: lovio.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Moment Title',
                        hintText: 'e.g., First Kiss, Proposal, Mom\'s Birthday',
                        prefixIcon: Icon(Icons.favorite_border_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Selection
                    Text(
                      'Category',
                      style: AppTextStyles.labelMedium(color: lovio.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.where((c) => c != 'All').map((cat) {
                        final isSel = selectedCat == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (_) =>
                              setSheetState(() => selectedCat = cat),
                          selectedColor: lovio.accent.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSel ? lovio.accent : lovio.textPrimary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Date Picker Tile
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_today_rounded,
                          color: lovio.accent),
                      title: Text(
                        'Date: ${DateFormat('MMMM d, yyyy').format(selectedDate)}',
                        style:
                            AppTextStyles.titleMedium(color: lovio.textPrimary),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2050),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Text(
                          'Change Date',
                          style: AppTextStyles.labelLarge(color: lovio.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Reminder Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: reminderEnabled,
                      activeColor: lovio.accent,
                      title: Text(
                        'Enable Celebration Reminder',
                        style:
                            AppTextStyles.titleMedium(color: lovio.textPrimary),
                      ),
                      subtitle: Text(
                        'Get notified 7 days and 1 day in advance',
                        style:
                            AppTextStyles.bodySmall(color: lovio.textSecondary),
                      ),
                      onChanged: (val) =>
                          setSheetState(() => reminderEnabled = val),
                    ),
                    const SizedBox(height: 8),

                    // Note Input
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Personal Memory Note',
                        hintText: 'What makes this date so unforgettable?',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    AnimatedPressable(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final newMoment = _MomentItem(
                          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text.trim(),
                          category: selectedCat,
                          date: selectedDate,
                          note: noteController.text.trim(),
                          isUpcoming: selectedDate.isAfter(DateTime.now()),
                          daysCount: selectedDate
                              .difference(DateTime.now())
                              .inDays
                              .abs(),
                          gradient: null,
                          icon: Icons.favorite_rounded,
                        );

                        setState(() {
                          _moments.insert(0, newMoment);
                        });

                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Special date saved to your memories! ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: lovio.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: lovio.glow,
                        ),
                        child: Center(
                          child: Text(
                            'Save to My Moments',
                            style: AppTextStyles.labelLarge(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    final upcomingItem = _moments.firstWhere(
      (m) => m.isUpcoming,
      orElse: () => _moments.first,
    );

    final filteredList = _selectedCategory == 'All'
        ? _moments
        : _moments.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: lovio.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar with Moments Title & Top-Right Dashboard Actions (Bell Icon + Profile Avatar)
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
                  'My Moments',
                  style: AppTextStyles.displaySmall(color: lovio.textPrimary),
                ),
                Text(
                  'Important dates, memories & milestones ✨',
                  style: AppTextStyles.handwrittenMedium(color: lovio.accent),
                ),
              ],
            ),
            // TOP-RIGHT DASHBOARD ACTIONS
            actions: const [
              DashboardTopActions(),
            ],
          ),

          // 2. Prominent Upcoming Day & Reminder Hero Card (At the top of the page)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: upcomingItem.gradient ?? lovio.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: lovio.glow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm_on_rounded,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'UPCOMING IN ${upcomingItem.daysCount} DAYS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    upcomingItem.title,
                    style: AppTextStyles.headlineMedium(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('EEEE, MMMM d, yyyy').format(upcomingItem.date)} 💕',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    upcomingItem.note,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quick Action Button
                  Row(
                    children: [
                      AnimatedPressable(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Opening Love Letter editor for your anniversary surprise ✨'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShadows.softCard,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_note_rounded,
                                  size: 18, color: lovio.accent),
                              const SizedBox(width: 6),
                              Text(
                                'Write Surprise Letter',
                                style: AppTextStyles.labelMedium(
                                    color: lovio.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Reminder Active 🔔',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Category Filter Chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedPressable(
                      onPressed: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                          cat,
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

          // Section Header with "Add Date" Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Special Dates & Memories',
                    style:
                        AppTextStyles.headlineSmall(color: lovio.textPrimary),
                  ),
                  AnimatedPressable(
                    onPressed: () => _showAddMomentSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: lovio.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: lovio.accent.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              size: 16, color: lovio.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Add Date',
                            style:
                                AppTextStyles.labelSmall(color: lovio.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Memories & Dates Timeline Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final moment = filteredList[index];
                return _MomentTimelineCard(
                  moment: moment,
                  onEdit: () {},
                );
              },
              childCount: filteredList.length,
            ),
          ),

          // Bottom Spacing for floating navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _MomentTimelineCard extends StatelessWidget {
  final _MomentItem moment;
  final VoidCallback onEdit;

  const _MomentTimelineCard({
    required this.moment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.softCard,
        border: Border.all(color: lovio.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Date Calendar Pill
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: moment.isUpcoming
                  ? lovio.primaryGradient
                  : (moment.gradient ??
                      LinearGradient(
                        colors: [
                          lovio.primary.withOpacity(0.14),
                          lovio.secondary.withOpacity(0.28),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (moment.isUpcoming ? lovio.primary : lovio.secondary)
                      .withOpacity(0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(moment.date).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: moment.isUpcoming ? Colors.white : lovio.accent,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${moment.date.day}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: moment.isUpcoming ? Colors.white : lovio.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: lovio.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        moment.category,
                        style: AppTextStyles.labelSmall(color: lovio.accent),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      moment.isUpcoming
                          ? 'In ${moment.daysCount} days'
                          : '${moment.daysCount} days ago',
                      style: AppTextStyles.labelSmall(color: lovio.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  moment.title,
                  style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  moment.note,
                  style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentItem {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String note;
  final bool isUpcoming;
  final int daysCount;
  final LinearGradient? gradient;
  final IconData icon;

  _MomentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.note,
    required this.isUpcoming,
    required this.daysCount,
    this.gradient,
    required this.icon,
  });
}
