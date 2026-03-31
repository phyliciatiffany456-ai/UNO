import 'package:flutter/material.dart';

import '../models/chat_store.dart';
import '../models/story_item.dart';
import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'chat_profile_info_page.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class ChatBoxPage extends StatefulWidget {
  const ChatBoxPage({super.key});

  @override
  State<ChatBoxPage> createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  final TextEditingController _controller = TextEditingController();
  bool _viewedChatStory = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshInputState);
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshInputState);
    _controller.dispose();
    super.dispose();
  }

  bool get _hasText => _controller.text.trim().isNotEmpty;

  void _refreshInputState() {
    if (mounted) setState(() {});
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage()));
  }

  void _sendMessage() {
    final String message = _controller.text.trim();
    if (message.isEmpty) return;
    ChatStore.add(message);
    _controller.clear();
  }

  Future<void> _openChatProfileStory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const StoryViewerPage(story: StoryItem(label: 'TiffanyPhylicia')),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedChatStory = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: _openNotifications,
              onSearchTap: _openSearch,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF24262E)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ChatProfileAvatar(
                          viewed: _viewedChatStory,
                          onTap: _openChatProfileStory,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ChatProfileInfoPage(
                                    name: 'TiffanyPhylicia',
                                    role: 'UI/UX Designer',
                                    bio:
                                        'Suka bangun produk digital dan kolaborasi bareng tim lintas divisi.',
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'TiffanyPhylicia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.local_fire_department,
                          color: Color(0xFFFFA84D),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 280,
                      child: ValueListenableBuilder<List<ChatMessage>>(
                        valueListenable: ChatStore.messages,
                        builder: (
                          BuildContext context,
                          List<ChatMessage> messages,
                          Widget? child,
                        ) {
                          return ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ChatMessage message = messages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _bubble(
                                  alignRight: message.fromMe,
                                  label: message.text,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1014),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2D313B)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: const Color(0xFFFF6A2D),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: _hasText ? _sendMessage : null,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFE23E6B), Color(0xFFF2A63D)],
                        ),
                      ),
                      child: Icon(
                        _hasText ? Icons.send_rounded : Icons.add,
                        color: Colors.white,
                        size: _hasText ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.community,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () => AppRoutes.goApply(context),
        onCreateTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage())),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }

  Widget _bubble({required bool alignRight, required String label}) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 210),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: alignRight ? const Color(0xFFFF6A2D) : const Color(0xFF0E1014),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: alignRight
                ? const Color(0xFFFF6A2D)
                : const Color(0xFF2D313B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: alignRight ? Colors.white : const Color(0xFFD1D5DB),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _ChatProfileAvatar extends StatelessWidget {
  const _ChatProfileAvatar({required this.viewed, required this.onTap});

  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        StoryRingAvatar(size: 34, viewed: viewed, onTap: onTap),
        const CircleAvatar(
          radius: 11,
          backgroundColor: Color(0xFFE5E7EB),
          child: Icon(Icons.person, size: 13, color: Color(0xFF121417)),
        ),
      ],
    );
  }
}
