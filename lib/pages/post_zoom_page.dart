import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_post.dart';
import 'create_post_page.dart';

class PostZoomPage extends StatefulWidget {
  const PostZoomPage({super.key, this.post});

  final PostItem? post;

  @override
  State<PostZoomPage> createState() => _PostZoomPageState();
}

class _PostZoomPageState extends State<PostZoomPage> {
  @override
  Widget build(BuildContext context) {
    final PostItem? zoomPost = widget.post;
    return Scaffold(
      body: SafeArea(
        child: zoomPost == null
            ? const Center(
                child: Text(
                  'Post tidak ditemukan.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                children: [
                  FeedPost(post: zoomPost),
                ],
              ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.profile,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () => AppRoutes.goApply(context),
        onCreateTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CreatePostPage()),
        ),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}
