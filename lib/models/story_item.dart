class StoryItem {
  const StoryItem({
    required this.label,
    this.authorId,
    this.avatarUrl,
    this.storyIds = const <String>[],
    this.isMine = false,
    this.isViewed = false,
  });

  final String label;
  final String? authorId;
  final String? avatarUrl;
  final List<String> storyIds;
  final bool isMine;
  final bool isViewed;

  StoryItem copyWith({
    String? label,
    String? authorId,
    String? avatarUrl,
    List<String>? storyIds,
    bool? isMine,
    bool? isViewed,
  }) {
    return StoryItem(
      label: label ?? this.label,
      authorId: authorId ?? this.authorId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storyIds: storyIds ?? this.storyIds,
      isMine: isMine ?? this.isMine,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
