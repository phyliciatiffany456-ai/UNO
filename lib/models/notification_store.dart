import 'package:flutter/foundation.dart';

class SystemNotice {
  const SystemNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
}

class NotificationStore {
  static final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(false);
  static final ValueNotifier<List<SystemNotice>> systemNotices =
      ValueNotifier<List<SystemNotice>>(<SystemNotice>[]);
  static DateTime _lastReadAt = DateTime.now();
  static final Set<String> _knownNoticeIds = <String>{};

  static void markRead() {
    _lastReadAt = DateTime.now();
    hasUnread.value = false;
  }

  static void markUnread() {
    hasUnread.value = true;
  }

  static void pushSystemNotice({
    required String id,
    required String title,
    required String message,
  }) {
    if (_knownNoticeIds.contains(id)) return;
    _knownNoticeIds.add(id);
    final List<SystemNotice> next = List<SystemNotice>.from(systemNotices.value)
      ..insert(
        0,
        SystemNotice(
          id: id,
          title: title,
          message: message,
          createdAt: DateTime.now(),
        ),
      );
    systemNotices.value = next;
    markUnread();
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
