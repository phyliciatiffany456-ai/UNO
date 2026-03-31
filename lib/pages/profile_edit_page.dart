import 'package:flutter/material.dart';

import '../models/cv_store.dart';
import '../models/profile_store.dart';
import '../models/story_item.dart';
import '../navigation/app_routes.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/expandable_text.dart';
import '../widgets/story_ring_avatar.dart';
import '../widgets/top_bar.dart';
import 'create_post_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'story_viewer_page.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _workController = TextEditingController();

  String _selectedPronoun = 'Ms.';
  String _selectedGender = 'Perempuan';
  bool _viewedProfileStory = false;

  @override
  void initState() {
    super.initState();
    final ProfileData profile = ProfileStore.data.value;
    _nameController.text = profile.name;
    _bioController.text = profile.bio;
    _educationController.text = profile.education;
    _workController.text = profile.workExperience;
    _selectedPronoun = profile.pronoun;
    _selectedGender = profile.gender;
    _nameController.addListener(_refresh);
    _bioController.addListener(_refresh);
  }

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _bioController.removeListener(_refresh);
    _nameController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _workController.dispose();
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
    CvStore.setCv(picked);
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
        builder: (_) => StoryViewerPage(story: StoryItem(label: label)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedProfileStory = true;
    });
  }

  void _saveProfile() {
    final String name = _nameController.text.trim();
    final String bio = _bioController.text.trim();
    final String education = _educationController.text.trim();
    final String work = _workController.text.trim();

    final ProfileData updated = ProfileStore.data.value.copyWith(
      name: name.isEmpty ? 'User' : name,
      pronoun: _selectedPronoun,
      bio: bio.isEmpty ? 'Belum ada bio.' : bio,
      gender: _selectedGender,
      education: education.isEmpty ? '-' : education,
      workExperience: work.isEmpty ? '-' : work,
    );
    ProfileStore.update(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        duration: Duration(seconds: 1),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EditAvatar(
                  viewed: _viewedProfileStory,
                  onTap: _openProfileStory,
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MiniStat(label: 'Postingan', value: '68'),
                          _MiniStat(label: 'Pengikuti', value: '9.8K'),
                          _MiniStat(label: 'Mengikuti', value: '201'),
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
  const _EditAvatar({required this.viewed, required this.onTap});

  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      StoryRingAvatar(size: 84, viewed: viewed, onTap: onTap);
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
