import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static const List<StoryItem> initialStories = <StoryItem>[
    StoryItem(label: 'Your Short', isMine: true, isViewed: false),
    StoryItem(label: 'Rani HRD', isViewed: false),
    StoryItem(label: 'Fajar Dev', isViewed: false),
    StoryItem(label: 'Nadia PM', isViewed: false),
    StoryItem(label: 'Arga UX', isViewed: false),
    StoryItem(label: 'Dita Data', isViewed: false),
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostService _postService = PostService();
  late List<StoryItem> stories;
  List<PostItem> _posts = <PostItem>[];
  bool _loadingPosts = true;

  @override
  void initState() {
    super.initState();
    stories = List<StoryItem>.from(HomePage.initialStories);
    _loadFeed();
  }

  Future<void> _openStory(int index) async {
    final StoryItem story = stories[index];
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StoryViewerPage(story: story)),
    );
    if (!mounted || story.isViewed) return;
    setState(() {
      stories[index] = story.copyWith(isViewed: true);
    });
  }

  void _openCreatePage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage()));
  }

  void _openCreateShortPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateShortPage()));
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
      AppRoutes.goLogin(context);
      return;
    }

    setState(() {
      _loadingPosts = true;
    });

    try {
      final List<PostItem> posts = await _postService.fetchFeed();
      if (!mounted) return;
      setState(() {
        _posts = posts;
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
            Stories(
              stories: stories,
              onStoryTap: _openStory,
              onMineAddTap: _openCreateShortPage,
            ),
            const SizedBox(height: 8),
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
