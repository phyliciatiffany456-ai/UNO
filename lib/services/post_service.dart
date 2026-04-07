import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_item.dart';

class PostService {
  PostService({
    SupabaseClient? client,
    Random? random,
  })  : _client = client ?? Supabase.instance.client,
        _random = random ?? Random.secure();

  static const String postsTable = 'posts';
  static const String postImagesBucket = 'post-images';

  final SupabaseClient _client;
  final Random _random;

  User? get currentUser => _client.auth.currentUser;

  Future<List<PostItem>> fetchFeed() async {
    final List<Map<String, dynamic>> rows = await _client
        .from(postsTable)
        .select()
        .order('created_at', ascending: false);

    return rows.map(_mapPost).toList();
  }

  Future<void> createPost({
    required String content,
    required PostType type,
    required String accessibility,
    required bool hideLikeAndViewCount,
    required bool turnOffCommenting,
    required List<XFile> images,
  }) async {
    final User user = _requireUser();
    final List<String> imageUrls = <String>[];

    for (final XFile image in images) {
      final String path = _buildStoragePath(user.id, image.name);
      final Uint8List bytes = await image.readAsBytes();
      await _client.storage.from(postImagesBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _contentTypeFromName(image.name),
            ),
          );
      imageUrls.add(_client.storage.from(postImagesBucket).getPublicUrl(path));
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'author_id': user.id,
      'author_name': _authorNameFromUser(user),
      'author_role': _authorRoleFromUser(user),
      'content': content,
      'category': PostItem.typeToDb(type),
      'accessibility': accessibility.toLowerCase(),
      'hide_like_view_count': hideLikeAndViewCount,
      'turn_off_commenting': turnOffCommenting,
      'image_urls': imageUrls,
      'can_apply': type == PostType.job,
    };

    await _client.from(postsTable).insert(payload);
  }

  PostItem _mapPost(Map<String, dynamic> row) {
    final dynamic rawUrls = row['image_urls'];
    final List<String> imageUrls = rawUrls is List
        ? rawUrls.map((dynamic url) => url.toString()).toList()
        : <String>[];

    return PostItem(
      id: row['id'].toString(),
      authorId: row['author_id'].toString(),
      name: (row['author_name'] as String?)?.trim().isNotEmpty == true
          ? row['author_name'].toString()
          : 'Unknown',
      role: (row['author_role'] as String?)?.trim().isNotEmpty == true
          ? row['author_role'].toString()
          : 'Member',
      content: (row['content'] as String?)?.trim() ?? '',
      type: PostItem.parseType((row['category'] as String?) ?? 'insight'),
      imageUrls: imageUrls,
      canApply: row['can_apply'] as bool? ?? false,
      isFollowed: true,
      hasStory: true,
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? ''),
    );
  }

  User _requireUser() {
    final User? user = currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }
    return user;
  }

  String _buildStoragePath(String userId, String originalFileName) {
    final String extension = _fileExtension(originalFileName);
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int randomPart = _random.nextInt(1 << 32);
    return 'posts/$userId/$now-$randomPart$extension';
  }

  String _fileExtension(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) {
      return '.jpg';
    }
    final String ext = fileName.substring(dot).toLowerCase();
    if (ext.length > 10) {
      return '.jpg';
    }
    return ext;
  }

  String _contentTypeFromName(String fileName) {
    final String ext = _fileExtension(fileName);
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }

  String _authorNameFromUser(User user) {
    final Map<String, dynamic> metadata = user.userMetadata ?? <String, dynamic>{};
    return (metadata['full_name'] as String?)?.trim().isNotEmpty == true
        ? metadata['full_name'].toString()
        : (user.email ?? 'User');
  }

  String _authorRoleFromUser(User user) {
    final Map<String, dynamic> metadata = user.userMetadata ?? <String, dynamic>{};
    return (metadata['role'] as String?)?.trim().isNotEmpty == true
        ? metadata['role'].toString()
        : 'UNO Member';
  }
}
