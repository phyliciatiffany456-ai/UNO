import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../models/story_seen_store.dart';
import '../navigation/app_routes.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../services/social_service.dart';
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
  final PostService _postService = PostService();
  final ProfileService _profileService = ProfileService();
  final SocialService _socialService = SocialService();

  bool _viewedProfileStory = false;
  bool _loading = true;
  List<PostItem> _myPosts = <PostItem>[];
  String _displayName = 'User';
  String _bio = 'Belum ada bio.';
  String _role = 'UNO Member';
  int _followerCount = 0;
  int _followingCount = 0;
  bool _hasActiveStory = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
      final ProfileRecord profile = await _profileService.fetchMyProfile();
      final List<PostItem> posts = await _postService.fetchFeed();
      final Map<String, int> followStats = await _socialService.getFollowStats(
        user.id,
      );
      if (!mounted) return;
      setState(() {
        _displayName = profile.fullName;
        _bio = profile.bio;
        _role = profile.role;
        _avatarUrl = profile.avatarUrl;
        _followerCount = followStats['followers'] ?? 0;
        _followingCount = followStats['following'] ?? 0;
        _myPosts = posts.where((PostItem p) => p.authorId == user.id).toList();
        final DateTime threshold = DateTime.now().subtract(
          const Duration(days: 1),
        );
        _hasActiveStory = _myPosts.any(
          (PostItem p) =>
              p.type == PostType.short &&
              p.createdAt != null &&
              p.createdAt!.isAfter(threshold),
        );
        _viewedProfileStory = StorySeenStore.isSeen(
          authorId: user.id,
          label: _displayName,
        );
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat profil dari database.')),
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double tileWidth = (width - 16) / 3;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onNotificationTap: () => _openNotifications(context),
              onSearchTap: () => _openSearch(context),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileRingAvatar(
                            label: _displayName,
                            viewed: _viewedProfileStory,
                            hasStory: _hasActiveStory,
                            imageUrl: _avatarUrl,
                            onTap: _hasActiveStory
                                ? () => _openStory(context, _displayName)
                                : null,
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
                                  _displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _role,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _ProfileStat(
                                      label: 'Postingan',
                                      value: '${_myPosts.length}',
                                    ),
                                    _ProfileStat(
                                      label: 'Pengikut',
                                      value: '$_followerCount',
                                      onTap: () => _openConnections(
                                        ConnectionTab.followers,
                                      ),
                                    ),
                                    _ProfileStat(
                                      label: 'Mengikuti',
                                      value: '$_followingCount',
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
                          text: _bio,
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
                            onTap: () => Navigator.of(context)
                                .push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const ProfileDashboardPage(),
                                  ),
                                )
                                .then((_) => _loadProfile()),
                          ),
                          const SizedBox(width: 6),
                          _profileAction(
                            'Edit Profil',
                            onTap: () => Navigator.of(context)
                                .push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const ProfileEditPage(),
                                  ),
                                )
                                .then((_) => _loadProfile()),
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
                              onTap: () {},
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
                      if (_myPosts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Belum ada postingan dari akun ini.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _myPosts.map((PostItem post) {
                            final bool hasImage = post.imageUrls.isNotEmpty;
                            return InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PostZoomPage(post: post),
                                ),
                              ),
                              child: SizedBox(
                                width: tileWidth,
                                height: tileWidth * 1.2,
                                child: hasImage
                                    ? Image.network(
                                        post.imageUrls.first,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(
                                          color: Color(0xFFC8C8C8),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFF20242B),
                                        padding: const EdgeInsets.all(8),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          post.content,
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
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

  Future<void> _openStory(BuildContext context, String label) async {
    final String? myUserId = Supabase.instance.client.auth.currentUser?.id;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            StoryViewerPage(story: StoryItem(label: label, authorId: myUserId)),
      ),
    );
    StorySeenStore.markSeen(authorId: myUserId, label: label);
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
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => ProfileConnectionsPage(initialTab: tab),
          ),
        )
        .then((_) => _loadProfile());
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
