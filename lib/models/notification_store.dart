import 'package:flutter/foundation.dart';

class NotificationStore {
  static final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(false);
  static DateTime _lastReadAt = DateTime.now();

  static void markRead() {
    _lastReadAt = DateTime.now();
    hasUnread.value = false;
  }

  static void markUnread() {
    hasUnread.value = true;
  }

  static void syncWithLatestPost(
    DateTime? latestPostAt, {
    String? latestAuthorId,
    String? currentUserId,
  }) {
    if (latestPostAt == null) {
      hasUnread.value = false;
      return;
    }

    if (currentUserId != null &&
        latestAuthorId != null &&
        latestAuthorId == currentUserId) {
      hasUnread.value = false;
      return;
    }

    hasUnread.value = latestPostAt.isAfter(_lastReadAt);
  }
}
