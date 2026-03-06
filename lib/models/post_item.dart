enum PostType { insight, short, job }

class PostItem {
  const PostItem({
    required this.name,
    required this.role,
    required this.content,
    required this.type,
    this.imageCount = 0,
    this.canApply = false,
    this.isFollowed = true,
    this.hasStory = true,
  });

  final String name;
  final String role;
  final String content;
  final PostType type;
  final int imageCount;
  final bool canApply;
  final bool isFollowed;
  final bool hasStory;
}
