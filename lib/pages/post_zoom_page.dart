import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/pop_icon_button.dart';
import '../widgets/story_ring_avatar.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class PostZoomPage extends StatelessWidget {
  const PostZoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          children: [
            const Text(
              'Zoom In- Postingan',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ZoomAvatar(),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TiffanyPhylicia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TopStat(label: 'Postingan', value: '68'),
                          _TopStat(label: 'Pengikuti', value: '9.8K'),
                          _TopStat(label: 'Mengikuti', value: '201'),
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
                    'Lorem Ipsum dolor sim Amet... deskripsi postingan di mode zoom ini bisa dibuka tutup seperti caption.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              color: const Color(0xFF13151A),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFFF2B2B),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TiffanyPhylicia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'never-Alan Walker',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.more_vert, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: const Color(0xFFCFCFCF),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 56,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(active: true),
                      SizedBox(width: 4),
                      _Dot(),
                      SizedBox(width: 4),
                      _Dot(),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Row(
                      children: [
                        PopIconButton(
                          icon: Icons.favorite_border,
                          activeIcon: Icons.favorite,
                          color: Colors.white,
                          activeColor: Color(0xFFFF3B30),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        PopIconButton(
                          icon: Icons.mode_comment_outlined,
                          activeIcon: Icons.mode_comment,
                          color: Colors.white,
                          activeColor: Color(0xFF7DD3FC),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        PopIconButton(
                          icon: Icons.send_outlined,
                          activeIcon: Icons.send,
                          color: Colors.white,
                          activeColor: Color(0xFF93C5FD),
                          size: 18,
                        ),
                        Spacer(),
                        PopIconButton(
                          icon: Icons.bookmark_border,
                          activeIcon: Icons.bookmark,
                          color: Colors.white,
                          activeColor: Color(0xFFF4A640),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TiffanyPhylicia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        ExpandableText(
                          text:
                              'Lorem ipsum dolor sim amet... caption ini bisa diperluas dan dipendekkan seperti caption postingan pada umumnya.',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 9,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.profile,
        onHomeTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
        ),
        onApplyTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ApplyPage())),
        onCreateTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage())),
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

class _TopStat extends StatelessWidget {
  const _TopStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10)),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ZoomAvatar extends StatelessWidget {
  const _ZoomAvatar();

  @override
  Widget build(BuildContext context) => const StoryRingAvatar(size: 72);
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : const Color(0xFFB7B7B7),
      ),
    );
  }
}
