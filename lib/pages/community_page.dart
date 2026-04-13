import 'package:flutter/material.dart';
import '../models/post_item.dart';
import '../models/story_item.dart';
import '../models/story_seen_store.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../services/chat_service.dart';
import '../services/social_service.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/stories.dart';
import '../widgets/top_bar.dart';
import 'chat_box_page.dart';
import 'chat_profile_info_page.dart';
import 'create_post_page.dart';
import 'create_short_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();
  final ChatService _chatService = ChatService();

  List<StoryItem> _stories = <StoryItem>[];
  List<StoryItem> _communityPeople = <StoryItem>[];
  List<ChatRoomItem> _groupRooms = <ChatRoomItem>[];

  bool _friendMode = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    setState(() {
      _loading = true;
    });

    try {
      final List<PostItem> posts = await _postService.fetchFeed();
      final Set<String> followingIds = await _socialService.getFollowingIds();
      final String? currentUserId = _socialService.currentUser?.id;
      final List<StoryItem> stories = _buildStories(
        posts,
        currentUserId: currentUserId,
        followingIds: followingIds,
      );
      final List<StoryItem> people = await _buildCommunityPeople();
      final List<ChatRoomItem> groupRooms = await _chatService.fetchMyGroupRooms();

      if (!mounted) return;
      setState(() {
        _stories = stories;
        _communityPeople = people;
        _groupRooms = groupRooms;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data komunitas.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<StoryItem> _buildStories(
    List<PostItem> posts, {
    required String? currentUserId,
    required Set<String> followingIds,
  }) {
    final DateTime threshold = DateTime.now().subtract(const Duration(days: 1));
    final Map<String, PostItem> latestStoryByAuthor = <String, PostItem>{};

    for (final PostItem post in posts) {
      if (post.type != PostType.short) continue;
      final DateTime? createdAt = post.createdAt;
      if (createdAt == null || createdAt.isBefore(threshold)) continue;
      final bool isMine = currentUserId != null && post.authorId == currentUserId;
      final bool isFollowed = followingIds.contains(post.authorId);
      if (!isMine && !isFollowed) continue;
      latestStoryByAuthor.putIfAbsent(post.authorId, () => post);
    }

    final List<PostItem> orderedStories = latestStoryByAuthor.values.toList()
      ..sort((PostItem a, PostItem b) {
        final bool aMine = currentUserId != null && a.authorId == currentUserId;
        final bool bMine = currentUserId != null && b.authorId == currentUserId;
        if (aMine && !bMine) return -1;
        if (!aMine && bMine) return 1;
        final DateTime aCreatedAt =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bCreatedAt =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bCreatedAt.compareTo(aCreatedAt);
      });

    return orderedStories
        .map(
          (PostItem post) => StoryItem(
            label: post.name,
            authorId: post.authorId,
            isMine: currentUserId != null && post.authorId == currentUserId,
            isViewed: StorySeenStore.isSeen(
              authorId: post.authorId,
              label: post.name,
            ),
          ),
        )
        .toList();
  }

  Future<void> _createGroup() async {
    final TextEditingController nameController = TextEditingController();

    final bool? created = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13151A),
          title: const Text(
            'Buat Grup',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 360,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nama grup',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final String groupName = nameController.text.trim();
                if (groupName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Nama grup wajib diisi.')),
                  );
                  return;
                }
                try {
                  final String roomId = await _chatService.createGroupRoom(
                    name: groupName,
                  );
                  if (!mounted) return;
                  Navigator.of(dialogContext).pop(true);
                  await _loadCommunity();
                  if (!mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatBoxPage(
                        initialRoomId: roomId,
                        roomTitle: groupName,
                        isGroupRoom: true,
                      ),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Gagal membuat grup: $error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A2D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grup berhasil dibuat. Bagikan kode grup ke temanmu.')),
      );
    }
  }

  Future<void> _joinGroupByCode() async {
    final TextEditingController codeController = TextEditingController();
    final bool? joined = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13151A),
          title: const Text(
            'Masuk dengan Kode',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 360,
            child: TextField(
              controller: codeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Masukkan kode grup',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _chatService.joinGroupByCode(codeController.text);
                  if (!mounted) return;
                  Navigator.of(dialogContext).pop(true);
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Gagal masuk grup: $error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A2D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Masuk'),
            ),
          ],
        );
      },
    );

    codeController.dispose();
    if (joined == true) {
      await _loadCommunity();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil masuk ke grup.')),
      );
    }
  }

  Future<List<StoryItem>> _buildCommunityPeople() async {
    final String? myId = _socialService.currentUser?.id;
    if (myId == null) return <StoryItem>[];

    final followed = await _socialService.getFollowing(myId);
    return followed
        .map(
          (user) => StoryItem(
            label: user.name,
            authorId: user.userId,
            isViewed: StorySeenStore.isSeen(
              authorId: user.userId,
              label: user.name,
            ),
          ),
        )
        .toList();
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

  void _openCreateShort() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateShortPage()));
  }

  Future<void> _openStory(int index) async {
    if (index < 0 || index >= _stories.length) return;
    final StoryItem story = _stories[index];
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StoryViewerPage(story: story)),
    );
    StorySeenStore.markSeen(authorId: story.authorId, label: story.label);
    if (!mounted) return;
    setState(() {
      _stories[index] = story.copyWith(isViewed: true);
    });
  }

  Future<void> _openInlineStory(StoryItem person) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(story: person),
      ),
    );
    StorySeenStore.markSeen(authorId: person.authorId, label: person.label);
    if (!mounted) return;
    setState(() {
      _communityPeople = _communityPeople
          .map(
            (StoryItem item) => item.authorId == person.authorId
                ? item.copyWith(isViewed: true)
                : item,
          )
          .toList();
    });
  }

  Future<void> _openDirectChat(StoryItem person) async {
    final String? userId = person.authorId;
    if (userId == null) return;
    try {
      final String roomId = await _chatService.ensureDirectRoomWithUser(
        otherUserId: userId,
        otherUserName: person.label,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatBoxPage(
            initialRoomId: roomId,
            roomTitle: person.label,
            isGroupRoom: false,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka chat: $error')),
      );
    }
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
            const SizedBox(height: 8),
            if (_stories.isNotEmpty)
              Stories(
                stories: _stories,
                onStoryTap: _openStory,
                onMineAddTap: _openCreateShort,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _modeButton(
                      label: 'Teman',
                      selected: _friendMode,
                      onTap: () {
                        setState(() {
                          _friendMode = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _modeButton(
                      label: 'Komunitas',
                      selected: !_friendMode,
                      onTap: () {
                        setState(() {
                          _friendMode = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _friendMode
                      ? _buildPeopleList()
                      : _buildGroupList(),
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
        onCommunityTap: () {},
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }

  Widget _buildPeopleList() {
    if (_communityPeople.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada user yang kamu follow.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final Set<String> activeStoryUserIds = _stories
        .map((StoryItem s) => s.authorId ?? '')
        .where((String id) => id.isNotEmpty)
        .toSet();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      itemCount: _communityPeople.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final StoryItem person = _communityPeople[index];
        final String label = person.label;
        final bool hasStory =
            person.authorId != null && activeStoryUserIds.contains(person.authorId);
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF13151A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF24262E)),
          ),
          child: Row(
            children: [
              _InlineStoryAvatar(
                label: label,
                viewed: StorySeenStore.isSeen(
                  authorId: person.authorId,
                  label: label,
                ),
                hasStory: hasStory,
                onTap: hasStory ? () => _openInlineStory(person) : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatProfileInfoPage(
                        name: label,
                        userId: person.authorId,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _openDirectChat(person),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupList() {
    return RefreshIndicator(
      onRefresh: _loadCommunity,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Tambah Grup',
                  onTap: _createGroup,
                  height: 36,
                  fontSize: 12,
                  borderRadius: 10,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Masuk Kode',
                  onTap: _joinGroupByCode,
                  variant: AppButtonVariant.outline,
                  height: 36,
                  fontSize: 12,
                  borderRadius: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_groupRooms.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Belum ada grup. Buat grup baru atau masuk dengan kode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ..._groupRooms.map((ChatRoomItem room) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13151A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF24262E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE23E6B), Color(0xFFF2A63D)],
                              ),
                            ),
                            child: const Icon(
                              Icons.groups_2_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${room.memberCount} anggota',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kode: ${room.id}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Masuk Grup',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ChatBoxPage(
                                    initialRoomId: room.id,
                                    roomTitle: room.name,
                                    isGroupRoom: true,
                                  ),
                                ),
                              ),
                              height: 34,
                              fontSize: 11,
                              borderRadius: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AppButton(
      label: label,
      onTap: onTap,
      variant: selected ? AppButtonVariant.primary : AppButtonVariant.outline,
      height: 34,
      fontSize: 12,
      borderRadius: 10,
    );
  }
}

class _InlineStoryAvatar extends StatelessWidget {
  const _InlineStoryAvatar({
    required this.label,
    required this.viewed,
    required this.hasStory,
    this.onTap,
  });

  final String label;
  final bool viewed;
  final bool hasStory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Gradient ringGradient = viewed
        ? const LinearGradient(
            colors: [Color(0xFF6B7280), Color(0xFF6B7280)],
          )
        : const LinearGradient(
            colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasStory ? ringGradient : null,
          color: hasStory ? null : const Color(0xFF2D313B),
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0F1013),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE5E7EB),
                ),
                child: Center(
                  child: Text(
                    _initials(label),
                    style: const TextStyle(
                      color: Color(0xFF121417),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String raw) {
    final List<String> words = raw
        .split(' ')
        .where((String word) => word.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
