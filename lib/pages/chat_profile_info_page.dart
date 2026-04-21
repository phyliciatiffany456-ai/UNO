import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../models/story_seen_store.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../services/chat_service.dart';
import '../services/social_service.dart';
import '../widgets/app_button.dart';
import '../widgets/expandable_text.dart';
import '../widgets/profile_ring_avatar.dart';
import 'chat_box_page.dart';
import 'post_zoom_page.dart';
import 'story_viewer_page.dart';

class ChatProfileInfoPage extends StatefulWidget {
  const ChatProfileInfoPage({
    super.key,
    required this.name,
    this.userId,
    this.role = 'Member',
    this.bio = 'Belum ada bio.',
  });

  final String name;
  final String? userId;
  final String role;
  final String bio;

  @override
  State<ChatProfileInfoPage> createState() => _ChatProfileInfoPageState();
}

class _ChatProfileInfoPageState extends State<ChatProfileInfoPage> {
  final ProfileService _profileService = ProfileService();
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();
  final ChatService _chatService = ChatService();

  bool _viewedStory = false;
  bool _following = false;
  bool _loading = true;

  String _name = '';
  String _role = '';
  String _bio = '';
  String? _avatarUrl;
  int _followerCount = 0;
  int _followingCount = 0;
  bool _hasStory = false;
  List<PostItem> _posts = <PostItem>[];

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _role = widget.role;
    _bio = widget.bio;
    _load();
  }

  Future<void> _load() async {
    final String? targetUserId = widget.userId;
    if (targetUserId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final ProfileRecord? profile = await _profileService.fetchProfileByUserId(
        targetUserId,
      );
      final List<PostItem> feed = await _postService.fetchFeed();
      final List<PostItem> posts = feed
          .where((PostItem p) => p.authorId == targetUserId)
          .toList();
      final Map<String, int> followStats = await _socialService.getFollowStats(
        targetUserId,
      );
      final Set<String> myFollowing = await _socialService.getFollowingIds();
      final DateTime threshold = DateTime.now().subtract(
        const Duration(days: 1),
      );

      if (!mounted) return;
      setState(() {
        if (profile != null) {
          _name = profile.fullName;
          _role = profile.role;
          _bio = profile.bio;
          _avatarUrl = profile.avatarUrl;
        }
        _posts = posts;
        _followerCount = followStats['followers'] ?? 0;
        _followingCount = followStats['following'] ?? 0;
        _following = myFollowing.contains(targetUserId);
        _hasStory = posts.any(
          (PostItem p) =>
              p.type == PostType.short &&
              p.createdAt != null &&
              p.createdAt!.isAfter(threshold),
        );
        _viewedStory = StorySeenStore.isSeen(
          authorId: targetUserId,
          label: _name,
        );
      });
    } catch (_) {
      // keep fallback UI
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openStory() async {
    final String? userId = widget.userId;
    if (!_hasStory || userId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          story: StoryItem(
            label: _name,
            authorId: userId,
            avatarUrl: _avatarUrl,
          ),
        ),
      ),
    );
    StorySeenStore.markSeen(authorId: userId, label: _name);
    if (!mounted) return;
    setState(() {
      _viewedStory = true;
    });
  }

  Future<void> _toggleFollow() async {
    final String? targetUserId = widget.userId;
    if (targetUserId == null) return;
    final String? myUserId = _socialService.currentUser?.id;
    if (myUserId == targetUserId) return;
    final bool next = !_following;
    setState(() {
      _following = next;
      _followerCount += next ? 1 : -1;
      if (_followerCount < 0) _followerCount = 0;
    });
    try {
      if (next) {
        await _socialService.followUser(targetUserId);
      } else {
        await _socialService.unfollowUser(targetUserId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _following = !next;
        _followerCount += next ? -1 : 1;
        if (_followerCount < 0) _followerCount = 0;
      });
    }
  }

  Future<void> _openDirectChat() async {
    final String? targetUserId = widget.userId;
    if (targetUserId == null) return;
    try {
      final String roomId = await _chatService.ensureDirectRoomWithUser(
        otherUserId: targetUserId,
        otherUserName: _name,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatBoxPage(
            initialRoomId: roomId,
            roomTitle: _name,
            isGroupRoom: false,
            otherUserId: targetUserId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka chat: $error')));
    }
  }

  Future<void> _openShareSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bagikan Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _ShareTile(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp',
                  subtitle: 'Kirim profil ke WhatsApp',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
                _ShareTile(
                  icon: Icons.copy_outlined,
                  title: 'Copy Link',
                  subtitle: 'Salin link profil',
                  onTap: () => Navigator.of(context).pop(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileRingAvatar(
                      label: _name,
                      size: 80,
                      viewed: _viewedStory,
                      hasStory: _hasStory,
                      imageUrl: _avatarUrl,
                      onTap: _hasStory ? _openStory : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _role,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ProfileStat(
                                label: 'Postingan',
                                value: '${_posts.length}',
                              ),
                              _ProfileStat(
                                label: 'Pengikut',
                                value: '$_followerCount',
                              ),
                              _ProfileStat(
                                label: 'Mengikuti',
                                value: '$_followingCount',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpandableText(
                  text: _bio,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_socialService.currentUser?.id != widget.userId)
                      Expanded(
                        child: AppButton(
                          label: _following ? 'Mengikuti' : 'Ikuti',
                          onTap: _toggleFollow,
                          variant: _following
                              ? AppButtonVariant.outline
                              : AppButtonVariant.primary,
                          height: 32,
                          fontSize: 12,
                          borderRadius: 8,
                        ),
                      ),
                    if (_socialService.currentUser?.id != widget.userId)
                      const SizedBox(width: 6),
                    Expanded(
                      child: AppButton(
                        label: 'Chat',
                        onTap: _openDirectChat,
                        variant: AppButtonVariant.outline,
                        height: 32,
                        fontSize: 12,
                        borderRadius: 8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppButton(
                        label: 'Bagikan Profil',
                        onTap: _openShareSheet,
                        variant: AppButtonVariant.outline,
                        height: 32,
                        fontSize: 12,
                        borderRadius: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Postingan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (_posts.isEmpty)
                  const Text(
                    'Belum ada postingan.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  ..._posts.map((PostItem post) => _PostItemCard(post: post)),
              ],
            ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostItemCard extends StatelessWidget {
  const _PostItemCard({required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PostZoomPage(post: post)),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF13151A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF24262E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: post.imageUrls.isNotEmpty
                    ? Image.network(post.imageUrls.first, fit: BoxFit.cover)
                    : const ColoredBox(color: Color(0xFFC8C8C8)),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1013),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D313B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
