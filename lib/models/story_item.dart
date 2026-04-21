class StoryItem {
  const StoryItem({
    required this.label,
    this.authorId,
    this.avatarUrl,
    this.isMine = false,
    this.isViewed = false,
  });

  final String label;
  final String? authorId;
  final String? avatarUrl;
  final bool isMine;
  final bool isViewed;

  StoryItem copyWith({
    String? label,
    String? authorId,
    String? avatarUrl,
    bool? isMine,
    bool? isViewed,
  }) {
    return StoryItem(
      label: label ?? this.label,
      authorId: authorId ?? this.authorId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMine: isMine ?? this.isMine,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
