import 'package:flutter/material.dart';

import '../models/notification_store.dart';
import '../models/post_item.dart';
import '../models/post_streak.dart';
import '../models/story_item.dart';
import '../models/story_seen_store.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../services/social_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'chat_profile_info_page.dart';
import 'create_post_page.dart';
import 'post_zoom_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();

  List<PostItem> _notificationPosts = <PostItem>[];
  Map<String, int> _authorStreaks = <String, int>{};
  Set<String> _activeStoryAuthors = <String>{};
  Map<String, List<String>> _activeStoryIdsByAuthor = <String, List<String>>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationStore.markRead();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
    });

    try {
      final List<PostItem> posts = await _postService.fetchFeed();
      final String? currentUserId = _socialService.currentUser?.id;
      final Map<String, DateTime> followingSinceByAuthor = await _socialService
          .getFollowingSinceMap(userId: currentUserId);
      final DateTime storyThreshold = DateTime.now().subtract(
        const Duration(days: 1),
      );
      final List<PostItem> notificationPosts = posts.where((PostItem post) {
        if (post.authorId == currentUserId) return false;
        final DateTime? followedAt = followingSinceByAuthor[post.authorId];
        final DateTime? createdAt = post.createdAt;
        if (followedAt == null || createdAt == null) return false;
        return !createdAt.isBefore(followedAt);
      }).toList();
      final Map<String, int> authorStreaks = PostStreak.buildByAuthor(posts);
      final Set<String> activeStoryAuthors = posts
          .where(
            (PostItem post) =>
                post.type == PostType.short &&
                post.createdAt != null &&
                post.createdAt!.isAfter(storyThreshold) &&
                followingSinceByAuthor.containsKey(post.authorId),
          )
          .map((PostItem post) => post.authorId)
          .toSet();
      final Map<String, List<String>> activeStoryIdsByAuthor =
          <String, List<String>>{};
      for (final PostItem post in posts.where(
        (PostItem post) =>
            post.type == PostType.short &&
            post.createdAt != null &&
            post.createdAt!.isAfter(storyThreshold) &&
            followingSinceByAuthor.containsKey(post.authorId),
      )) {
        activeStoryIdsByAuthor.putIfAbsent(post.authorId, () => <String>[]).add(
          post.id,
        );
      }
      if (!mounted) return;
      setState(() {
        _notificationPosts = notificationPosts.take(30).toList();
        _authorStreaks = authorStreaks;
        _activeStoryAuthors = activeStoryAuthors;
        _activeStoryIdsByAuthor = activeStoryIdsByAuthor;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat notifikasi dari database.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openStory(PostItem post) async {
    if (!_activeStoryAuthors.contains(post.authorId)) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          story: StoryItem(
            label: post.name,
            authorId: post.authorId,
            avatarUrl: post.avatarUrl,
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  void _openSearch(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage()));
  }

  void _openCreate(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage()));
  }

  String _notificationText(PostItem post) {
    switch (post.type) {
      case PostType.job:
        return 'Membuka lowongan baru: ${post.content}';
      case PostType.short:
        return 'Mengunggah short baru';
      case PostType.insight:
        return 'Membuat postingan baru';
    }
  }

  int? _streakFromPost(PostItem post) {
    return _authorStreaks[post.authorId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: () {},
              onSearchTap: () => _openSearch(context),
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Notifikasi Terbaru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _notificationPosts.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada notifikasi.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadNotifications,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: _notificationPosts.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(height: 8),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final PostItem post =
                                            _notificationPosts[index];
                                        final bool hasStory =
                                            _activeStoryAuthors.contains(
                                              post.authorId,
                                            );
                                        return _NotificationTile(
                                          hasStory: hasStory,
                                          username: post.name,
                                          text: _notificationText(post),
                                          streakDays: _streakFromPost(post),
                                          viewedStory:
                                              hasStory &&
                                              StorySeenStore.hasSeenAllStoryIds(
                                                _activeStoryIdsByAuthor[post.authorId] ??
                                                    const <String>[],
                                              ),
                                          onAvatarTap: hasStory
                                              ? () => _openStory(post)
                                              : null,
                                          avatarUrl: post.avatarUrl,
                                          onNameTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    ChatProfileInfoPage(
                                                      name: post.name,
                                                      userId: post.authorId,
                                                      role: post.role,
                                                      bio: post.content,
                                                    ),
                                              ),
                                            );
                                          },
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    PostZoomPage(post: post),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.apply,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () {},
        onCreateTap: () => _openCreate(context),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.hasStory,
    required this.username,
    required this.text,
    required this.streakDays,
    required this.viewedStory,
    required this.onAvatarTap,
    this.avatarUrl,
    required this.onNameTap,
    required this.onTap,
  });

  final bool hasStory;
  final String username;
  final String text;
  final int? streakDays;
  final bool viewedStory;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;
  final VoidCallback onNameTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1014),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D313B)),
        ),
        child: Row(
          children: [
            StoryRingProfileAvatar(
              size: 34,
              hasStory: hasStory,
              viewed: viewedStory,
              label: username,
              imageUrl: avatarUrl,
              onTap: onAvatarTap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: onNameTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: streakDays != null
                      ? const Color(0xFFFFA84D)
                      : const Color(0xFF6B7280),
                  size: 18,
                ),
                Text(
                  streakDays?.toString() ?? '-',
                  style: TextStyle(
                    color: streakDays != null
                        ? const Color(0xFFFFB27D)
                        : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
