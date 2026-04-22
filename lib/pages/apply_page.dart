import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../models/story_seen_store.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'job_apply_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final PostService _postService = PostService();

  List<PostItem> _jobs = <PostItem>[];
  Map<String, List<String>> _activeStoryIdsByAuthor = <String, List<String>>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    StorySeenStore.changes.addListener(_handleSeenStoreChanged);
    _loadJobs();
  }

  @override
  void dispose() {
    StorySeenStore.changes.removeListener(_handleSeenStoreChanged);
    super.dispose();
  }

  void _handleSeenStoreChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
    });

    try {
      final List<PostItem> posts = await _postService.fetchFeed();
      final DateTime threshold = DateTime.now().subtract(
        const Duration(days: 1),
      );
      final Map<String, List<String>> activeStoryIdsByAuthor =
          <String, List<String>>{};
      for (final PostItem post in posts.where(
        (PostItem post) =>
            post.type == PostType.short &&
            post.createdAt != null &&
            post.createdAt!.isAfter(threshold),
      )) {
        activeStoryIdsByAuthor.putIfAbsent(post.authorId, () => <String>[]).add(
          post.id,
        );
      }
      if (!mounted) return;
      setState(() {
        _jobs = posts.where((PostItem post) => post.type == PostType.job).toList();
        _activeStoryIdsByAuthor = activeStoryIdsByAuthor;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data loker dari database.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

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

  Future<void> _openStory(BuildContext context, PostItem job) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          story: StoryItem(
            label: job.name,
            authorId: job.authorId,
            avatarUrl: job.avatarUrl,
            storyIds: _activeStoryIdsByAuthor[job.authorId] ?? const <String>[],
            isViewed: StorySeenStore.hasSeenAllStoryIds(
              _activeStoryIdsByAuthor[job.authorId] ?? const <String>[],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: () => _openNotifications(context),
              onSearchTap: () => _openSearch(context),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rekomendasi Loker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _jobs.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada loker di database.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadJobs,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        itemCount: _jobs.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          final PostItem job = _jobs[index];
                          final String? currentUserId =
                              _postService.currentUser?.id;
                          final bool isOwner = currentUserId == job.authorId;
                          final bool isClosed = _isJobClosed(job);
                          final bool canOpenApply = isOwner || !isClosed;
                          return _JobCard(
                            title: job.jobTitle ?? job.content,
                            profileName: job.name,
                            avatarUrl: job.avatarUrl,
                            salary: _deadlineText(job),
                            city: job.jobLocation ?? job.role,
                            domicile: job.jobDomicile ?? '-',
                            requirements: job.jobRequirements ?? '-',
                            chips: _criteriaChips(job.jobRequirements),
                            isProfileViewed: StorySeenStore.hasSeenAllStoryIds(
                              _activeStoryIdsByAuthor[job.authorId] ??
                                  const <String>[],
                            ),
                            onProfileTap: () => _openStory(context, job),
                            onApplyTap: canOpenApply
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => JobApplyPage(post: job),
                                    ),
                                  )
                                : null,
                            actionLabel: isOwner
                                ? 'Review'
                                : (isClosed ? 'Closed' : 'Apply'),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.apply,
        onHomeTap: () => AppRoutes.goHome(context),
        onApplyTap: () {},
        onCreateTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage())),
        onCommunityTap: () => AppRoutes.goCommunity(context),
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }

  bool _isJobClosed(PostItem job) {
    final DateTime? deadline = job.jobDeadline;
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline);
  }

  String _deadlineText(PostItem job) {
    final DateTime? deadline = job.jobDeadline;
    if (deadline == null) return 'Open';
    final String month = deadline.month.toString().padLeft(2, '0');
    final String day = deadline.day.toString().padLeft(2, '0');
    final String hour = deadline.hour.toString().padLeft(2, '0');
    final String minute = deadline.minute.toString().padLeft(2, '0');
    final bool closed = _isJobClosed(job);
    return '${closed ? 'Closed' : 'Deadline'} $day/$month/${deadline.year} $hour:$minute';
  }

  List<String> _criteriaChips(String? rawRequirements) {
    final String requirements = (rawRequirements ?? '').trim();
    if (requirements.isEmpty) {
      return <String>['Tidak ada kriteria'];
    }

    final List<String> parts = requirements
        .split(RegExp(r'[\n,;|/]+'))
        .map((String item) => item.trim())
        .expand((String item) => item.split(RegExp(r'\s+-\s+|\s+dan\s+')))
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .map(_normalizeCriteriaChip)
        .where((String item) => item.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return <String>[_normalizeCriteriaChip(requirements)];
    }

    final List<String> unique = <String>[];
    for (final String part in parts) {
      final bool exists = unique.any(
        (String current) => current.toLowerCase() == part.toLowerCase(),
      );
      if (!exists) {
        unique.add(part);
      }
      if (unique.length == 6) break;
    }
    return unique;
  }

  String _normalizeCriteriaChip(String value) {
    String cleaned = value
        .replaceAll(RegExp(r'^[\-\u2022\d\.\)\s]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return '';
    if (cleaned.length > 28) {
      cleaned = '${cleaned.substring(0, 25).trim()}...';
    }
    return cleaned;
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.title,
    required this.profileName,
    this.avatarUrl,
    required this.salary,
    required this.city,
    required this.domicile,
    required this.requirements,
    required this.chips,
    required this.actionLabel,
    required this.isProfileViewed,
    this.onProfileTap,
    this.onApplyTap,
  });

  final String title;
  final String profileName;
  final String? avatarUrl;
  final String salary;
  final String city;
  final String domicile;
  final String requirements;
  final List<String> chips;
  final String actionLabel;
  final bool isProfileViewed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onApplyTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onApplyTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  salary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoryProfile(
                  label: profileName,
                  avatarUrl: avatarUrl,
                  viewed: isProfileViewed,
                  onTap: onProfileTap,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    city,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Domisili: $domicile',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 2),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((String text) => _SkillChip(label: text))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 90,
                child: AppButton(
                  label: actionLabel,
                  onTap: onApplyTap,
                  height: 34,
                  fontSize: 12,
                  borderRadius: 10,
                  expand: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 82),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0E1014),
        border: Border.all(color: const Color(0xFF2D313B)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StoryProfile extends StatelessWidget {
  const _StoryProfile({
    required this.label,
    this.avatarUrl,
    required this.viewed,
    this.onTap,
  });

  final String label;
  final String? avatarUrl;
  final bool viewed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Column(
          children: [
            StoryRingProfileAvatar(
              size: 52,
              viewed: viewed,
              hasStory: true,
              label: label,
              imageUrl: avatarUrl,
              onTap: onTap,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
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
