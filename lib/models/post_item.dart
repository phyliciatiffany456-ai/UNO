enum PostType { insight, short, job }

class PostItem {
  const PostItem({
    required this.id,
    required this.authorId,
    required this.name,
    required this.role,
    required this.content,
    required this.type,
    this.imageUrls = const <String>[],
    this.canApply = false,
    this.isFollowed = true,
    this.hasStory = true,
    this.createdAt,
  });

  final String id;
  final String authorId;
  final String name;
  final String role;
  final String content;
  final PostType type;
  final List<String> imageUrls;
  final bool canApply;
  final bool isFollowed;
  final bool hasStory;
  final DateTime? createdAt;

  int get imageCount => imageUrls.length;

  static PostType parseType(String raw) {
    switch (raw.toLowerCase()) {
      case 'short':
        return PostType.short;
      case 'job':
        return PostType.job;
      case 'insight':
      default:
        return PostType.insight;
    }
  }

  static String typeToDb(PostType type) {
    switch (type) {
      case PostType.short:
        return 'short';
      case PostType.job:
        return 'job';
      case PostType.insight:
        return 'insight';
    }
  }
}
