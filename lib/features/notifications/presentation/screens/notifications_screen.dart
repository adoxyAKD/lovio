import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Reminders',
    'Partner',
    'Reactions',
    'Comments',
  ];

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      id: '1',
      title: 'Partner Love Note',
      message: 'Sophia sent you a sweet Love Letter: "You make every day magical 💕"',
      timeAgo: 'Just now',
      category: 'Partner',
      icon: Icons.favorite_rounded,
      iconColor: AppColors.roseAccent,
      isUnread: true,
    ),
    _NotificationItem(
      id: '2',
      title: 'Upcoming Milestone Alert',
      message: '4 days until your 1st Anniversary! Start creating your surprise card ✨',
      timeAgo: '2 hours ago',
      category: 'Reminders',
      icon: Icons.celebration_rounded,
      iconColor: const Color(0xFFF77F00),
      isUnread: true,
    ),
    _NotificationItem(
      id: '3',
      title: 'Story Reaction',
      message: 'Lucas and 18 others reacted ❤️ to your memory story.',
      timeAgo: '4 hours ago',
      category: 'Reactions',
      icon: Icons.thumb_up_rounded,
      iconColor: const Color(0xFF4361EE),
      isUnread: false,
    ),
    _NotificationItem(
      id: '4',
      title: 'New Comment',
      message: 'Emma commented: "This is the most romantic book I have seen! 🥹"',
      timeAgo: 'Yesterday',
      category: 'Comments',
      icon: Icons.chat_bubble_rounded,
      iconColor: const Color(0xFF06D6A0),
      isUnread: false,
    ),
    _NotificationItem(
      id: '5',
      title: 'Birthday Reminder',
      message: 'Mom\'s Birthday is in 12 days. Set a celebration reminder!',
      timeAgo: '2 days ago',
      category: 'Reminders',
      icon: Icons.cake_rounded,
      iconColor: const Color(0xFFE056FD),
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    final filteredList = _selectedFilter == 'All'
        ? _notifications
        : _notifications.where((n) => n.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.displaySmall(color: lovio.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n.isUnread = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read ✨'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium(color: lovio.accent),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedPressable(
                    onPressed: () => setState(() => _selectedFilter = filter),
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
                        filter,
                        style: AppTextStyles.labelMedium(
                          color: isSelected ? Colors.white : lovio.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Notifications List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 48, color: lovio.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications in this category',
                          style: AppTextStyles.bodyMedium(
                              color: lovio.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.isUnread
                              ? lovio.primary.withOpacity(0.12)
                              : lovio.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: item.isUnread
                                ? lovio.accent.withOpacity(0.3)
                                : lovio.border,
                          ),
                          boxShadow: AppShadows.softCard,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.iconColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                color: item.iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTextStyles.titleMedium(
                                          color: lovio.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        item.timeAgo,
                                        style: AppTextStyles.labelSmall(
                                          color: lovio.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    style: AppTextStyles.bodySmall(
                                      color: lovio.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: lovio.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category;
  final IconData icon;
  final Color iconColor;
  bool isUnread;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.isUnread,
  });
}

