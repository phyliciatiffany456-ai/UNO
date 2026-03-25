import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../models/story_item.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/top_bar.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'post_zoom_page.dart';
import 'profile_dashboard_page.dart';
import 'profile_edit_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _viewedProfileStory = false;

  void _openNotifications(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }

  void _openSearch(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double tileWidth = (width - 16) / 3;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: () => _openNotifications(context),
              onSearchTap: () => _openSearch(context),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRingAvatar(
                        label: 'TiffanyPhylicia',
                        viewed: _viewedProfileStory,
                        onTap: () =>
                            _openStory(context, 'TiffanyPhylicia'),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TiffanyPhylicia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _ProfileStat(label: 'Postingan', value: '68'),
                                _ProfileStat(label: 'Pengikuti', value: '9.8K'),
                                _ProfileStat(label: 'Mengikuti', value: '201'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ExpandableText(
                      text:
                          'Lorem Ipsum dolor sim Amet... ini deskripsi profil yang bisa lebih panjang saat dibuka supaya terlihat lengkap seperti bio profil di aplikasi sosial media.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _profileAction(
                        'Dasbor',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileDashboardPage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _profileAction(
                        'Edit Profil',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileEditPage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _profileAction(
                        'Share Profil',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur share profil coming soon'),
                            duration: Duration(seconds: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _TabIcon(
                          icon: Icons.grid_on_rounded,
                          active: true,
                          onTap: () {},
                        ),
                      ),
                      Expanded(
                        child: _TabIcon(
                          icon: Icons.video_collection_outlined,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PostZoomPage(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _TabIcon(icon: Icons.repeat, onTap: () {}),
                      ),
                      Expanded(
                        child: _TabIcon(
                          icon: Icons.groups_2_outlined,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CommunityPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List<Widget>.generate(12, (int index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PostZoomPage(),
                          ),
                        ),
                        child: Container(
                          width: tileWidth,
                          height: tileWidth * 1.2,
                          color: const Color(0xFFC8C8C8),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
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
        onProfileTap: () {},
      ),
    );
  }

  Future<void> _openStory(BuildContext context, String label) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(story: StoryItem(label: label)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedProfileStory = true;
    });
  }

  Widget _profileAction(String label, {required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileRingAvatar extends StatelessWidget {
  const _ProfileRingAvatar({
    required this.label,
    this.size = 84,
    required this.viewed,
    this.onTap,
  });

  final String label;
  final double size;
  final bool viewed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Gradient ringGradient = viewed
        ? const LinearGradient(
            colors: [Color(0xFF6B7280), Color(0xFF6B7280)],
          )
        : const LinearGradient(
            colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final double innerDark = size - 8;
    final double innerLight = size - 16;

    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ringGradient,
        ),
        child: Center(
          child: Container(
            width: innerDark,
            height: innerDark,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0F1013),
            ),
            child: Center(
              child: Container(
                width: innerLight,
                height: innerLight,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE5E7EB),
                ),
                child: Center(
                  child: Text(
                    _initials(label),
                    style: const TextStyle(
                      color: Color(0xFF121417),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String raw) {
    final List<String> words = raw
        .split(' ')
        .where((String word) => word.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    this.active = false,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? Colors.white : const Color(0xFF3A3D46),
              width: 1.2,
            ),
          ),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : const Color(0xFF9CA3AF),
          size: 20,
        ),
      ),
    );
  }
}
