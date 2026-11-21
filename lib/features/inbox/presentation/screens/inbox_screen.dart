import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../navigation/presentation/widgets/dashboard_top_actions.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabs = ['Chats', 'Received Letters', 'Story Replies'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openChatDialog(BuildContext context, String name, String subtitle) {
    final lovio = context.lovioColors;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
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
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lovio.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Chat Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: lovio.primary.withOpacity(0.3),
                        child: Text(
                          name[0],
                          style: TextStyle(
                            color: lovio.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.titleMedium(
                                color: lovio.textPrimary,
                              ),
                            ),
                            Text(
                              'Active now • Tap to view profile',
                              style: AppTextStyles.labelSmall(
                                color: const Color(0xFF06D6A0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded,
                            color: AppColors.roseAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sent heart to $name 💕'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Messages list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _MessageBubble(
                          text: subtitle,
                          isMe: false,
                          time: '12:30 PM',
                        ),
                        const _MessageBubble(
                          text:
                              'I loved the anniversary card! Cannot wait for tonight 💕',
                          isMe: true,
                          time: '12:32 PM',
                        ),
                        const _MessageBubble(
                          text:
                              'Meet me at 7:00 PM at Café Bloom? I have a small surprise for you ✨',
                          isMe: false,
                          time: '12:35 PM',
                        ),
                      ],
                    ),
                  ),

                  // Input row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Message $name...',
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
                          if (textController.text.trim().isNotEmpty) {
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message delivered 💕'),
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

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Scaffold(
      backgroundColor: lovio.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inbox',
              style: AppTextStyles.displaySmall(color: lovio.textPrimary),
            ),
            Text(
              'Chats, letters & shared memories ✨',
              style: AppTextStyles.handwrittenMedium(color: lovio.accent),
            ),
          ],
        ),
        // TOP-RIGHT DASHBOARD ACTIONS
        actions: const [
          DashboardTopActions(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: Colors.white,
              unselectedLabelColor: lovio.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: lovio.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: lovio.glow,
              ),
              labelStyle: AppTextStyles.labelMedium(),
              unselectedLabelStyle: AppTextStyles.bodySmall(),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsList(context),
          _buildReceivedCreationsList(context),
          _buildStoryRepliesList(context),
        ],
      ),
    );
  }

  Widget _buildChatsList(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _ChatTile(
          name: 'Sophia ❤️',
          lastMessage: 'I just finished reading your anniversary book! 😭💕',
          time: '2m ago',
          unreadCount: 2,
          isOnline: true,
          onTap: () => _openChatDialog(
            context,
            'Sophia ❤️',
            'I just finished reading your anniversary book! 😭💕',
          ),
        ),
        _ChatTile(
          name: 'Liam & Emma',
          lastMessage: 'Sent ❤️ to your anniversary story.',
          time: '1h ago',
          unreadCount: 0,
          isOnline: false,
          onTap: () => _openChatDialog(
            context,
            'Liam & Emma',
            'Sent ❤️ to your anniversary story.',
          ),
        ),
        _ChatTile(
          name: 'Noah & Ava',
          lastMessage: 'Can you share your Paris scrapbook template with us?',
          time: '3h ago',
          unreadCount: 1,
          isOnline: true,
          onTap: () => _openChatDialog(
            context,
            'Noah & Ava',
            'Can you share your Paris scrapbook template with us?',
          ),
        ),
        _ChatTile(
          name: 'Mom 🌸',
          lastMessage:
              'Happy early anniversary sweethearts! Calling you tonight.',
          time: 'Yesterday',
          unreadCount: 0,
          isOnline: false,
          onTap: () => _openChatDialog(
            context,
            'Mom 🌸',
            'Happy early anniversary sweethearts! Calling you tonight.',
          ),
        ),
        _ChatTile(
          name: 'Lovio Team',
          lastMessage: 'Welcome to Lovio! Explore 20+ animated backgrounds.',
          time: '2d ago',
          unreadCount: 0,
          isOnline: false,
          onTap: () => _openChatDialog(
            context,
            'Lovio Team',
            'Welcome to Lovio! Explore 20+ animated backgrounds.',
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedCreationsList(BuildContext context) {
    final lovio = context.lovioColors;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.softCard,
            border: Border.all(color: lovio.border),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: lovio.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Received from Sophia',
                      style: AppTextStyles.labelSmall(color: lovio.accent),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Our Sweetest Memories',
                      style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Interactive Book • 14 Pages',
                      style:
                          AppTextStyles.bodySmall(color: lovio.textSecondary),
                    ),
                  ],
                ),
              ),
              AnimatedPressable(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening interactive book... ✨'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: lovio.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Open',
                    style: AppTextStyles.labelMedium(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryRepliesList(BuildContext context) {
    final lovio = context.lovioColors;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lovio.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.softCard,
            border: Border.all(color: lovio.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: lovio.primary.withOpacity(0.3),
                child: Text(
                  'L',
                  style: TextStyle(
                    color: lovio.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lucas & Mia',
                      style: AppTextStyles.titleMedium(color: lovio.textPrimary),
                    ),
                    Text(
                      'Reacted ❤️ to your anniversary countdown story',
                      style: AppTextStyles.bodySmall(color: lovio.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '4h ago',
                style: AppTextStyles.labelSmall(color: lovio.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  const _ChatTile({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: lovio.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.softCard,
        border: Border.all(color: lovio.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: lovio.primary.withOpacity(0.3),
              child: Text(
                name.isNotEmpty ? name[0] : 'U',
                style: AppTextStyles.titleMedium(color: lovio.accent),
              ),
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06D6A0),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(name,
            style: AppTextStyles.titleMedium(color: lovio.textPrimary)),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall(
            color: unreadCount > 0 ? lovio.textPrimary : lovio.textSecondary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time,
                style: AppTextStyles.labelSmall(
                    color: unreadCount > 0 ? lovio.accent : lovio.textMuted)),
            const SizedBox(height: 4),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: lovio.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final lovio = context.lovioColors;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? lovio.accent : lovio.primary.withOpacity(0.18),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : lovio.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : lovio.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
