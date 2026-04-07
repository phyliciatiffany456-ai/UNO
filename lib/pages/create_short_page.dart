import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../models/post_item.dart';
import '../services/post_service.dart';

class CreateShortPage extends StatefulWidget {
  const CreateShortPage({super.key});

  @override
  State<CreateShortPage> createState() => _CreateShortPageState();
}

class _CreateShortPageState extends State<CreateShortPage> {
  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _image;
  bool _posting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _image = picked;
    });
  }

  Future<void> _submit() async {
    final String caption = _captionController.text.trim();
    if (caption.isEmpty) {
      _show('Caption short wajib diisi.');
      return;
    }

    setState(() {
      _posting = true;
    });
    try {
      await _postService.createPost(
        content: caption,
        type: PostType.short,
        accessibility: 'public',
        hideLikeAndViewCount: true,
        turnOffCommenting: false,
        images: _image != null ? <XFile>[_image!] : <XFile>[],
      );
      if (!mounted) return;
      _show('Short berhasil dibagikan.');
      Navigator.of(context).pop(true);
    } catch (e) {
      _show('Gagal upload short: $e');
    } finally {
      if (mounted) {
        setState(() {
          _posting = false;
        });
      }
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        title: const Text(
          'Tambah Short',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _posting ? null : _pickImage,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E24),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: _image == null
                    ? const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FutureBuilder<Uint8List>(
                          future: _image!.readAsBytes(),
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<Uint8List> snapshot,
                          ) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis caption short...',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x44FFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6A2D)),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _posting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_posting ? 'Mengunggah...' : 'Bagikan Short'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
