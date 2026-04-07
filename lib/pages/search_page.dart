import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_item.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
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
      return post.name.toLowerCase().contains(query) ||
          post.role.toLowerCase().contains(query) ||
          post.content.toLowerCase().contains(query);
    }).toList();
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
            Padding(
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
                        hintText: 'Cari user, short, atau loker',
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_filteredPosts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Belum ada hasil untuk pencarian ini.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _filteredPosts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (BuildContext context, int index) {
                            final PostItem post = _filteredPosts[index];
                            return _SearchTile(
                              username: post.name,
                              text: post.role,
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
                  ],
                ),
              ),
            ),
            const Spacer(),
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
    required this.username,
    required this.text,
    required this.onTap,
  });

  final String username;
  final String text;
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
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4B4B), Color(0xFFFF2B2B)],
                ),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFE5E7EB),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
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
            const Icon(
              Icons.local_fire_department,
              color: Color(0xFFFFA84D),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
