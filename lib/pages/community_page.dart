import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../models/story_item.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/stories.dart';
import '../widgets/top_bar.dart';
import 'chat_box_page.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<StoryItem> _stories = const <StoryItem>[
    StoryItem(label: 'Your Story', isMine: true),
    StoryItem(label: 'phylicia.tif'),
    StoryItem(label: 'tiffany456'),
    StoryItem(label: 'tiffany.ph'),
    StoryItem(label: 'pli'),
  ];

  bool _friendMode = true;

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

  Future<void> _openStory(int index) async {
    final StoryItem story = _stories[index];
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StoryViewerPage(story: story)),
    );
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
            Stories(stories: _stories, onStoryTap: _openStory),
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
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ChatBoxPage()),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Row(
                  children: [
                    StoryRingAvatar(size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TiffanyPhylicia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFFA84D),
                      size: 18,
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

  Widget _modeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0x1AFFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFF6A2D)),
        ),
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
    );
  }
}
