import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'post_item.dart';
import '../services/post_service.dart';

class SavedPostStore {
  static final ValueNotifier<List<PostItem>> savedPosts =
      ValueNotifier<List<PostItem>>(<PostItem>[]);
  static final PostService _postService = PostService();
  static Set<String> _savedIds = <String>{};

  static bool contains(String postId) {
    return _savedIds.contains(postId);
  }

  static Future<void> load({List<PostItem>? feedPosts}) async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _savedIds = <String>{};
      savedPosts.value = <PostItem>[];
      return;
    }

    final List<Map<String, dynamic>> rows = await Supabase.instance.client
        .from('saved_posts')
        .select('post_id')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    _savedIds = rows
        .map((Map<String, dynamic> row) => row['post_id'].toString())
        .toSet();

    final List<PostItem> sourcePosts = feedPosts ?? await _postService.fetchFeed();
    final Map<String, PostItem> byId = <String, PostItem>{
      for (final PostItem post in sourcePosts) post.id: post,
    };

    savedPosts.value = rows
        .map((Map<String, dynamic> row) => byId[row['post_id'].toString()])
        .whereType<PostItem>()
        .toList(growable: false);
  }

  static Future<void> save(PostItem post) async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }
    if (contains(post.id)) return;

    try {
      await Supabase.instance.client.from('saved_posts').insert(<String, dynamic>{
        'post_id': post.id,
        'user_id': user.id,
      });
    } on PostgrestException catch (error) {
      if (error.code != '23505') rethrow;
    }

    _savedIds = <String>{..._savedIds, post.id};
    savedPosts.value = <PostItem>[post, ...savedPosts.value];
  }

  static Future<void> remove(String postId) async {
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }

    await Supabase.instance.client
        .from('saved_posts')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    _savedIds = Set<String>.from(_savedIds)..remove(postId);
    savedPosts.value = savedPosts.value
        .where((PostItem item) => item.id != postId)
        .toList(growable: false);
  }
}
