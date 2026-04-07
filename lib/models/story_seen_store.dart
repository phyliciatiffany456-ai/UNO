class StorySeenStore {
  StorySeenStore._();

  static final Set<String> _seenKeys = <String>{};

  static bool isSeen({String? authorId, String? label}) {
    final String key = _key(authorId: authorId, label: label);
    if (key.isEmpty) return false;
    return _seenKeys.contains(key);
  }

  static void markSeen({String? authorId, String? label}) {
    final String key = _key(authorId: authorId, label: label);
    if (key.isEmpty) return;
    _seenKeys.add(key);
  }

  static String _key({String? authorId, String? label}) {
    if (authorId != null && authorId.trim().isNotEmpty) {
      return 'id:${authorId.trim()}';
    }
    if (label != null && label.trim().isNotEmpty) {
      return 'label:${label.trim().toLowerCase()}';
    }
    return '';
  }
}
