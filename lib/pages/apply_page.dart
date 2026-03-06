import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';

class ApplyPage extends StatelessWidget {
  const ApplyPage({super.key});

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
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                children: const [
                  _JobCard(
                    title: 'IT Specialist',
                    salary: 'Rp 5-6 Juta',
                    city: 'Jakarta Barat',
                    chips: ['Fulltime', 'SMA/SMK', 'HTML', 'Java'],
                  ),
                  SizedBox(height: 12),
                  _JobCard(
                    title: 'Customer Service',
                    salary: 'Rp 5-6 Juta',
                    city: 'Jakarta Barat',
                    chips: ['Fulltime', 'SMA/SMK', 'Communication Skill'],
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
    required this.salary,
    required this.city,
    required this.chips,
  });

  final String title;
  final String salary;
  final String city;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                Text(
                  salary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const StoryRingAvatar(size: 42),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'TiffanyPhylicia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Text(
                  city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
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
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1414),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
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
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6A2D)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
