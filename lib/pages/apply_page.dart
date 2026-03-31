import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../models/story_item.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
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
  final Set<String> _viewedProfiles = <String>{};

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

  Future<void> _openStory(BuildContext context, String label) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(story: StoryItem(label: label)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedProfiles.add(label);
    });
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                children: [
                  _JobCard(
                    title: 'IT Specialist',
                    profileName: 'TiffanyPhylicia',
                    salary: 'Rp 5-6 Juta',
                    city: 'Jakarta Barat',
                    chips: ['Fulltime', 'SMA/SMK', 'HTML', 'Java'],
                    isProfileViewed: _viewedProfiles.contains(
                      'TiffanyPhylicia',
                    ),
                    onProfileTap: () => _openStory(context, 'TiffanyPhylicia'),
                    onApplyTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const JobApplyPage(company: 'TiffanyPhylicia'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _JobCard(
                    title: 'Customer Service',
                    profileName: 'Rani HRD',
                    salary: 'Rp 5-6 Juta',
                    city: 'Jakarta Barat',
                    chips: ['Fulltime', 'SMA/SMK', 'Communication Skill'],
                    isProfileViewed: _viewedProfiles.contains('Rani HRD'),
                    onProfileTap: () => _openStory(context, 'Rani HRD'),
                    onApplyTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const JobApplyPage(company: 'Rani HRD'),
                      ),
                    ),
                  ),
                ],
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
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.title,
    required this.profileName,
    required this.salary,
    required this.city,
    required this.chips,
    required this.isProfileViewed,
    this.onProfileTap,
    this.onApplyTap,
  });

  final String title;
  final String profileName;
  final String salary;
  final String city;
  final List<String> chips;
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
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
                  label: 'Apply',
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
  const _StoryProfile({required this.label, required this.viewed, this.onTap});

  final String label;
  final bool viewed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Gradient ringGradient = viewed
        ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF6B7280)])
        : const LinearGradient(
            colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return SizedBox(
      width: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ringGradient,
              ),
              child: Center(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F1013),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5E7EB),
                      ),
                      child: Center(
                        child: Text(
                          _initials(label),
                          style: const TextStyle(
                            color: Color(0xFF121417),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
