import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../models/post_item.dart';
import '../models/story_item.dart';
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

  static const List<PostItem> posts = <PostItem>[
    PostItem(
      name: 'TiffanyPhylicia',
      role: 'UI/UX Designer',
      content:
          'Insight: Portofolio yang kuat bukan cuma visual bagus, tapi proses problem solving yang jelas.',
      type: PostType.insight,
      imageCount: 3,
    ),
    PostItem(
      name: 'fajar.engineer',
      role: 'Mobile Engineer',
      content:
          'Short: Flutter tip hari ini, pisahkan widget reusable dari awal supaya scaling lebih gampang.',
      type: PostType.short,
      isFollowed: false,
    ),
    PostItem(
      name: 'NexaTech Careers',
      role: 'Hiring Team',
      content:
          'Loker: Flutter Developer (Remote). Butuh pengalaman state management dan integrasi API.',
      type: PostType.job,
      imageCount: 1,
      canApply: true,
      isFollowed: false,
    ),
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<StoryItem> stories;

  @override
  void initState() {
    super.initState();
    stories = List<StoryItem>.from(HomePage.initialStories);
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
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return FeedPost(post: HomePage.posts[index]);
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
                itemCount: HomePage.posts.length,
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
