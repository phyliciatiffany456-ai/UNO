import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/profile_store.dart';
import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_post.dart';
import 'create_post_page.dart';

class PostZoomPage extends StatefulWidget {
  const PostZoomPage({super.key});

  @override
  State<PostZoomPage> createState() => _PostZoomPageState();
}

class _PostZoomPageState extends State<PostZoomPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileData>(
      valueListenable: ProfileStore.data,
      builder: (BuildContext context, ProfileData profile, Widget? child) {
        final PostItem zoomPost = PostItem(
          id: 'zoom-preview',
          authorId: 'local-preview',
          name: profile.name,
          role: profile.workExperience,
          content:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus luctus semper lacus, at aliquet neque pharetra sed. Cras sollicitudin at nibh non varius.',
          type: PostType.insight,
          imageUrls: const <String>[
            'https://images.unsplash.com/photo-1498050108023-c5249f4df085',
            'https://images.unsplash.com/photo-1551281044-8b1f5f0c5f22',
            'https://images.unsplash.com/photo-1515879218367-8466d910aaa4',
          ],
          canApply: false,
          isFollowed: true,
          hasStory: true,
        );

        return Scaffold(
          body: SafeArea(
            child: ListView(
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
      },
    );
  }
}
