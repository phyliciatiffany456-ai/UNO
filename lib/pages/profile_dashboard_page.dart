import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/story_ring_avatar.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class ProfileDashboardPage extends StatelessWidget {
  const ProfileDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileMiniHeaderAvatar(),
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
                          _SmallStat(label: 'Postingan', value: '68'),
                          _SmallStat(label: 'Pengikuti', value: '9.8K'),
                          _SmallStat(label: 'Mengikuti', value: '201'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const ExpandableText(
              text:
                  'Lorem Ipsum dolor sim Amet... ini ringkasan profil dashboard yang bisa dibaca lebih detail saat user menekan selengkapnya.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Lamaran Terkirim: 4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '30 Hari Terakhir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _MetricCard(
              total: '4',
              title: 'Total Kunjungan Profil',
              lines: [
                'Profil dilihat                  4',
                'Lamaran Dilihat            4',
                'Tampil dalam Hasil Pencarian      0',
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tayangan: 30',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            const _MetricCard(
              total: '30',
              title: 'Tayangan Konten',
              lines: [
                'Koneksi                               15',
                'Komunitas                              7',
                'Bukan Koneksi                      8',
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Koneksi Baru: 5',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            const _MetricCard(
              total: '5',
              title: 'Koneksi Baru',
              lines: [
                'Berkoneksi                             2',
                'Komunitas                             7',
                'Berhenti Berkoneksi               -4',
              ],
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

class _ProfileMiniHeaderAvatar extends StatelessWidget {
  const _ProfileMiniHeaderAvatar();

  @override
  Widget build(BuildContext context) => const StoryRingAvatar(size: 78);
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.total,
    required this.title,
    required this.lines,
  });

  final String total;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF6A2D)),
      ),
      child: Column(
        children: [
          Text(
            total,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (String line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  line,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
