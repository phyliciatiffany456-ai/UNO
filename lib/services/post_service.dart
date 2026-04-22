import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_item.dart';
import 'social_service.dart';

class PostService {
  PostService({
    SupabaseClient? client,
    Random? random,
    SocialService? socialService,
  }) : _client = client ?? Supabase.instance.client,
       _random = random ?? Random.secure(),
       _socialService = socialService ?? SocialService(client: client);

  static const String postsTable = 'posts';
  static const String postImagesBucket = 'post-images';

  final SupabaseClient _client;
  final Random _random;
  final SocialService _socialService;

  User? get currentUser => _client.auth.currentUser;

  Future<List<PostItem>> fetchFeed() async {
    final List<Map<String, dynamic>> rows = await _client
        .from(postsTable)
        .select()
        .order('created_at', ascending: false);
    final List<String> authorIds = rows
        .map((Map<String, dynamic> row) => row['author_id'].toString())
        .toSet()
        .toList();
    final List<String> postIds = rows
        .map((Map<String, dynamic> row) => row['id'].toString())
        .toList();
    final Map<String, PostEngagement> engagements = await _safeFetchEngagements(
      postIds,
    );
    final Set<String> followingIds = await _safeFetchFollowingIds();
    final Map<String, Map<String, dynamic>> profilesByAuthorId =
        await _safeFetchProfilesByUserId(authorIds);

    return rows
        .map(
          (Map<String, dynamic> row) => _mapPost(
            row,
            engagements[row['id'].toString()],
            followingIds,
            profilesByAuthorId[row['author_id'].toString()],
          ),
        )
        .toList();
  }

  Future<List<PostItem>> fetchShortPostsByAuthor(String authorId) async {
    final String oneDayAgo = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String();
    final List<Map<String, dynamic>> rows = await _client
        .from(postsTable)
        .select()
        .eq('author_id', authorId)
        .eq('category', 'short')
        .gte('created_at', oneDayAgo)
        .order('created_at', ascending: true);
    return rows
        .map(
          (Map<String, dynamic> row) => _mapPost(row, null, <String>{}, null),
        )
        .toList();
  }

  Future<void> createPost({
    required String content,
    required PostType type,
    required String accessibility,
    required List<XFile> images,
    bool hideLikeAndViewCount = false,
    bool turnOffCommenting = false,
    String? jobTitle,
    String? jobLocation,
    String? jobDomicile,
    String? jobRequirements,
    DateTime? jobDeadline,
  }) async {
    final User user = _requireUser();
    final List<String> imageUrls = <String>[];

    for (final XFile image in images) {
      final String path = _buildStoragePath(user.id, image.name);
      final Uint8List bytes = await image.readAsBytes();
      await _client.storage
          .from(postImagesBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _contentTypeFromName(image.name),
            ),
          );
      imageUrls.add(_client.storage.from(postImagesBucket).getPublicUrl(path));
    }

    final Map<String, dynamic>? profile = await _fetchProfileByUserId(user.id);

    final Map<String, dynamic> payload = <String, dynamic>{
      'author_id': user.id,
      'author_name': _authorNameFromUser(user, profile),
      'author_role': _authorRoleFromUser(user, profile),
      'content': content,
      'category': PostItem.typeToDb(type),
      'accessibility': accessibility.toLowerCase(),
      'hide_like_view_count': hideLikeAndViewCount,
      'turn_off_commenting': turnOffCommenting,
      'image_urls': imageUrls,
      'can_apply': type == PostType.job,
    };

    if (type == PostType.job) {
      payload.addAll(<String, dynamic>{
        'job_title': _nullIfEmpty(jobTitle),
        'job_location': _nullIfEmpty(jobLocation),
        'job_domicile': _nullIfEmpty(jobDomicile),
        'job_requirements': _nullIfEmpty(jobRequirements),
        'job_deadline': jobDeadline?.toIso8601String(),
      });
    }

    await _client.from(postsTable).insert(payload);
  }

  PostItem _mapPost(
    Map<String, dynamic> row,
    PostEngagement? engagement,
    Set<String> followingIds,
    Map<String, dynamic>? profile,
  ) {
    final PostType type = PostItem.parseType(
      (row['category'] as String?) ?? 'insight',
    );
    final dynamic rawUrls = row['image_urls'];
    final List<String> imageUrls = rawUrls is List
        ? rawUrls.map((dynamic url) => url.toString()).toList()
        : <String>[];

    return PostItem(
      id: row['id'].toString(),
      authorId: row['author_id'].toString(),
      name: _displayName(row, profile),
      role: _displayRole(row, profile),
      avatarUrl: _displayAvatarUrl(profile),
      content: (row['content'] as String?)?.trim() ?? '',
      type: type,
      imageUrls: imageUrls,
      canApply: row['can_apply'] as bool? ?? false,
      isFollowed: followingIds.contains(row['author_id'].toString()),
      hasStory: type == PostType.short,
      likeCount: engagement?.likeCount ?? 0,
      commentCount: engagement?.commentCount ?? 0,
      shareCount: engagement?.shareCount ?? 0,
      isLiked: engagement?.isLikedByMe ?? false,
      isShared: engagement?.isSharedByMe ?? false,
      jobTitle: _nullIfEmpty(row['job_title']?.toString()),
      jobLocation: _nullIfEmpty(row['job_location']?.toString()),
      jobDomicile: _nullIfEmpty(row['job_domicile']?.toString()),
      jobRequirements: _nullIfEmpty(row['job_requirements']?.toString()),
      jobDeadline: DateTime.tryParse((row['job_deadline'] as String?) ?? ''),
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? ''),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _fetchProfilesByUserId(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return <String, Map<String, dynamic>>{};

    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('user_id,full_name,role,avatar_url')
        .inFilter('user_id', userIds);

    return <String, Map<String, dynamic>>{
      for (final Map<String, dynamic> row in rows)
        row['user_id'].toString(): row,
    };
  }

  Future<Map<String, dynamic>?> _fetchProfileByUserId(String userId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('user_id,full_name,role,avatar_url')
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Map<String, PostEngagement>> _safeFetchEngagements(
    List<String> postIds,
  ) async {
    try {
      return await _socialService.getPostEngagementMap(postIds);
    } catch (_) {
      return <String, PostEngagement>{};
    }
  }

  Future<Set<String>> _safeFetchFollowingIds() async {
    try {
      return await _socialService.getFollowingIds();
    } catch (_) {
      return <String>{};
    }
  }

  Future<Map<String, Map<String, dynamic>>> _safeFetchProfilesByUserId(
    List<String> userIds,
  ) async {
    try {
      return await _fetchProfilesByUserId(userIds);
    } catch (_) {
      return <String, Map<String, dynamic>>{};
    }
  }

  String _displayName(Map<String, dynamic> row, Map<String, dynamic>? profile) {
    final String? profileName = profile?['full_name']?.toString().trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }

    final String? postName = (row['author_name'] as String?)?.trim();
    if (postName != null && postName.isNotEmpty) {
      return postName;
    }

    return 'User';
  }

  String _displayRole(Map<String, dynamic> row, Map<String, dynamic>? profile) {
    final String? profileRole = profile?['role']?.toString().trim();
    if (profileRole != null && profileRole.isNotEmpty) {
      return profileRole;
    }

    final String? postRole = (row['author_role'] as String?)?.trim();
    if (postRole != null && postRole.isNotEmpty) {
      return postRole;
    }

    return 'Role';
  }

  String? _displayAvatarUrl(Map<String, dynamic>? profile) {
    final String? avatarUrl = profile?['avatar_url']?.toString().trim();
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }
    return avatarUrl;
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
    final int randomPart = _random.nextInt(1000000000);
    return '$userId/$now-$randomPart$extension';
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

  String _authorNameFromUser(User user, Map<String, dynamic>? profile) {
    final String? profileName = profile?['full_name']?.toString().trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }

    final Map<String, dynamic> metadata =
        user.userMetadata ?? <String, dynamic>{};
    return (metadata['full_name'] as String?)?.trim().isNotEmpty == true
        ? metadata['full_name'].toString()
        : (user.email ?? 'User');
  }

  String _authorRoleFromUser(User user, Map<String, dynamic>? profile) {
    final String? profileRole = profile?['role']?.toString().trim();
    if (profileRole != null && profileRole.isNotEmpty) {
      return profileRole;
    }

    final Map<String, dynamic> metadata =
        user.userMetadata ?? <String, dynamic>{};
    return (metadata['role'] as String?)?.trim().isNotEmpty == true
        ? metadata['role'].toString()
        : 'Role';
  }

  String? _nullIfEmpty(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}
