import 'package:supabase_flutter/supabase_flutter.dart';

class PostEngagement {
  const PostEngagement({
    required this.postId,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLikedByMe,
    required this.isSharedByMe,
  });

  final String postId;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLikedByMe;
  final bool isSharedByMe;
}

class PostCommentItem {
  const PostCommentItem({
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  final String userId;
  final String userName;
  final String content;
  final DateTime? createdAt;
}

class UserMiniProfile {
  const UserMiniProfile({
    required this.userId,
    required this.name,
    required this.role,
  });

  final String userId;
  final String name;
  final String role;
}

class FollowingSinceRecord {
  const FollowingSinceRecord({
    required this.followingId,
    required this.followedAt,
  });

  final String followingId;
  final DateTime followedAt;
}

class SocialService {
  SocialService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, PostEngagement>> getPostEngagementMap(
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) return <String, PostEngagement>{};

    final List<Map<String, dynamic>> likes = await _client
        .from('post_likes')
        .select('post_id,user_id')
        .inFilter('post_id', postIds);
    final List<Map<String, dynamic>> comments = await _client
        .from('post_comments')
        .select('post_id,id')
        .inFilter('post_id', postIds);
    final List<Map<String, dynamic>> shares = await _client
        .from('post_shares')
        .select('post_id,user_id')
        .inFilter('post_id', postIds);

    final String? myUserId = currentUser?.id;
    final Map<String, int> likeCounts = <String, int>{};
    final Map<String, int> commentCounts = <String, int>{};
    final Map<String, int> shareCounts = <String, int>{};
    final Set<String> likedByMe = <String>{};
    final Set<String> sharedByMe = <String>{};

    for (final Map<String, dynamic> row in likes) {
      final String postId = row['post_id'].toString();
      likeCounts[postId] = (likeCounts[postId] ?? 0) + 1;
      if (myUserId != null && row['user_id']?.toString() == myUserId) {
        likedByMe.add(postId);
      }
    }

    for (final Map<String, dynamic> row in comments) {
      final String postId = row['post_id'].toString();
      commentCounts[postId] = (commentCounts[postId] ?? 0) + 1;
    }

    for (final Map<String, dynamic> row in shares) {
      final String postId = row['post_id'].toString();
      shareCounts[postId] = (shareCounts[postId] ?? 0) + 1;
      if (myUserId != null && row['user_id']?.toString() == myUserId) {
        sharedByMe.add(postId);
      }
    }

    final Map<String, PostEngagement> result = <String, PostEngagement>{};
    for (final String postId in postIds) {
      result[postId] = PostEngagement(
        postId: postId,
        likeCount: likeCounts[postId] ?? 0,
        commentCount: commentCounts[postId] ?? 0,
        shareCount: shareCounts[postId] ?? 0,
        isLikedByMe: likedByMe.contains(postId),
        isSharedByMe: sharedByMe.contains(postId),
      );
    }
    return result;
  }

  Future<void> toggleLike(String postId) async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> existing = await _client
        .from('post_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .limit(1);

    if (existing.isNotEmpty) {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
      return;
    }

    await _client.from('post_likes').insert(<String, dynamic>{
      'post_id': postId,
      'user_id': user.id,
    });
  }

  Future<void> toggleShare(String postId) async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> existing = await _client
        .from('post_shares')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .limit(1);

    if (existing.isNotEmpty) {
      await _client
          .from('post_shares')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
      return;
    }

    await _client.from('post_shares').insert(<String, dynamic>{
      'post_id': postId,
      'user_id': user.id,
    });
  }

  Future<bool> sharePost(String postId) async {
    final User user = _requireUser();

    await _client.from('post_shares').insert(<String, dynamic>{
      'post_id': postId,
      'user_id': user.id,
    });
    return true;
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final User user = _requireUser();
    final String text = content.trim();
    if (text.isEmpty) return;
    await _client.from('post_comments').insert(<String, dynamic>{
      'post_id': postId,
      'user_id': user.id,
      'content': text,
    });
  }

  Future<List<PostCommentItem>> fetchComments(String postId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('post_comments')
        .select('user_id,content,created_at')
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    final List<String> userIds = rows
        .map((Map<String, dynamic> row) => row['user_id'].toString())
        .toSet()
        .toList();
    final List<UserMiniProfile> profiles = await _fetchProfiles(userIds);
    final Map<String, UserMiniProfile> byId = <String, UserMiniProfile>{
      for (final UserMiniProfile item in profiles) item.userId: item,
    };

    return rows.map((Map<String, dynamic> row) {
      final String userId = row['user_id'].toString();
      final UserMiniProfile? profile = byId[userId];
      return PostCommentItem(
        userId: userId,
        userName: profile?.name ?? 'User',
        content: row['content'].toString(),
        createdAt: DateTime.tryParse((row['created_at'] as String?) ?? ''),
      );
    }).toList();
  }

  Future<Set<String>> getFollowingIds() async {
    final User? user = currentUser;
    if (user == null) return <String>{};
    final List<Map<String, dynamic>> rows = await _client
        .from('user_follows')
        .select('following_id')
        .eq('follower_id', user.id);
    return rows
        .map((Map<String, dynamic> row) => row['following_id'].toString())
        .toSet();
  }

  Future<Map<String, DateTime>> getFollowingSinceMap({String? userId}) async {
    final String? followerId = userId ?? currentUser?.id;
    if (followerId == null || followerId.isEmpty) {
      return <String, DateTime>{};
    }

    final List<Map<String, dynamic>> rows = await _client
        .from('user_follows')
        .select('following_id,created_at')
        .eq('follower_id', followerId);

    final Map<String, DateTime> followingSince = <String, DateTime>{};
    for (final Map<String, dynamic> row in rows) {
      final String followingId = row['following_id'].toString();
      final DateTime? followedAt = DateTime.tryParse(
        (row['created_at'] as String?) ?? '',
      );
      if (followedAt != null) {
        followingSince[followingId] = followedAt;
      }
    }
    return followingSince;
  }

  Future<void> followUser(String targetUserId) async {
    final User user = _requireUser();
    if (targetUserId == user.id) return;
    await _client.from('user_follows').upsert(<String, dynamic>{
      'follower_id': user.id,
      'following_id': targetUserId,
    }, onConflict: 'follower_id,following_id');
  }

  Future<void> unfollowUser(String targetUserId) async {
    final User user = _requireUser();
    await _client
        .from('user_follows')
        .delete()
        .eq('follower_id', user.id)
        .eq('following_id', targetUserId);
  }

  Future<Map<String, int>> getFollowStats(String userId) async {
    final List<Map<String, dynamic>> followers = await _client
        .from('user_follows')
        .select('id')
        .eq('following_id', userId);
    final List<Map<String, dynamic>> following = await _client
        .from('user_follows')
        .select('id')
        .eq('follower_id', userId);
    return <String, int>{
      'followers': followers.length,
      'following': following.length,
    };
  }

  Future<List<UserMiniProfile>> getFollowers(String userId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('user_follows')
        .select('follower_id')
        .eq('following_id', userId);
    final List<String> ids =
        rows.map((Map<String, dynamic> row) => row['follower_id'].toString()).toList();
    return _fetchProfiles(ids);
  }

  Future<List<UserMiniProfile>> getFollowing(String userId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('user_follows')
        .select('following_id')
        .eq('follower_id', userId);
    final List<String> ids = rows
        .map((Map<String, dynamic> row) => row['following_id'].toString())
        .toList();
    return _fetchProfiles(ids);
  }

  Future<List<UserMiniProfile>> _fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return <UserMiniProfile>[];
    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('user_id,full_name,role')
        .inFilter('user_id', userIds);
    final Map<String, Map<String, dynamic>> byId = <String, Map<String, dynamic>>{
      for (final Map<String, dynamic> row in rows) row['user_id'].toString(): row,
    };
    return userIds.map((String id) {
      final Map<String, dynamic>? row = byId[id];
      return UserMiniProfile(
        userId: id,
        name: (row?['full_name'] as String?)?.trim().isNotEmpty == true
            ? row!['full_name'].toString()
            : 'User',
        role: (row?['role'] as String?)?.trim().isNotEmpty == true
            ? row!['role'].toString()
            : 'Role',
      );
    }).toList();
  }

  User _requireUser() {
    final User? user = currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }
    return user;
  }
}
