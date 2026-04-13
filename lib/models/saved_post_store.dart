import 'package:flutter/foundation.dart';

import 'post_item.dart';

class SavedPostStore {
  static final ValueNotifier<List<PostItem>> savedPosts =
      ValueNotifier<List<PostItem>>(<PostItem>[]);

  static bool contains(String postId) {
    return savedPosts.value.any((PostItem item) => item.id == postId);
  }

  static void save(PostItem post) {
    if (contains(post.id)) return;
    savedPosts.value = <PostItem>[post, ...savedPosts.value];
  }

  static void remove(String postId) {
    savedPosts.value = savedPosts.value
        .where((PostItem item) => item.id != postId)
        .toList(growable: false);
  }
}
