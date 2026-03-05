class StoryItem {
  const StoryItem({
    required this.label,
    this.isMine = false,
    this.isViewed = false,
  });

  final String label;
  final bool isMine;
  final bool isViewed;

  StoryItem copyWith({String? label, bool? isMine, bool? isViewed}) {
    return StoryItem(
      label: label ?? this.label,
      isMine: isMine ?? this.isMine,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
