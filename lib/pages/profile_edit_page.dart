import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cv_store.dart';
import '../models/story_item.dart';
import '../navigation/app_routes.dart';
import '../models/post_item.dart';
import '../services/profile_service.dart';
import '../services/post_service.dart';
import '../services/social_service.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/profile_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'profile_connections_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ProfileService _profileService = ProfileService();
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String _selectedPronoun = 'Ms.';
  String _selectedGender = 'Perempuan';
  bool _viewedProfileStory = false;
  bool _loading = true;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  bool _hasActiveStory = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _nameController.addListener(_refresh);
    _bioController.addListener(_refresh);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final ProfileRecord profile = await _profileService.fetchMyProfile();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.fullName;
        _bioController.text = profile.bio;
        _educationController.text = profile.education;
        _workController.text = profile.workExperience;
        _roleController.text = profile.role;
        _selectedPronoun = profile.pronoun;
        _selectedGender = profile.gender;
        _avatarUrl = profile.avatarUrl;
      });
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final List<PostItem> posts = await _postService.fetchFeed();
        final Map<String, int> followStats = await _socialService.getFollowStats(
          userId,
        );
        if (!mounted) return;
        final DateTime threshold = DateTime.now().subtract(
          const Duration(days: 1),
        );
        setState(() {
          _postCount =
              posts.where((PostItem p) => p.authorId == userId).length;
          _followerCount = followStats['followers'] ?? 0;
          _followingCount = followStats['following'] ?? 0;
          _hasActiveStory = posts.any(
            (PostItem p) =>
                p.authorId == userId &&
                p.type == PostType.short &&
                p.createdAt != null &&
                p.createdAt!.isAfter(threshold),
          );
        });
      }
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

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _bioController.removeListener(_refresh);
    _nameController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _workController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
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

  Future<void> _showUploadCvSheet() async {
    final String? picked = await showModalBottomSheet<String>(
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
                  'Pilih Format CV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _CvPickerTile(
                  label: 'PDF',
                  example: 'Tiffany_CV.pdf',
                  onTap: () => Navigator.of(context).pop('Tiffany_CV.pdf'),
                ),
                const SizedBox(height: 8),
                _CvPickerTile(
                  label: 'DOCX',
                  example: 'Tiffany_CV.docx',
                  onTap: () => Navigator.of(context).pop('Tiffany_CV.docx'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    CvStore.setCv(name: picked);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CV berhasil di-upload: $picked'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _openProfileStory() async {
    final String label = _nameController.text.trim().isEmpty
        ? 'User'
        : _nameController.text.trim();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          story: StoryItem(
            label: label,
            authorId: Supabase.instance.client.auth.currentUser?.id,
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedProfileStory = true;
    });
  }

  Future<void> _saveProfile() async {
    final String name = _nameController.text.trim();
    final String bio = _bioController.text.trim();
    final String education = _educationController.text.trim();
    final String work = _workController.text.trim();
    final String role = _roleController.text.trim();
    try {
      await _profileService.upsertMyProfile(
        fullName: name,
        bio: bio,
        pronoun: _selectedPronoun,
        gender: _selectedGender,
        education: education,
        workExperience: work,
        role: role,
        avatarUrl: _avatarUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal simpan profil ke database.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _changePhoto() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    try {
      final String url = await _profileService.uploadMyAvatar(file);
      if (!mounted) return;
      setState(() {
        _avatarUrl = url;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diubah.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload foto profil.')),
      );
    }
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          children: [
            TopBar(
              onNotificationTap: _openNotifications,
              onSearchTap: _openSearch,
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EditAvatar(
                  label: _nameController.text.isEmpty
                      ? 'User'
                      : _nameController.text,
                  viewed: _viewedProfileStory,
                  hasStory: _hasActiveStory,
                  imageUrl: _avatarUrl,
                  onTap: _hasActiveStory ? _openProfileStory : null,
                  onAddTap: _changePhoto,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isEmpty
                            ? 'User'
                            : _nameController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MiniStat(label: 'Postingan', value: '$_postCount'),
                          _MiniStat(
                            label: 'Pengikut',
                            value: '$_followerCount',
                            onTap: () =>
                                _openConnections(ConnectionTab.followers),
                          ),
                          _MiniStat(
                            label: 'Mengikuti',
                            value: '$_followingCount',
                            onTap: () =>
                                _openConnections(ConnectionTab.following),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ExpandableText(
                text:
                    _bioController.text.isEmpty ? 'Belum ada bio.' : _bioController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 10),
            _EditTextField(
              label: 'Nama',
              controller: _nameController,
            ),
            const SizedBox(height: 6),
            _EditDropdownField(
              label: 'Kata Ganti',
              value: _selectedPronoun,
              items: const <String>['Ms.', 'Mr.', 'Mrs'],
              onChanged: (String value) {
                setState(() {
                  _selectedPronoun = value;
                });
              },
            ),
            const SizedBox(height: 6),
            _EditTextField(
              label: 'Bio',
              controller: _bioController,
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 6),
            _EditDropdownField(
              label: 'Jenis Kelamin',
              value: _selectedGender,
              items: const <String>['Laki-laki', 'Perempuan'],
              onChanged: (String value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 6),
            _EditTextField(
              label: 'Pendidikan',
              controller: _educationController,
            ),
            const SizedBox(height: 6),
            _EditTextField(
              label: 'Pengalaman Kerja',
              controller: _workController,
            ),
            const SizedBox(height: 6),
            _EditTextField(
              label: 'Role',
              controller: _roleController,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Simpan Perubahan',
              onTap: _saveProfile,
              height: 40,
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String?>(
              valueListenable: CvStore.fileName,
              builder: (BuildContext context, String? value, Widget? child) {
                final bool hasCv = value != null;
                return _menuAction(
                  hasCv ? 'Curriculum Vitae ($value)' : 'Curriculum Vitae',
                  icon: hasCv ? Icons.check_circle_outline : Icons.upload_file,
                  onTap: _showUploadCvSheet,
                );
              },
            ),
            const SizedBox(height: 6),
            _menuAction(
              'LogOut',
              icon: Icons.chevron_right,
              onTap: () => AppRoutes.goLogin(context),
            ),
            const SizedBox(height: 6),
            _menuAction('Ganti Akun', icon: Icons.chevron_right, onTap: () {}),
            ],
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
        onProfileTap: () => AppRoutes.goProfile(context),
      ),
    );
  }

  Widget _menuAction(
    String label, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EditTextField extends StatelessWidget {
  const _EditTextField({
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6A2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            cursorColor: const Color(0xFFFF6A2D),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: Color(0xFF0E1014),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2D313B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2D313B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF6A2D)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditDropdownField extends StatelessWidget {
  const _EditDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6A2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1014),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF2D313B)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1C22),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                items: items
                    .map(
                      (String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) onChanged(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CvPickerTile extends StatelessWidget {
  const _CvPickerTile({
    required this.label,
    required this.example,
    required this.onTap,
  });

  final String label;
  final String example;
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
            const Icon(Icons.description_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label - $example',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EditAvatar extends StatelessWidget {
  const _EditAvatar({
    required this.label,
    required this.viewed,
    required this.onTap,
    required this.hasStory,
    this.imageUrl,
    this.onAddTap,
  });

  final String label;
  final bool viewed;
  final VoidCallback? onTap;
  final bool hasStory;
  final String? imageUrl;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) => ProfileRingAvatar(
    label: label,
    size: 84,
    viewed: viewed,
    hasStory: hasStory,
    imageUrl: imageUrl,
    onTap: onTap,
    showAdd: true,
    onAddTap: onAddTap,
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.onTap});

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
