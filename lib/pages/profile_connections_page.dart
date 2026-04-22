import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/social_service.dart';
import '../widgets/story_ring_avatar.dart';

enum ConnectionTab { followers, following }

class ProfileConnectionsPage extends StatefulWidget {
  const ProfileConnectionsPage({super.key, required this.initialTab});

  final ConnectionTab initialTab;

  @override
  State<ProfileConnectionsPage> createState() => _ProfileConnectionsPageState();
}

class _ProfileConnectionsPageState extends State<ProfileConnectionsPage> {
  final SocialService _socialService = SocialService();
  late ConnectionTab _activeTab;
  List<UserMiniProfile> _followers = <UserMiniProfile>[];
  List<UserMiniProfile> _following = <UserMiniProfile>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
    });
    try {
      final List<UserMiniProfile> followers = await _socialService.getFollowers(
        user.id,
      );
      final List<UserMiniProfile> following = await _socialService.getFollowing(
        user.id,
      );
      if (!mounted) return;
      setState(() {
        _followers = followers;
        _following = following;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showFollowers = _activeTab == ConnectionTab.followers;
    final List<UserMiniProfile> data = showFollowers ? _followers : _following;

    return Scaffold(
      appBar: AppBar(
        title: Text(showFollowers ? 'Pengikut' : 'Mengikuti'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: _tabButton(
                    label: 'Pengikut',
                    active: showFollowers,
                    onTap: () {
                      setState(() {
                        _activeTab = ConnectionTab.followers;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _tabButton(
                    label: 'Mengikuti',
                    active: !showFollowers,
                    onTap: () {
                      setState(() {
                        _activeTab = ConnectionTab.following;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                ? Center(
                    child: Text(
                      showFollowers
                          ? 'Belum ada pengikut.'
                          : 'Belum mengikuti siapa pun.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    itemCount: data.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final UserMiniProfile item = data[index];
                      return Container(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E1014),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2D313B)),
                        ),
                        child: Row(
                          children: [
                            StoryRingProfileAvatar(
                              size: 32,
                              viewed: false,
                              hasStory: false,
                              label: item.name,
                              imageUrl: item.avatarUrl,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    item.role,
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF6A2D) : const Color(0xFF0E1014),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFFF6A2D) : const Color(0xFF2D313B),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
