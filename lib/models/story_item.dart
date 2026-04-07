class StoryItem {
  const StoryItem({
    required this.label,
    this.authorId,
    this.isMine = false,
    this.isViewed = false,
  });

  final String label;
  final String? authorId;
  final bool isMine;
  final bool isViewed;

  StoryItem copyWith({
    String? label,
    String? authorId,
    bool? isMine,
    bool? isViewed,
  }) {
    return StoryItem(
      label: label ?? this.label,
      authorId: authorId ?? this.authorId,
      isMine: isMine ?? this.isMine,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
