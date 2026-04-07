import 'package:flutter/material.dart';

import '../models/notification_store.dart';
import '../navigation/app_routes.dart';
import '../models/story_item.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'chat_profile_info_page.dart';
import 'create_post_page.dart';
import 'post_zoom_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Set<String> _viewedStories = <String>{};

  @override
  void initState() {
    super.initState();
    NotificationStore.markRead();
  }

  Future<void> _openStory(String label) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(story: StoryItem(label: label)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedStories.add(label);
    });
  }

  void _openSearch(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage()));
  }

  void _openCreate(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: () {},
              onSearchTap: () => _openSearch(context),
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Notifikasi Terbaru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _NotificationTile(
                      username: 'TiffanyPhylicia',
                      text: 'Memberi reaksi ke postinganmu',
                      streakDays: 4,
                      viewedStory: _viewedStories.contains('TiffanyPhylicia'),
                      onAvatarTap: () => _openStory('TiffanyPhylicia'),
                      onNameTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ChatProfileInfoPage(
                              name: 'TiffanyPhylicia',
                              role: 'UI/UX Designer',
                              bio:
                                  'Suka bangun produk digital dan kolaborasi bareng tim lintas divisi.',
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PostZoomPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _NotificationTile(
                      username: 'NexaTech Careers',
                      text: 'Membuka lowongan baru untuk Flutter Engineer',
                      streakDays: 2,
                      viewedStory: _viewedStories.contains('NexaTech Careers'),
                      onAvatarTap: () => _openStory('NexaTech Careers'),
                      onNameTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ChatProfileInfoPage(
                              name: 'NexaTech Careers',
                              role: 'Company',
                              bio:
                                  'Akun resmi rekrutmen NexaTech untuk update lowongan terbaru.',
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PostZoomPage(),
                          ),
                        );
                      },
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
        currentTab: NavTab.apply,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () {},
        onCreateTap: () => _openCreate(context),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.username,
    required this.text,
    required this.streakDays,
    required this.viewedStory,
    required this.onAvatarTap,
    required this.onNameTap,
    required this.onTap,
  });

  final String username;
  final String text;
  final int streakDays;
  final bool viewedStory;
  final VoidCallback onAvatarTap;
  final VoidCallback onNameTap;
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
              size: 34,
              viewed: viewedStory,
              onTap: onAvatarTap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: onNameTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
            Column(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFFA84D),
                  size: 18,
                ),
                Text(
                  '$streakDays',
                  style: const TextStyle(
                    color: Color(0xFFFFB27D),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
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
