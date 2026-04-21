import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cv_store.dart';
import '../models/story_item.dart';
import '../navigation/app_routes.dart';
import '../models/post_item.dart';
import '../services/account_switch_service.dart';
import '../services/auth_service.dart';
import '../services/job_application_service.dart';
import '../services/profile_service.dart';
import '../services/post_service.dart';
import '../services/social_service.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
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
  final AuthService _authService = AuthService();
  final AccountSwitchService _accountSwitchService = AccountSwitchService();
  final ProfileService _profileService = ProfileService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
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
  bool _switchingAccount = false;
  bool _uploadingCv = false;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  bool _hasActiveStory = false;
  String? _avatarUrl;
  String? _cvFileName;
  String? _cvStoragePath;
  String? _cvPublicUrl;

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
      await _accountSwitchService.registerCurrentSession(
        displayName: profile.fullName,
        avatarUrl: profile.avatarUrl,
      );
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
        _cvFileName = profile.cvFileName;
        _cvStoragePath = profile.cvStoragePath;
        _cvPublicUrl = profile.cvPublicUrl;
      });
      if (profile.cvFileName != null) {
        CvStore.setCv(
          name: profile.cvFileName!,
          path: profile.cvStoragePath,
          url: profile.cvPublicUrl,
        );
      } else {
        CvStore.clear();
      }
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final List<PostItem> posts = await _postService.fetchFeed();
        final Map<String, int> followStats = await _socialService
            .getFollowStats(userId);
        if (!mounted) return;
        final DateTime threshold = DateTime.now().subtract(
          const Duration(days: 1),
        );
        setState(() {
          _postCount = posts.where((PostItem p) => p.authorId == userId).length;
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

  Future<void> _pickAndUploadCv() async {
    setState(() {
      _uploadingCv = true;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf', 'doc', 'docx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final PlatformFile file = result.files.first;
      final CvUploadResult uploaded = await _jobApplicationService.uploadCv(
        file,
      );
      await _profileService.upsertMyProfile(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        pronoun: _selectedPronoun,
        gender: _selectedGender,
        education: _educationController.text.trim(),
        workExperience: _workController.text.trim(),
        role: _roleController.text.trim(),
        avatarUrl: _avatarUrl,
        cvFileName: uploaded.fileName,
        cvStoragePath: uploaded.storagePath,
        cvPublicUrl: uploaded.publicUrl,
      );

      if (!mounted) return;
      setState(() {
        _cvFileName = uploaded.fileName;
        _cvStoragePath = uploaded.storagePath;
        _cvPublicUrl = uploaded.publicUrl;
      });
      CvStore.setCv(
        name: uploaded.fileName,
        path: uploaded.storagePath,
        url: uploaded.publicUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CV berhasil di-upload: ${uploaded.fileName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal upload CV: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _uploadingCv = false;
        });
      }
    }
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
            avatarUrl: _avatarUrl,
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
        cvFileName: _cvFileName,
        cvStoragePath: _cvStoragePath,
        cvPublicUrl: _cvPublicUrl,
      );
      await _accountSwitchService.registerCurrentSession(
        displayName: name.isEmpty ? null : name,
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
    if (!mounted) return;
    if (!_isAllowedAvatarFile(file.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil hanya boleh PNG, JPG, atau JPEG.'),
        ),
      );
      return;
    }
    try {
      final String url = await _profileService.uploadMyAvatar(file);
      await _profileService.upsertMyProfile(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        pronoun: _selectedPronoun,
        gender: _selectedGender,
        education: _educationController.text.trim(),
        workExperience: _workController.text.trim(),
        role: _roleController.text.trim(),
        avatarUrl: url,
      );
      if (!mounted) return;
      setState(() {
        _avatarUrl = url;
      });
      await _accountSwitchService.registerCurrentSession(
        displayName: _nameController.text.trim(),
        avatarUrl: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diubah.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  bool _isAllowedAvatarFile(String fileName) {
    final String lower = fileName.trim().toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      AppRoutes.goLogin(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal logout. Coba lagi.')));
    }
  }

  Future<void> _openAccountSwitcher() async {
    final List<KnownAccount> accounts = await _accountSwitchService
        .loadKnownAccounts();
    if (!mounted) return;

    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada akun lain yang pernah login di perangkat ini.',
          ),
        ),
      );
      return;
    }

    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ganti Akun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...accounts.map((KnownAccount account) {
                  final bool isCurrent = account.userId == currentUserId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _KnownAccountTile(
                      account: account,
                      isCurrent: isCurrent,
                      disabled: _switchingAccount,
                      onTap: () async {
                        if (isCurrent || _switchingAccount) {
                          Navigator.of(sheetContext).pop();
                          return;
                        }
                        Navigator.of(sheetContext).pop();
                        await _switchToAccount(account);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _switchToAccount(KnownAccount account) async {
    setState(() {
      _switchingAccount = true;
    });
    try {
      await _accountSwitchService.switchToAccount(account);
      if (!mounted) return;
      AppRoutes.goHome(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal ganti akun. Coba login ulang ke akun tersebut sekali lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _switchingAccount = false;
        });
      }
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
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _EditTextField(label: 'Nama', controller: _nameController),
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
              _EditTextField(label: 'Role', controller: _roleController),
              const SizedBox(height: 10),
              AppButton(
                label: 'Simpan Perubahan',
                onTap: _saveProfile,
                height: 40,
                fontSize: 13,
              ),
              const SizedBox(height: 8),
              _menuAction(
                'Ubah Foto Profil (PNG, JPG, JPEG)',
                icon: Icons.photo_camera_outlined,
                onTap: _changePhoto,
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<String?>(
                valueListenable: CvStore.fileName,
                builder: (BuildContext context, String? value, Widget? child) {
                  final bool hasCv = value != null;
                  return _menuAction(
                    _uploadingCv
                        ? 'Uploading CV...'
                        : (hasCv
                              ? 'Curriculum Vitae ($value)'
                              : 'Curriculum Vitae'),
                    icon: hasCv
                        ? Icons.check_circle_outline
                        : Icons.upload_file,
                    onTap: _uploadingCv ? () {} : _pickAndUploadCv,
                  );
                },
              ),
              const SizedBox(height: 6),
              _menuAction('LogOut', icon: Icons.chevron_right, onTap: _logout),
              const SizedBox(height: 6),
              _menuAction(
                _switchingAccount ? 'Mengganti Akun...' : 'Ganti Akun',
                icon: Icons.chevron_right,
                onTap: _switchingAccount ? () {} : _openAccountSwitcher,
              ),
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
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
            const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 18,
            ),
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

class _KnownAccountTile extends StatelessWidget {
  const _KnownAccountTile({
    required this.account,
    required this.isCurrent,
    required this.disabled,
    required this.onTap,
  });

  final KnownAccount account;
  final bool isCurrent;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1013),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFFFF6A2D)
                : const Color(0xFF2D313B),
          ),
        ),
        child: Row(
          children: [
            ProfileRingAvatar(
              label: account.displayName,
              viewed: false,
              hasStory: false,
              size: 42,
              imageUrl: account.avatarUrl,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              isCurrent ? 'Dipakai' : 'Pilih',
              style: TextStyle(
                color: isCurrent ? const Color(0xFFFF6A2D) : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
