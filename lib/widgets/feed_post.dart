import 'package:flutter/material.dart';

import '../models/post_item.dart';
import 'pop_icon_button.dart';

class FeedPost extends StatefulWidget {
  const FeedPost({super.key, required this.post});

  final PostItem post;

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  late bool _isFollowed;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.post.isFollowed;
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
                const CircleAvatar(radius: 10, backgroundColor: Colors.white),
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
                const PopIconButton(
                  icon: Icons.more_vert,
                  color: Colors.white,
                  size: 16,
                  toggle: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              post.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
          if (post.withImage) ...[
            const SizedBox(height: 8),
            Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFCFCFCF),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    post.imageDots,
                    (int index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _Dot(active: index == 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                PopIconButton(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  color: Colors.white,
                  activeColor: Color(0xFFFF3B30),
                  size: 18,
                ),
                SizedBox(width: 8),
                PopIconButton(
                  icon: Icons.mode_comment_outlined,
                  activeIcon: Icons.mode_comment,
                  color: Colors.white,
                  activeColor: Color(0xFF7DD3FC),
                  size: 18,
                ),
                SizedBox(width: 8),
                PopIconButton(
                  icon: Icons.send_outlined,
                  activeIcon: Icons.send,
                  color: Colors.white,
                  activeColor: Color(0xFF93C5FD),
                  size: 18,
                ),
                Spacer(),
                PopIconButton(
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
            child: Row(
              children: [
                Text(
                  post.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    post.content,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 9,
                    ),
                  ),
                ),
                if (post.canApply)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2B2B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                      ),
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
