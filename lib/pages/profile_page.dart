import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/story_ring_avatar.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'post_zoom_page.dart';
import 'profile_dashboard_page.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double tileWidth = (width - 16) / 3;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRingAvatar(),
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
  const _ProfileRingAvatar();

  @override
  Widget build(BuildContext context) => const StoryRingAvatar(size: 84);
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
