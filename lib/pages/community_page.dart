import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../models/story_seen_store.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../services/social_service.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_post.dart';
import '../widgets/stories.dart';
import '../widgets/top_bar.dart';
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

  List<StoryItem> _stories = <StoryItem>[];
  List<PostItem> _posts = <PostItem>[];
  List<StoryItem> _communityPeople = <StoryItem>[];

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
      final List<StoryItem> stories = _buildStories(posts);
      final List<StoryItem> people = await _buildCommunityPeople(stories);

      if (!mounted) return;
      setState(() {
        _posts = posts;
        _stories = stories;
        _communityPeople = people;
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

  List<StoryItem> _buildStories(List<PostItem> posts) {
    final Set<String> seen = <String>{};
    final List<StoryItem> result = <StoryItem>[];
    final DateTime threshold = DateTime.now().subtract(const Duration(days: 1));
    for (final PostItem post in posts) {
      if (post.type != PostType.short) continue;
      final DateTime? createdAt = post.createdAt;
      if (createdAt == null || createdAt.isBefore(threshold)) continue;
      if (seen.contains(post.authorId)) continue;
      seen.add(post.authorId);
      result.add(
        StoryItem(
          label: post.name,
          authorId: post.authorId,
          isViewed: StorySeenStore.isSeen(
            authorId: post.authorId,
            label: post.name,
          ),
        ),
      );
    }
    return result;
  }

  Future<List<StoryItem>> _buildCommunityPeople(List<StoryItem> stories) async {
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
                      : _buildCommunityFeed(),
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
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChatProfileInfoPage(
                      name: label,
                      userId: person.authorId,
                    ),
                  ),
                ),
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

  Widget _buildCommunityFeed() {
    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada postingan komunitas.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommunity,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 10),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          return FeedPost(post: _posts[index]);
        },
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
