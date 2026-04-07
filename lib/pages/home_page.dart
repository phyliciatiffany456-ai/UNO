import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_store.dart';
import '../models/story_seen_store.dart';
import '../navigation/app_routes.dart';
import '../models/post_item.dart';
import '../models/story_item.dart';
import '../services/post_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_post.dart';
import '../widgets/stories.dart';
import '../widgets/top_bar.dart';
import 'notifications_page.dart';
import 'create_post_page.dart';
import 'create_short_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostService _postService = PostService();
  List<StoryItem> stories = <StoryItem>[];
  List<PostItem> _posts = <PostItem>[];
  bool _loadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _openStory(int index) async {
    if (index < 0 || index >= stories.length) return;
    final StoryItem story = stories[index];
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StoryViewerPage(story: story)),
    );
    StorySeenStore.markSeen(authorId: story.authorId, label: story.label);
    if (!mounted) return;
    setState(() {
      stories[index] = story.copyWith(isViewed: true);
    });
  }

  void _openCreatePage() {
    Navigator.of(
      context,
    )
        .push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage()))
        .then((_) => _loadFeed());
  }

  void _openCreateShortPage() {
    Navigator.of(
      context,
    )
        .push(MaterialPageRoute<void>(builder: (_) => const CreateShortPage()))
        .then((_) => _loadFeed());
  }

  void _openNotificationsPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }

  void _openSearchPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage()));
  }

  Future<void> _loadFeed() async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppRoutes.goLogin(context);
      });
      return;
    }

    setState(() {
      _loadingPosts = true;
    });

    try {
      final List<PostItem> posts = await _postService.fetchFeed();
      if (!mounted) return;
      final DateTime? latestPostAt = posts.isNotEmpty ? posts.first.createdAt : null;
      final String? latestAuthorId = posts.isNotEmpty ? posts.first.authorId : null;
      NotificationStore.syncWithLatestPost(
        latestPostAt,
        latestAuthorId: latestAuthorId,
        currentUserId: user.id,
      );
      setState(() {
        _posts = posts;
        stories = _buildStories(posts, user.id);
      });
    } catch (_) {
      _showMessage('Gagal memuat feed dari database.');
    } finally {
      if (mounted) {
        setState(() {
          _loadingPosts = false;
        });
      }
    }
  }

  List<StoryItem> _buildStories(List<PostItem> posts, String currentUserId) {
    final Set<String> seenAuthorIds = <String>{};
    final List<StoryItem> result = <StoryItem>[];
    final DateTime threshold = DateTime.now().subtract(const Duration(days: 1));

    for (final PostItem post in posts) {
      if (post.type != PostType.short) continue;
      final DateTime? createdAt = post.createdAt;
      if (createdAt == null || createdAt.isBefore(threshold)) continue;
      if (seenAuthorIds.contains(post.authorId)) continue;
      seenAuthorIds.add(post.authorId);
      result.add(
        StoryItem(
          label: post.name,
          authorId: post.authorId,
          isMine: post.authorId == currentUserId,
          isViewed: StorySeenStore.isSeen(
            authorId: post.authorId,
            label: post.name,
          ),
        ),
      );
    }

    return result;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: _openNotificationsPage,
              onSearchTap: _openSearchPage,
            ),
            const SizedBox(height: 10),
            if (stories.isNotEmpty) ...<Widget>[
              Stories(
                stories: stories,
                onStoryTap: _openStory,
                onMineAddTap: _openCreateShortPage,
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: _loadingPosts
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada postingan.\nYuk jadi yang pertama posting.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFeed,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return FeedPost(post: _posts[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 10),
                        itemCount: _posts.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.home,
        onCreateTap: _openCreatePage,
        onApplyTap: () => AppRoutes.goApply(context),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}
