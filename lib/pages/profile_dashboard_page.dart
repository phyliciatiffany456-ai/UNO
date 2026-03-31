import 'package:flutter/material.dart';

import '../models/profile_store.dart';
import '../models/story_item.dart';
import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/profile_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'profile_connections_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class ProfileDashboardPage extends StatefulWidget {
  const ProfileDashboardPage({super.key});

  @override
  State<ProfileDashboardPage> createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  bool _viewedProfileStory = false;

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

  void _openConnections(ConnectionTab tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileConnectionsPage(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<ProfileData>(
          valueListenable: ProfileStore.data,
          builder: (BuildContext context, ProfileData profile, Widget? child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              children: [
                TopBar(
                  onNotificationTap: _openNotifications,
                  onSearchTap: _openSearch,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13151A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF24262E)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileMiniHeaderAvatar(
                        label: profile.name,
                        viewed: _viewedProfileStory,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  StoryViewerPage(story: StoryItem(label: profile.name)),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {
                            _viewedProfileStory = true;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const _SmallStat(label: 'Postingan', value: '68'),
                                _SmallStat(
                                  label: 'Pengikut',
                                  value: '9.8K',
                                  onTap: () => _openConnections(
                                    ConnectionTab.followers,
                                  ),
                                ),
                                _SmallStat(
                                  label: 'Mengikuti',
                                  value: '201',
                                  onTap: () => _openConnections(
                                    ConnectionTab.following,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ExpandableText(
                  text: profile.bio,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                const _MetricCard(
                  title: 'Lamaran Terkirim',
                  total: '4',
                  rows: <_MetricRowData>[
                    _MetricRowData(label: 'Lamaran Dibuka HR', value: '4'),
                    _MetricRowData(label: 'Tahap Review', value: '2'),
                    _MetricRowData(label: 'Interview', value: '1'),
                  ],
                ),
                const SizedBox(height: 8),
                const _MetricCard(
                  title: 'Tayangan Konten',
                  total: '30',
                  rows: <_MetricRowData>[
                    _MetricRowData(label: 'Koneksi', value: '15'),
                    _MetricRowData(label: 'Komunitas', value: '7'),
                    _MetricRowData(label: 'Non Koneksi', value: '8'),
                  ],
                ),
                const SizedBox(height: 8),
                const _MetricCard(
                  title: 'Koneksi Baru',
                  total: '5',
                  rows: <_MetricRowData>[
                    _MetricRowData(label: 'Permintaan Diterima', value: '2'),
                    _MetricRowData(label: 'Permintaan Masuk', value: '7'),
                    _MetricRowData(label: 'Unfollow', value: '-4'),
                  ],
                ),
              ],
            );
          },
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
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }
}

class _ProfileMiniHeaderAvatar extends StatelessWidget {
  const _ProfileMiniHeaderAvatar({
    required this.label,
    required this.viewed,
    required this.onTap,
  });

  final String label;
  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      ProfileRingAvatar(label: label, size: 74, viewed: viewed, onTap: onTap);
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.total,
    required this.rows,
  });

  final String title;
  final String total;
  final List<_MetricRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13151A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24262E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1014),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2D313B)),
                ),
                child: Text(
                  total,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map((row) => _MetricRow(data: row)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.data});

  final _MetricRowData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRowData {
  const _MetricRowData({required this.label, required this.value});

  final String label;
  final String value;
}
