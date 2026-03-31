import 'package:flutter/material.dart';

import '../models/notification_store.dart';
import '../navigation/app_routes.dart';
import '../models/story_item.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    NotificationStore.markRead();
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const StoryViewerPage(
                              story: StoryItem(label: 'TiffanyPhylicia'),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _NotificationTile(
                      username: 'NexaTech Careers',
                      text: 'Membuka lowongan baru untuk Flutter Engineer',
                      streakDays: 2,
                      onTap: () {},
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
    required this.onTap,
  });

  final String username;
  final String text;
  final int streakDays;
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
