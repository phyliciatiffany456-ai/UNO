import 'package:flutter/foundation.dart';

class NotificationStore {
  static final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(true);

  static void markRead() {
    hasUnread.value = false;
  }

  static void markUnread() {
    hasUnread.value = true;
  }
}
