import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_item.dart';
import '../models/post_streak.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'job_apply_page.dart';
import 'notifications_page.dart';
import 'post_zoom_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final PostService _postService = PostService();
  List<PostItem> _allPosts = <PostItem>[];
  Map<String, int> _authorStreaks = <String, int>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    _loadSearchData();
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadSearchData() async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      AppRoutes.goLogin(context);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final List<PostItem> posts = await _postService.fetchFeed();
      if (!mounted) return;
      setState(() {
        _allPosts = posts;
        _authorStreaks = PostStreak.buildByAuthor(posts);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<PostItem> get _filteredPosts {
    final String query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return _allPosts;

    return _allPosts.where((PostItem post) {
      final List<String> searchableFields = <String>[
        post.name,
        post.role,
        post.content,
        post.jobTitle ?? '',
        post.jobLocation ?? '',
        post.jobDomicile ?? '',
        post.jobRequirements ?? '',
        _typeLabel(post),
      ];
      return searchableFields.any(
        (String field) => field.toLowerCase().contains(query),
      );
    }).toList();
  }

  String _typeLabel(PostItem post) {
    switch (post.type) {
      case PostType.job:
        return 'loker';
      case PostType.short:
        return 'short';
      case PostType.insight:
        return 'postingan';
    }
  }

  void _openCreate(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage()));
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }

  String _postSubtitle(PostItem post) {
    final String content = post.content.trim();
    if (content.isNotEmpty) {
      return '${post.role} - $content';
    }
    return post.role;
  }

  String _jobSubtitle(PostItem post) {
    final List<String> parts = <String>[
      post.name,
      if ((post.jobLocation ?? '').trim().isNotEmpty) post.jobLocation!.trim(),
      if ((post.jobDomicile ?? '').trim().isNotEmpty) post.jobDomicile!.trim(),
    ];
    return parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: _openNotifications,
              onSearchTap: () {},
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
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: const Color(0xFFFF6A2D),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          hintText: 'Cari user, postingan, atau loker',
                          hintStyle: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0E1014),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF2D313B)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFFF6A2D)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_loading)
                        const Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else if (_filteredPosts.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Belum ada hasil untuk pencarian ini.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: _filteredPosts.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 8),
                            itemBuilder: (BuildContext context, int index) {
                              final PostItem post = _filteredPosts[index];
                              return _SearchTile(
                                title: post.type == PostType.job
                                    ? (post.jobTitle?.trim().isNotEmpty == true
                                          ? post.jobTitle!
                                          : post.content)
                                    : post.name,
                                subtitle: post.type == PostType.job
                                    ? _jobSubtitle(post)
                                    : _postSubtitle(post),
                                badge: _typeLabel(post),
                                avatarUrl: post.avatarUrl,
                                label: post.name,
                                streakDays: _authorStreaks[post.authorId],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => post.type == PostType.job
                                          ? JobApplyPage(post: post)
                                          : PostZoomPage(post: post),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.home,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () => AppRoutes.goApply(context),
        onCreateTap: () => _openCreate(context),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.avatarUrl,
    required this.label,
    required this.streakDays,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String? avatarUrl;
  final String label;
  final int? streakDays;
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
              size: 32,
              viewed: false,
              hasStory: false,
              label: label,
              imageUrl: avatarUrl,
            ),
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
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    subtitle,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C22),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF2D313B)),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
