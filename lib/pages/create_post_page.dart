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

  String selectedCategory = 'Insight';
  String selectedAccessibility = 'Public';
  bool _isPosting = false;
  List<XFile> _selectedImages = <XFile>[];
  DateTime? _selectedJobDeadline;

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
      final List<XFile> mergedImages = List<XFile>.from(_selectedImages);
      for (final XFile file in files) {
        final bool alreadySelected = mergedImages.any(
          (XFile existing) => existing.path == file.path,
        );
        if (!alreadySelected) {
          mergedImages.add(file);
        }
      }
      _selectedImages = mergedImages;
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
        accessibility: _mapAccessibility(selectedAccessibility),
        images: _selectedImages,
        jobTitle: jobTitle,
        jobLocation: _jobLocationController.text.trim(),
        jobDomicile: _jobDomicileController.text.trim(),
        jobRequirements: _jobRequirementsController.text.trim(),
        jobDeadline: _selectedJobDeadline,
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

  String _mapAccessibility(String value) {
    switch (value) {
      case 'Friends only':
        return 'private';
      case 'Public':
      default:
        return 'public';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickJobDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedJobDeadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedJobDeadline != null
          ? TimeOfDay.fromDateTime(_selectedJobDeadline!)
          : TimeOfDay.now(),
    );
    if (pickedTime == null || !mounted) return;

    final DateTime deadline = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedJobDeadline = deadline;
      _jobDeadlineController.text = _formatDeadline(deadline);
    });
  }

  String _formatDeadline(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
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
                              'Tap untuk pilih satu atau beberapa gambar',
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
                            separatorBuilder:
                                (BuildContext context, int index) =>
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
              child: Text(
                _selectedImages.isEmpty
                    ? 'Kamu bisa pilih lebih dari 1 gambar.'
                    : '${_selectedImages.length} gambar dipilih. Tap ikon + untuk menambah lagi.',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
                      options: const <String>['Public', 'Friends only'],
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                selectedAccessibility == 'Friends only'
                    ? 'Friends only berarti hanya akun yang saling follow dengan kamu yang bisa melihat postingan ini.'
                    : 'Public berarti semua pengguna yang punya akses ke feed bisa melihat postingan ini.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.4,
                ),
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
                      hint: 'Deadline lamaran',
                      height: 52,
                      readOnly: true,
                      onTap: _pickJobDeadline,
                      trailing: const Icon(
                        Icons.schedule,
                        color: Colors.white70,
                        size: 18,
                      ),
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
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 18,
          ),
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
    this.readOnly = false,
    this.onTap,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final double height;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget textInput = TextField(
      controller: controller,
      maxLines: height <= 60 ? 1 : null,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        border: InputBorder.none,
        isCollapsed: true,
      ),
    );

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: textInput),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Padding(padding: const EdgeInsets.only(top: 1), child: trailing!),
          ],
        ],
      ),
    );
  }
}
