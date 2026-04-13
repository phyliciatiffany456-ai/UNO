import 'package:flutter/material.dart';

import '../models/notification_store.dart';
import '../models/post_item.dart';
import '../models/story_item.dart';
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
  final Set<String> _viewedStories = <String>{};

  List<PostItem> _notificationPosts = <PostItem>[];
  Map<String, int> _authorPostCounts = <String, int>{};
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
      final List<PostItem> notificationPosts = posts
          .where((PostItem post) => post.authorId != currentUserId)
          .toList();
      final Map<String, int> authorPostCounts = <String, int>{};
      for (final PostItem post in notificationPosts) {
        authorPostCounts[post.authorId] =
            (authorPostCounts[post.authorId] ?? 0) + 1;
      }
      if (!mounted) return;
      setState(() {
        _notificationPosts = notificationPosts.take(30).toList();
        _authorPostCounts = authorPostCounts;
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(story: StoryItem(label: post.name)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedStories.add(post.authorId);
    });
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

  int _streakFromPost(PostItem post) {
    return _authorPostCounts[post.authorId] ?? 0;
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
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: _notificationPosts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (BuildContext context, int index) {
                                    final PostItem post = _notificationPosts[index];
                                    return _NotificationTile(
                                      username: post.name,
                                      text: _notificationText(post),
                                      streakDays: _streakFromPost(post),
                                      viewedStory: _viewedStories.contains(
                                        post.authorId,
                                      ),
                                      onAvatarTap: () => _openStory(post),
                                      onNameTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => ChatProfileInfoPage(
                                              name: post.name,
                                              role: post.role,
                                              bio: post.content,
                                            ),
                                          ),
                                        );
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => PostZoomPage(post: post),
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
    required this.username,
    required this.text,
    required this.streakDays,
    required this.viewedStory,
    required this.onAvatarTap,
    required this.onNameTap,
    required this.onTap,
  });

  final String username;
  final String text;
  final int streakDays;
  final bool viewedStory;
  final VoidCallback onAvatarTap;
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
              viewed: viewedStory,
              label: username,
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
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFFA84D),
                  size: 18,
                ),
                Text(
                  '$streakDays',
                  style: const TextStyle(
                    color: Color(0xFFFFB27D),
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
