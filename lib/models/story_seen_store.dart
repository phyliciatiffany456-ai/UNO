import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StorySeenStore {
  StorySeenStore._();

  static const String _seenStoryIdsKey = 'story_seen_ids_v2';
  static bool _initialized = false;
  static final Set<String> _seenStoryIds = <String>{};
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<void> init() async {
    if (_initialized) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _seenStoryIds
      ..clear()
      ..addAll(prefs.getStringList(_seenStoryIdsKey) ?? const <String>[]);
    _initialized = true;
  }

  static bool isStorySeen(String? storyId) {
    if (!_initialized) return false;
    if (storyId == null || storyId.trim().isEmpty) return false;
    return _seenStoryIds.contains(storyId.trim());
  }

  static bool hasSeenAllStoryIds(Iterable<String> storyIds) {
    if (!_initialized) return false;
    final List<String> normalized = storyIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toList();
    if (normalized.isEmpty) return false;
    return normalized.every(_seenStoryIds.contains);
  }

  static Future<void> markStorySeen(String? storyId) async {
    if (!_initialized) {
      await init();
    }
    if (storyId == null || storyId.trim().isEmpty) return;
    final String normalized = storyId.trim();
    if (_seenStoryIds.contains(normalized)) return;
    _seenStoryIds.add(normalized);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenStoryIdsKey, _seenStoryIds.toList());
    changes.value++;
  }
}
