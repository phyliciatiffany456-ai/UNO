import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/story_ring_avatar.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EditAvatar(),
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
                          _MiniStat(label: 'Postingan', value: '68'),
                          _MiniStat(label: 'Pengikuti', value: '9.8K'),
                          _MiniStat(label: 'Mengikuti', value: '201'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const ExpandableText(
              text:
                  'Lorem Ipsum dolor sim Amet... deskripsi singkat akun ini bisa diperluas agar user bisa baca versi panjangnya.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            const _EditField(title: 'Nama', value: 'TiffanyPhylicia'),
            const SizedBox(height: 6),
            const _EditField(title: 'Kata Ganti', value: 'Ms.'),
            const SizedBox(height: 6),
            const _EditField(title: 'Bio', value: 'Lorem Ipsum Dolor Sim Amet'),
            const SizedBox(height: 6),
            const _EditField(title: 'Jenis Kelamin', value: 'Perempuan'),
            const SizedBox(height: 6),
            const _EditField(
              title: 'Pendidikan',
              value: 'Universitas Pelita Harapan',
            ),
            const SizedBox(height: 6),
            const _EditField(title: 'Pengalaman Kerja', value: 'Sivetsi'),
            const SizedBox(height: 10),
            _menuAction('Curriculum Vitae', icon: Icons.file_upload_outlined),
            const SizedBox(height: 6),
            _menuAction('LogOut', icon: Icons.chevron_right),
            const SizedBox(height: 6),
            _menuAction('Ganti Akun', icon: Icons.chevron_right),
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

  Widget _menuAction(String label, {required IconData icon}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF6A2D)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            Icon(icon, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

class _EditAvatar extends StatelessWidget {
  const _EditAvatar();

  @override
  Widget build(BuildContext context) => const StoryRingAvatar(size: 74);
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

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

class _EditField extends StatelessWidget {
  const _EditField({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6A2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
