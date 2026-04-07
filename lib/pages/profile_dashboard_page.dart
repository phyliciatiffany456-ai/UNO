import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
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
  final PostService _postService = PostService();

  bool _viewedProfileStory = false;
  bool _loading = true;

  String _displayName = 'User';
  String _bio = 'Belum ada bio.';

  int _postCount = 0;
  int _insightCount = 0;
  int _shortCount = 0;
  int _jobCount = 0;
  int _totalLikeCount = 0;
  int _totalCommentCount = 0;
  int _totalShareCount = 0;

  int _applicationCount = 0;
  int _submittedCount = 0;
  int _reviewCount = 0;
  int _interviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      AppRoutes.goLogin(context);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final Map<String, dynamic> metadata =
          user.userMetadata ?? <String, dynamic>{};
      final String name = (metadata['full_name'] as String?)?.trim().isNotEmpty ==
              true
          ? metadata['full_name'].toString()
          : (user.email ?? 'User');
      final String bio = (metadata['bio'] as String?)?.trim().isNotEmpty == true
          ? metadata['bio'].toString()
          : 'Belum ada bio.';

      final List<PostItem> posts = await _postService.fetchFeed();
      final List<PostItem> myPosts =
          posts.where((PostItem p) => p.authorId == user.id).toList();

      int applicationCount = 0;
      int submittedCount = 0;
      int reviewCount = 0;
      int interviewCount = 0;

      try {
        final List<dynamic> applications = await Supabase.instance.client
            .from('job_applications')
            .select('status')
            .eq('applicant_id', user.id);

        applicationCount = applications.length;

        for (final dynamic row in applications) {
          final String status =
              ((row as Map<String, dynamic>)['status'] as String? ?? '')
                  .toLowerCase();
          if (status == 'submitted' || status == 'waiting_review') {
            submittedCount += 1;
          }
          if (status == 'review' || status == 'in_review' || status == 'under_review') {
            reviewCount += 1;
          }
          if (status == 'interview' || status == 'accepted') interviewCount += 1;
        }
      } catch (_) {
        // Ignore when table is not created yet.
      }

      if (!mounted) return;
      final int likeTotal = myPosts.fold<int>(
        0,
        (int total, PostItem post) => total + post.likeCount,
      );
      final int commentTotal = myPosts.fold<int>(
        0,
        (int total, PostItem post) => total + post.commentCount,
      );
      final int shareTotal = myPosts.fold<int>(
        0,
        (int total, PostItem post) => total + post.shareCount,
      );
      setState(() {
        _displayName = name;
        _bio = bio;
        _postCount = myPosts.length;
        _insightCount =
            myPosts.where((PostItem p) => p.type == PostType.insight).length;
        _shortCount =
            myPosts.where((PostItem p) => p.type == PostType.short).length;
        _jobCount = myPosts.where((PostItem p) => p.type == PostType.job).length;
        _totalLikeCount = likeTotal;
        _totalCommentCount = commentTotal;
        _totalShareCount = shareTotal;
        _applicationCount = applicationCount;
        _submittedCount = submittedCount;
        _reviewCount = reviewCount;
        _interviewCount = interviewCount;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data dasbor dari database.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboard,
                child: ListView(
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
                            label: _displayName,
                            viewed: _viewedProfileStory,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => StoryViewerPage(
                                    story: StoryItem(label: _displayName),
                                  ),
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
                                  _displayName,
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
                                    _SmallStat(
                                      label: 'Postingan',
                                      value: '$_postCount',
                                    ),
                                    _SmallStat(
                                      label: 'Pengikut',
                                      value: '-',
                                      onTap: () => _openConnections(
                                        ConnectionTab.followers,
                                      ),
                                    ),
                                    _SmallStat(
                                      label: 'Mengikuti',
                                      value: '-',
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
                      text: _bio,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _MetricCard(
                      title: 'Lamaran Terkirim',
                      total: '$_applicationCount',
                      rows: <_MetricRowData>[
                        _MetricRowData(
                          label: 'Application Submitted',
                          value: '$_submittedCount',
                        ),
                        _MetricRowData(
                          label: 'Tahap Review',
                          value: '$_reviewCount',
                        ),
                        _MetricRowData(
                          label: 'Interview',
                          value: '$_interviewCount',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MetricCard(
                      title: 'Konten Dibuat',
                      total: '$_postCount',
                      rows: <_MetricRowData>[
                        _MetricRowData(label: 'Insight', value: '$_insightCount'),
                        _MetricRowData(label: 'Short', value: '$_shortCount'),
                        _MetricRowData(label: 'Loker', value: '$_jobCount'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MetricCard(
                      title: 'Engagement Postingan',
                      total:
                          '${_totalLikeCount + _totalCommentCount + _totalShareCount}',
                      rows: <_MetricRowData>[
                        _MetricRowData(
                          label: 'Total Like',
                          value: '$_totalLikeCount',
                        ),
                        _MetricRowData(
                          label: 'Total Komentar',
                          value: '$_totalCommentCount',
                        ),
                        _MetricRowData(
                          label: 'Total Share',
                          value: '$_totalShareCount',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MetricCard(
                      title: 'Aktivitas Akun',
                      total: '${_postCount + _applicationCount}',
                      rows: <_MetricRowData>[
                        _MetricRowData(
                          label: 'Total Aktivitas',
                          value: '${_postCount + _applicationCount}',
                        ),
                        _MetricRowData(
                          label: 'Total Postingan',
                          value: '$_postCount',
                        ),
                        _MetricRowData(
                          label: 'Total Lamaran',
                          value: '$_applicationCount',
                        ),
                      ],
                    ),
                  ],
                ),
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
