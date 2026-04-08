import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post_item.dart';
import '../services/post_service.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobLocationController = TextEditingController();
  final TextEditingController _jobDomicileController = TextEditingController();
  final TextEditingController _jobRequirementsController =
      TextEditingController();
  final TextEditingController _jobDeadlineController = TextEditingController();
  final PostService _postService = PostService();
  final ImagePicker _imagePicker = ImagePicker();

  bool hideLikeAndViewCount = true;
  bool turnOffCommenting = true;
  String selectedCategory = 'Insight';
  String selectedAccessibility = 'Public';
  bool _isPosting = false;
  List<XFile> _selectedImages = <XFile>[];

  @override
  void dispose() {
    _descriptionController.dispose();
    _jobTitleController.dispose();
    _jobLocationController.dispose();
    _jobDomicileController.dispose();
    _jobRequirementsController.dispose();
    _jobDeadlineController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
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

  Future<void> _pickImages() async {
    final List<XFile> files = await _imagePicker.pickMultiImage(
      imageQuality: 85,
    );
    if (files.isEmpty) return;
    setState(() {
      _selectedImages = files;
    });
  }

  Future<void> _submitPost() async {
    final bool isJobPost = selectedCategory == 'Loker';
    final String rawContent = _descriptionController.text.trim();
    final String jobTitle = _jobTitleController.text.trim();
    final String content = rawContent.isNotEmpty
        ? rawContent
        : (isJobPost ? jobTitle : '');

    if (content.isEmpty) {
      _showMessage('Deskripsi postingan tidak boleh kosong.');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await _postService.createPost(
        content: content,
        type: _mapCategory(selectedCategory),
        accessibility: selectedAccessibility,
        hideLikeAndViewCount: hideLikeAndViewCount,
        turnOffCommenting: turnOffCommenting,
        images: _selectedImages,
        jobTitle: jobTitle,
        jobLocation: _jobLocationController.text.trim(),
        jobDomicile: _jobDomicileController.text.trim(),
        jobRequirements: _jobRequirementsController.text.trim(),
        jobDeadline: DateTime.tryParse(_jobDeadlineController.text.trim()),
      );
      if (!mounted) return;
      _showMessage('Postingan berhasil dipublikasikan.');
      Navigator.of(context).pop();
    } catch (error) {
      final String raw = error.toString().toLowerCase();
      if (raw.contains('bucket not found')) {
        _showMessage(
          'Bucket Storage `post-images` belum ada. Buat dulu bucket di Supabase, lalu coba upload lagi.',
        );
      } else if (raw.contains('violates check constraint') &&
          raw.contains('category')) {
        _showMessage(
          'Schema Supabase untuk kolom category belum support job/loker. Jalankan ulang file supabase/schema.sql di SQL Editor.',
        );
      } else if (raw.contains('row-level security')) {
        _showMessage(
          'Akun belum punya izin insert posts. Pastikan login, lalu jalankan ulang supabase/schema.sql agar policy terbaru aktif.',
        );
      } else {
        _showMessage('Gagal upload postingan: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  PostType _mapCategory(String category) {
    switch (category) {
      case 'Short':
        return PostType.short;
      case 'Loker':
        return PostType.job;
      case 'Insight':
      case 'Portofolio':
      default:
        return PostType.insight;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 14),
          children: [
            TopBar(
              onNotificationTap: _openNotifications,
              onSearchTap: _openSearch,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  const Text(
                    'Postingan Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _isPosting ? null : _pickImages,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _isPosting ? null : _pickImages,
              child: Container(
                height: 260,
                width: double.infinity,
                color: const Color(0xFFC8C8C8),
                child: _selectedImages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Color(0xFF2D313B),
                              size: 42,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap untuk pilih gambar',
                              style: TextStyle(
                                color: Color(0xFF2D313B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: _selectedImages.length,
                            separatorBuilder: (BuildContext context, int index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (BuildContext context, int index) {
                              final XFile image = _selectedImages[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _PickedImagePreview(
                                      image: image,
                                      width: 170,
                                      height: 244,
                                    ),
                                  ),
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages = List<XFile>.from(
                                            _selectedImages,
                                          )..removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _CreateDropdownField(
                      label: 'Kategori',
                      value: selectedCategory,
                      options: const <String>[
                        'Insight',
                        'Short',
                        'Loker',
                        'Portofolio',
                      ],
                      onChanged: (String value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CreateDropdownField(
                      label: 'Accessibility',
                      value: selectedAccessibility,
                      options: const <String>['Public', 'Private'],
                      onChanged: (String value) {
                        setState(() {
                          selectedAccessibility = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (selectedCategory == 'Loker')
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Column(
                  children: [
                    _DescriptionField(
                      controller: _jobTitleController,
                      hint: 'Nama loker / posisi',
                      height: 52,
                    ),
                    const SizedBox(height: 8),
                    _DescriptionField(
                      controller: _jobLocationController,
                      hint: 'Lokasi kerja (contoh: Jakarta Selatan)',
                      height: 52,
                    ),
                    const SizedBox(height: 8),
                    _DescriptionField(
                      controller: _jobDomicileController,
                      hint: 'Domisili kandidat (contoh: Jabodetabek)',
                      height: 52,
                    ),
                    const SizedBox(height: 8),
                    _DescriptionField(
                      controller: _jobDeadlineController,
                      hint: 'Deadline (YYYY-MM-DD)',
                      height: 52,
                    ),
                    const SizedBox(height: 8),
                    _DescriptionField(
                      controller: _jobRequirementsController,
                      hint: 'Kriteria kandidat',
                      height: 90,
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _DescriptionField(controller: _descriptionController),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _ToggleRow(
                label: 'Hide like and view counts on this post',
                value: hideLikeAndViewCount,
                onChanged: (bool value) {
                  setState(() {
                    hideLikeAndViewCount = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _ToggleRow(
                label: 'Turn off commenting',
                value: turnOffCommenting,
                onChanged: (bool value) {
                  setState(() {
                    turnOffCommenting = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 90,
                  child: AppButton(
                    label: _isPosting ? 'UPLOAD...' : 'POST',
                    onTap: _isPosting ? null : _submitPost,
                    height: 34,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.create,
        onHomeTap: _goHome,
        onApplyTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ApplyPage())),
        onCommunityTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CommunityPage())),
        onProfileTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
      ),
    );
  }
}

class _PickedImagePreview extends StatelessWidget {
  const _PickedImagePreview({
    required this.image,
    required this.width,
    required this.height,
  });

  final XFile image;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFF9E9E9E),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _CreateDropdownField extends StatelessWidget {
  const _CreateDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          dropdownColor: const Color(0xFF1A1C22),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          isExpanded: true,
          items: options
              .map(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text('$label: $item'),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({
    required this.controller,
    this.hint = 'Deskripsi',
    this.height = 90,
  });

  final TextEditingController controller;
  final String hint;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFFF1E13),
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
