import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../models/profile_store.dart';
import '../models/story_item.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/profile_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'create_short_page.dart';
import 'notifications_page.dart';
import 'post_zoom_page.dart';
import 'profile_connections_page.dart';
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
        child: ValueListenableBuilder<ProfileData>(
          valueListenable: ProfileStore.data,
          builder: (BuildContext context, ProfileData profile, Widget? child) {
            return Column(
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
                          ProfileRingAvatar(
                            label: profile.name,
                            viewed: _viewedProfileStory,
                            onTap: () => _openStory(context, profile.name),
                            showAdd: true,
                            onAddTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const CreateShortPage(),
                              ),
                            ),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const _ProfileStat(
                                      label: 'Postingan',
                                      value: '68',
                                    ),
                                    _ProfileStat(
                                      label: 'Pengikut',
                                      value: '9.8K',
                                      onTap: () => _openConnections(
                                        ConnectionTab.followers,
                                      ),
                                    ),
                                    _ProfileStat(
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
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ExpandableText(
                          text: profile.bio,
                          style: const TextStyle(
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
                            onTap: () => _openShareSheet(context),
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

  Future<void> _openShareSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _ShareTile(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp',
                  subtitle: 'Kirim link profil ke WhatsApp',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
                _ShareTile(
                  icon: Icons.forum_outlined,
                  title: 'Discord',
                  subtitle: 'Bagikan ke channel Discord',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
                _ShareTile(
                  icon: Icons.copy_outlined,
                  title: 'Copy Link',
                  subtitle: 'Salin link profil',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openConnections(ConnectionTab tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileConnectionsPage(initialTab: tab),
      ),
    );
  }

  Widget _profileAction(String label, {required VoidCallback onTap}) {
    return Expanded(
      child: AppButton(
        label: label,
        onTap: onTap,
        variant: AppButtonVariant.outline,
        height: 32,
        fontSize: 12,
        borderRadius: 8,
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value, this.onTap});

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
        ),
      ),
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

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1013),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D313B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
