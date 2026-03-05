enum PostType { insight, short, job }

class PostItem {
  const PostItem({
    required this.name,
    required this.role,
    required this.content,
    required this.type,
    required this.withImage,
    this.imageDots = 3,
    this.canApply = false,
    this.isFollowed = true,
  });

  final String name;
  final String role;
  final String content;
  final PostType type;
  final bool withImage;
  final int imageDots;
  final bool canApply;
  final bool isFollowed;
}
