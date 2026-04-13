import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/saved_post_store.dart';
import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feed_post.dart';
import 'create_post_page.dart';

class SavedPostsPage extends StatelessWidget {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save'),
        backgroundColor: const Color(0xFF0F1013),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<PostItem>>(
          valueListenable: SavedPostStore.savedPosts,
          builder: (
            BuildContext context,
            List<PostItem> savedPosts,
            Widget? child,
          ) {
            if (savedPosts.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada post yang disimpan.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              itemCount: savedPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final PostItem post = savedPosts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF13151A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF24262E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FeedPost(
                        post: post,
                        openSavedPageOnSave: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: TextButton.icon(
                          onPressed: () {
                            SavedPostStore.remove(post.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post dihapus dari Save.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.undo_rounded,
                            color: Color(0xFFF4A640),
                            size: 18,
                          ),
                          label: const Text(
                            'Undo Save',
                            style: TextStyle(
                              color: Color(0xFFF4A640),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.home,
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
