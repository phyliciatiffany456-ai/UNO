import 'package:flutter/material.dart';

import '../models/story_item.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/pop_icon_button.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 12, 0),
              child: Row(
                children: [
                  const _BluePulseBell(),
                  const Spacer(),
                  const Text(
                    'uno',
                    style: TextStyle(
                      color: Color(0xFFFF6A2D),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  PopIconButton(
                    icon: Icons.search,
                    color: Colors.white,
                    size: 22,
                    toggle: false,
                    onTap: (_) => _openSearch(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _NotificationTile(
              username: 'TiffanyPhylicia',
              text: 'Lorem Ipsum dolor sim amet...',
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
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.apply,
        onHomeTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
        ),
        onApplyTap: () {},
        onCreateTap: () => _openCreate(context),
        onCommunityTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CommunityPage())),
        onProfileTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
      ),
    );
  }
}

class _BluePulseBell extends StatefulWidget {
  const _BluePulseBell();

  @override
  State<_BluePulseBell> createState() => _BluePulseBellState();
}

class _BluePulseBellState extends State<_BluePulseBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        return Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 19),
              Positioned(
                right: -1,
                top: 0,
                child: Container(
                  width: 7 + (t * 3),
                  height: 7 + (t * 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF42A5F5,
                    ).withValues(alpha: 0.8 - (0.45 * t)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF42A5F5,
                        ).withValues(alpha: 0.7 - (0.45 * t)),
                        blurRadius: 8 + (6 * t),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4B4B), Color(0xFFFF2B2B)],
                ),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 11,
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
                    '$username *',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 9,
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
                  size: 16,
                ),
                Text(
                  '$streakDays',
                  style: const TextStyle(
                    color: Color(0xFFFFB27D),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
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
