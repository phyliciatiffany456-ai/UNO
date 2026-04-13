import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_post.dart';
import 'create_post_page.dart';

class ProfileVideoFeedPage extends StatefulWidget {
  const ProfileVideoFeedPage({
    super.key,
    required this.posts,
    this.initialIndex = 0,
  });

  final List<PostItem> posts;
  final int initialIndex;

  @override
  State<ProfileVideoFeedPage> createState() => _ProfileVideoFeedPageState();
}

class _ProfileVideoFeedPageState extends State<ProfileVideoFeedPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
      body: SafeArea(
        child: widget.posts.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada video di profil ini.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    children: [
                      FeedPost(post: widget.posts[index]),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.profile,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () => AppRoutes.goApply(context),
        onCreateTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage())),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}
