import 'post_item.dart';

class PostStreak {
  PostStreak._();

  static Map<String, int> buildByAuthor(List<PostItem> posts) {
    final Map<String, Set<DateTime>> postingDaysByAuthor =
        <String, Set<DateTime>>{};

    for (final PostItem post in posts) {
      final DateTime? createdAt = post.createdAt;
      if (createdAt == null) continue;

      final DateTime postingDay = DateTime(
        createdAt.year,
        createdAt.month,
        createdAt.day,
      );
      postingDaysByAuthor.putIfAbsent(post.authorId, () => <DateTime>{}).add(
        postingDay,
      );
    }

    final Map<String, int> streakByAuthor = <String, int>{};
    final DateTime today = _dateOnly(DateTime.now());

    postingDaysByAuthor.forEach((String authorId, Set<DateTime> postingDays) {
      int streak = 0;
      DateTime cursor = today;

      while (postingDays.contains(cursor)) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      }

      if (streak > 0) {
        streakByAuthor[authorId] = streak;
      }
    });

    return streakByAuthor;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
