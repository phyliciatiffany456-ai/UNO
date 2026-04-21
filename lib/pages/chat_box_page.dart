import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../services/chat_service.dart';
import '../services/google_meet_service.dart';
import '../services/profile_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'chat_profile_info_page.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'online_meeting_page.dart';
import 'search_page.dart';

class ChatBoxPage extends StatefulWidget {
  const ChatBoxPage({
    super.key,
    this.initialRoomId,
    this.roomTitle,
    this.isGroupRoom = true,
    this.otherUserId,
  });

  final String? initialRoomId;
  final String? roomTitle;
  final bool isGroupRoom;
  final String? otherUserId;

  @override
  State<ChatBoxPage> createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  final ChatService _chatService = ChatService();
  final GoogleMeetService _googleMeetService = GoogleMeetService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _roomId;
  String? _roomError;
  String? _avatarUrl;
  Stream<List<ChatMessageItem>>? _messageStream;
  List<ChatMessageItem> _cachedMessages = <ChatMessageItem>[];
  List<ChatMessageItem> _pendingMessages = <ChatMessageItem>[];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshInputState);
    _loadHeaderProfile();
    if (widget.initialRoomId != null) {
      _bindRoom(widget.initialRoomId!);
    } else {
      _setupRoom();
    }
  }

  Future<void> _loadHeaderProfile() async {
    if (widget.isGroupRoom || widget.otherUserId == null) return;
    try {
      final ProfileRecord? profile = await _profileService.fetchProfileByUserId(
        widget.otherUserId!,
      );
      if (!mounted) return;
      setState(() {
        _avatarUrl = profile?.avatarUrl;
      });
    } catch (_) {}
  }

  void _bindRoom(String roomId) {
    _roomId = roomId;
    _roomError = null;
    _cachedMessages = <ChatMessageItem>[];
    _pendingMessages = <ChatMessageItem>[];
    _messageStream = _chatService.watchMessages(roomId);
  }

  Future<void> _setupRoom() async {
    try {
      final String roomId = await _chatService.ensureGlobalCommunityRoom();
      if (!mounted) return;
      setState(() {
        _bindRoom(roomId);
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
    _scrollController.dispose();
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

  Future<void> _sendMessage() async {
    final String? roomId = _roomId;
    if (roomId == null) return;
    final String message = _controller.text.trim();
    if (message.isEmpty || _sending) return;

    final String myId = _chatService.currentUser?.id ?? '';
    final ChatMessageItem optimisticMessage = ChatMessageItem(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      roomId: roomId,
      senderId: myId,
      content: message,
      createdAt: DateTime.now(),
    );

    setState(() {
      _sending = true;
      final List<ChatMessageItem> nextPending = List<ChatMessageItem>.from(
        _pendingMessages,
      )..add(optimisticMessage);
      _pendingMessages = nextPending;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      await _chatService.sendMessage(roomId: roomId, content: message);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingMessages = _pendingMessages
            .where((ChatMessageItem item) => item.id != optimisticMessage.id)
            .toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal kirim chat: $error')));
      return;
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Future<void> _handleComposerAction() async {
    if (_hasText) {
      await _sendMessage();
      return;
    }
    await _openScheduleDialog();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  List<ChatMessageItem> _mergeMessages(List<ChatMessageItem> messages) {
    final List<ChatMessageItem> merged = List<ChatMessageItem>.from(messages);
    final Map<String, int> serverCounts = <String, int>{};

    for (final ChatMessageItem item in messages) {
      final String key = '${item.senderId}|${item.content}';
      serverCounts[key] = (serverCounts[key] ?? 0) + 1;
    }

    final List<ChatMessageItem> stillPending = <ChatMessageItem>[];
    final Map<String, int> consumedServerCounts = <String, int>{};

    for (final ChatMessageItem item in _pendingMessages) {
      final String key = '${item.senderId}|${item.content}';
      final int used = consumedServerCounts[key] ?? 0;
      final int available = serverCounts[key] ?? 0;
      if (used < available) {
        consumedServerCounts[key] = used + 1;
        continue;
      }
      merged.add(item);
      stillPending.add(item);
    }

    _pendingMessages = stillPending;
    merged.sort(
      (ChatMessageItem a, ChatMessageItem b) => a.createdAt.compareTo(b.createdAt),
    );
    return merged;
  }

  Future<void> _openScheduleDialog() async {
    final _OnlineScheduleDraft? draft = await _showOnlineScheduleDialog();
    if (draft == null || _roomId == null) return;

    final ChatMessageItem optimisticMessage = ChatMessageItem(
      id: 'schedule-${DateTime.now().microsecondsSinceEpoch}',
      roomId: _roomId!,
      senderId: _chatService.currentUser?.id ?? '',
      content: _buildOnlineMeetingChatMessage(draft),
      createdAt: DateTime.now(),
    );

    setState(() {
      final List<ChatMessageItem> nextPending = List<ChatMessageItem>.from(
        _pendingMessages,
      )..add(optimisticMessage);
      _pendingMessages = nextPending;
      _sending = true;
    });
    _scrollToBottom();

    try {
      await _chatService.sendMessage(
        roomId: _roomId!,
        content: optimisticMessage.content,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OnlineMeetingPage(
            meetingLink: draft.meetingLink,
            scheduledAt: draft.scheduledAt,
            title: draft.title,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingMessages = _pendingMessages
            .where((ChatMessageItem item) => item.id != optimisticMessage.id)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal kirim jadwal meeting: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Future<_OnlineScheduleDraft?> _showOnlineScheduleDialog() async {
    final TextEditingController titleController = TextEditingController(
      text: widget.roomTitle?.trim().isNotEmpty == true
          ? 'Interview ${widget.roomTitle}'
          : 'Interview Online',
    );
    final TextEditingController linkController = TextEditingController(
      text: 'https://meet.google.com/',
    );
    final TextEditingController timeController = TextEditingController();
    DateTime? scheduledAt;
    bool generatingLink = false;

    final _OnlineScheduleDraft? result = await showDialog<_OnlineScheduleDraft>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            Future<void> pickSchedule() async {
              final DateTime now = DateTime.now();
              final DateTime initialDate = scheduledAt ?? now.add(
                const Duration(days: 1),
              );
              final DateTime? pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: initialDate,
                firstDate: DateTime(now.year, now.month, now.day),
                lastDate: DateTime(now.year + 3),
              );
              if (!dialogContext.mounted || pickedDate == null) return;

              final TimeOfDay initialTime = scheduledAt != null
                  ? TimeOfDay.fromDateTime(scheduledAt!)
                  : const TimeOfDay(hour: 9, minute: 0);
              final TimeOfDay? pickedTime = await showTimePicker(
                context: dialogContext,
                initialTime: initialTime,
              );
              if (pickedTime == null) return;

              scheduledAt = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              setDialogState(() {
                timeController.text = _formatScheduleDateTime(scheduledAt!);
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF13151A),
              title: const Text(
                'Tambah Jadwal Online',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogField(
                      controller: titleController,
                      label: 'Judul Meeting',
                      hintText: 'Contoh: Interview HR',
                    ),
                    const SizedBox(height: 12),
                    _buildDialogField(
                      controller: linkController,
                      label: 'Link Meeting',
                      hintText: 'Tempel link Zoom / Google Meet',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: generatingLink
                            ? null
                            : () async {
                                final String title = titleController.text.trim();
                                if (title.isEmpty) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Isi judul meeting dulu sebelum generate link.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() {
                                  generatingLink = true;
                                });
                                try {
                                  final GoogleMeetCreateResult result =
                                      await _googleMeetService.createMeeting(
                                    title: title,
                                  );
                                  if (!dialogContext.mounted) return;
                                  setDialogState(() {
                                    linkController.text = result.meetingLink;
                                  });
                                } catch (error) {
                                  if (!dialogContext.mounted) return;
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal generate Google Meet: $error',
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (dialogContext.mounted) {
                                    setDialogState(() {
                                      generatingLink = false;
                                    });
                                  }
                                }
                              },
                        child: Text(
                          generatingLink
                              ? 'Generating...'
                              : 'Generate Google Meet',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDialogField(
                      controller: timeController,
                      label: 'Jadwal',
                      hintText: 'Pilih tanggal dan jam',
                      readOnly: true,
                      onTap: pickSchedule,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String title = titleController.text.trim();
                    final String link = linkController.text.trim();
                    if (title.isEmpty || link.isEmpty || scheduledAt == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Judul, link meeting, dan jadwal wajib diisi.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      _OnlineScheduleDraft(
                        title: title,
                        meetingLink: link,
                        scheduledAt: scheduledAt!,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A2D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    linkController.dispose();
    timeController.dispose();
    return result;
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0F1013),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D313B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6A2D)),
            ),
          ),
        ),
      ],
    );
  }

  String _buildOnlineMeetingChatMessage(_OnlineScheduleDraft draft) {
    return '[ONLINE MEETING]\n'
        '${draft.title}\n'
        'Jadwal: ${_formatScheduleDateTime(draft.scheduledAt)}\n'
        'Link: ${draft.meetingLink}\n'
        'Klik link di atas untuk join meeting.';
  }

  String _formatScheduleDateTime(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
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
            Expanded(
              child: Padding(
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
                          widget.isGroupRoom
                              ? const CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Color(0xFFE5E7EB),
                                  child: Icon(
                                    Icons.groups_2_outlined,
                                    color: Color(0xFF121417),
                                    size: 18,
                                  ),
                                )
                              : StoryRingProfileAvatar(
                                  label: title,
                                  viewed: true,
                                  hasStory: false,
                                  size: 34,
                                  imageUrl: _avatarUrl,
                                ),
                          const SizedBox(width: 8),
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
                      Expanded(
                        child: _roomId == null || _messageStream == null
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
                                stream: _messageStream!,
                                initialData: _cachedMessages,
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<List<ChatMessageItem>> snapshot,
                                ) {
                                  final List<ChatMessageItem> messages =
                                      _mergeMessages(
                                        snapshot.data ?? <ChatMessageItem>[],
                                      );
                                  _cachedMessages = messages;
                                  _scrollToBottom();
                                  final String myId =
                                      _chatService.currentUser?.id ?? '';
                                  return ListView.builder(
                                    controller: _scrollController,
                                    padding: EdgeInsets.zero,
                                    itemCount: messages.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final ChatMessageItem message =
                                          messages[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
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
                        textInputAction: TextInputAction.send,
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
                    onTap:
                        (_roomId != null && !_sending)
                            ? _handleComposerAction
                            : null,
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
    final _MeetingMessageData? meeting = _parseMeetingMessage(label);
    if (meeting != null) {
      return _meetingBubble(alignRight: alignRight, meeting: meeting);
    }

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

  Widget _meetingBubble({
    required bool alignRight,
    required _MeetingMessageData meeting,
  }) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: alignRight ? const Color(0xFFFF6A2D) : const Color(0xFF0E1014),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: alignRight
                ? const Color(0xFFFF6A2D)
                : const Color(0xFF2D313B),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ONLINE MEETING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meeting.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Jadwal: ${meeting.scheduleLabel}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              meeting.meetingLink,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFF1E7),
                fontSize: 11,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OnlineMeetingPage(
                        meetingLink: meeting.meetingLink,
                        scheduledAt: meeting.scheduledAt,
                        title: meeting.title,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Join Meeting',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MeetingMessageData? _parseMeetingMessage(String message) {
    if (!message.startsWith('[ONLINE MEETING]')) return null;

    final List<String> lines = message
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    if (lines.length < 4) return null;

    final String title = lines.length > 1 ? lines[1] : 'Meeting Online';
    final String scheduleLine = lines.firstWhere(
      (String line) => line.startsWith('Jadwal:'),
      orElse: () => '',
    );
    final String linkLine = lines.firstWhere(
      (String line) => line.startsWith('Link:'),
      orElse: () => '',
    );

    final String scheduleLabel = scheduleLine.replaceFirst('Jadwal:', '').trim();
    final String meetingLink = linkLine.replaceFirst('Link:', '').trim();
    if (meetingLink.isEmpty) return null;

    return _MeetingMessageData(
      title: title,
      meetingLink: meetingLink,
      scheduleLabel: scheduleLabel.isEmpty ? '-' : scheduleLabel,
      scheduledAt: _tryParseSchedule(scheduleLabel),
    );
  }

  DateTime? _tryParseSchedule(String value) {
    final RegExp match = RegExp(
      r'^(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})$',
    );
    final Match? found = match.firstMatch(value);
    if (found == null) return null;
    return DateTime(
      int.parse(found.group(3)!),
      int.parse(found.group(2)!),
      int.parse(found.group(1)!),
      int.parse(found.group(4)!),
      int.parse(found.group(5)!),
    );
  }
}

class _OnlineScheduleDraft {
  const _OnlineScheduleDraft({
    required this.title,
    required this.meetingLink,
    required this.scheduledAt,
  });

  final String title;
  final String meetingLink;
  final DateTime scheduledAt;
}

class _MeetingMessageData {
  const _MeetingMessageData({
    required this.title,
    required this.meetingLink,
    required this.scheduleLabel,
    required this.scheduledAt,
  });

  final String title;
  final String meetingLink;
  final String scheduleLabel;
  final DateTime? scheduledAt;
}
