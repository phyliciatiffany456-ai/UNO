import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../pages/job_apply_page.dart';
import '../pages/story_viewer_page.dart';
import 'app_button.dart';
import 'expandable_text.dart';
import 'pop_icon_button.dart';

class FeedPost extends StatefulWidget {
  const FeedPost({super.key, required this.post});

  final PostItem post;

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  late bool _isFollowed;
  late bool _isStoryViewed;
  late int _likeCount;
  late int _commentCount;
  late int _shareCount;
  bool _liked = false;
  bool _commented = false;
  bool _shared = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.post.isFollowed;
    _isStoryViewed = false;
    _likeCount = 24;
    _commentCount = 3;
    _shareCount = 1;
  }

  @override
  Widget build(BuildContext context) {
    final PostItem post = widget.post;
    return Container(
      color: const Color(0xFF13151A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _storyAvatar,
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        post.role,
                        style: const TextStyle(
                          color: Color(0xFF9BA0A6),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _typeColor(post.type)),
                  ),
                  child: Text(
                    _typeLabel(post.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (!_isFollowed)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _isFollowed = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0B0F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  color: const Color(0xFF20242B),
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 16,
                  ),
                  itemBuilder: (BuildContext context) => const [
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Text(
                        'Laporkan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value != 'report') return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Postingan dilaporkan'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ExpandableText(
              text: post.content,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
          if (post.imageCount > 0) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: post.imageCount,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Container(color: const Color(0xFFCFCFCF));
                    },
                  ),
                  if (post.imageCount > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildDots(post.imageCount),
                      ),
                    ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _EngagementButton(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? const Color(0xFFFF3B30) : Colors.white,
                  count: _likeCount,
                  onTap: () {
                    setState(() {
                      _liked = !_liked;
                      _likeCount += _liked ? 1 : -1;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _EngagementButton(
                  icon: _commented
                      ? Icons.mode_comment
                      : Icons.mode_comment_outlined,
                  color: _commented ? const Color(0xFF7DD3FC) : Colors.white,
                  count: _commentCount,
                  onTap: () {
                    setState(() {
                      _commented = !_commented;
                      _commentCount += _commented ? 1 : -1;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _EngagementButton(
                  icon: _shared ? Icons.send : Icons.send_outlined,
                  color: _shared ? const Color(0xFF93C5FD) : Colors.white,
                  count: _shareCount,
                  onTap: () {
                    setState(() {
                      _shared = !_shared;
                      _shareCount += _shared ? 1 : -1;
                    });
                  },
                ),
                const Spacer(),
                const PopIconButton(
                  icon: Icons.bookmark_border,
                  activeIcon: Icons.bookmark,
                  color: Colors.white,
                  activeColor: Color(0xFFF4A640),
                  size: 18,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (post.canApply)
                      SizedBox(
                        width: 78,
                        child: AppButton(
                          label: 'Apply',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => JobApplyPage(company: post.name),
                              ),
                            );
                          },
                          height: 28,
                          fontSize: 11,
                          borderRadius: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                ExpandableText(
                  text: post.content,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _typeLabel(PostType type) {
    switch (type) {
      case PostType.insight:
        return 'Insight';
      case PostType.short:
        return 'Short';
      case PostType.job:
        return 'Loker';
    }
  }

  Color _typeColor(PostType type) {
    switch (type) {
      case PostType.insight:
        return const Color(0xFFFF4B4B);
      case PostType.short:
        return const Color(0xFF42A5F5);
      case PostType.job:
        return const Color(0xFFFF2B2B);
    }
  }

  List<Widget> _buildDots(int totalImages) {
    final int visibleCount = totalImages <= 5 ? totalImages : 5;

    int windowStart = 0;
    int activeDotIndex = _currentImageIndex;

    if (totalImages > 5) {
      if (_currentImageIndex <= 3) {
        windowStart = 0;
        activeDotIndex = _currentImageIndex;
      } else if (_currentImageIndex >= totalImages - 1) {
        windowStart = totalImages - 5;
        activeDotIndex = 4;
      } else {
        // Keep active indicator at the 4th dot while sliding in middle pages.
        windowStart = _currentImageIndex - 3;
        activeDotIndex = 3;
      }
    }

    return List<Widget>.generate(visibleCount, (int i) {
      final int imageIndex = windowStart + i;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: _Dot(active: imageIndex == _currentImageIndex || i == activeDotIndex),
      );
    });
  }

  Widget get _storyAvatar {
    final PostItem post = widget.post;
    final bool withStoryRing = post.hasStory;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: withStoryRing
          ? () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoryViewerPage(
                    story: StoryItem(label: post.name, isViewed: false),
                  ),
                ),
              );
              if (!mounted) return;
              setState(() {
                _isStoryViewed = true;
              });
            }
          : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: withStoryRing
              ? (_isStoryViewed
                    ? const LinearGradient(
                        colors: [Color(0xFF6B7280), Color(0xFF6B7280)],
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0xFFFEDA75),
                          Color(0xFFFA7E1E),
                          Color(0xFFD62976),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ))
              : null,
          color: withStoryRing ? null : Colors.white,
        ),
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0F1013),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 10, color: Color(0xFF121417)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  const _EngagementButton({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : const Color(0xFFB7B7B7),
      ),
    );
  }
}
