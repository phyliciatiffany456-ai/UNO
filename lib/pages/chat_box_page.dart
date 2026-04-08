import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../services/chat_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'chat_profile_info_page.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';

class ChatBoxPage extends StatefulWidget {
  const ChatBoxPage({
    super.key,
    this.initialRoomId,
    this.roomTitle,
    this.isGroupRoom = true,
  });

  final String? initialRoomId;
  final String? roomTitle;
  final bool isGroupRoom;

  @override
  State<ChatBoxPage> createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  String? _roomId;
  String? _roomError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshInputState);
    if (widget.initialRoomId != null) {
      _roomId = widget.initialRoomId;
      _roomError = null;
    } else {
      _setupRoom();
    }
  }

  Future<void> _setupRoom() async {
    try {
      final String roomId = await _chatService.ensureGlobalCommunityRoom();
      if (!mounted) return;
      setState(() {
        _roomId = roomId;
        _roomError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _roomError = e.toString();
      });
    }
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
    final String? roomId = _roomId;
    if (roomId == null) return;
    final String message = _controller.text.trim();
    if (message.isEmpty) return;
    _chatService.sendMessage(roomId: roomId, content: message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.roomTitle ?? 'Komunitas UNO';
    final bool isGroup = widget.roomTitle == null ? true : widget.isGroupRoom;
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
                        const CircleAvatar(
                          radius: 17,
                          backgroundColor: Color(0xFFE5E7EB),
                          child: Icon(
                            Icons.groups_2_outlined,
                            color: Color(0xFF121417),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ChatProfileInfoPage(
                                    name: title,
                                    role: isGroup ? 'Group Chat' : 'Direct Chat',
                                    bio: isGroup
                                        ? 'Ruang obrolan komunitas UNO.'
                                        : 'Obrolan private untuk proses rekrutmen.',
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                title,
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
                          isGroup
                              ? Icons.local_fire_department
                              : Icons.verified_user_outlined,
                          color: isGroup
                              ? const Color(0xFFFFA84D)
                              : const Color(0xFF34D399),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 280,
                      child: _roomId == null
                          ? Center(
                              child: _roomError == null
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Chat belum siap.\nCek schema chat di Supabase.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: _setupRoom,
                                          child: const Text('Coba lagi'),
                                        ),
                                      ],
                                    ),
                            )
                          : StreamBuilder<List<ChatMessageItem>>(
                              stream: _chatService.watchMessages(_roomId!),
                              builder: (
                                BuildContext context,
                                AsyncSnapshot<List<ChatMessageItem>> snapshot,
                              ) {
                                final List<ChatMessageItem> messages =
                                    snapshot.data ?? <ChatMessageItem>[];
                                final String myId =
                                    _chatService.currentUser?.id ?? '';
                                return ListView.builder(
                                  itemCount: messages.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final ChatMessageItem message =
                                        messages[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _bubble(
                                        alignRight: message.senderId == myId,
                                        label: message.content,
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
                    onTap: (_hasText && _roomId != null) ? _sendMessage : null,
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
