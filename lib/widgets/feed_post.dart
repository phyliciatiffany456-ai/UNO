import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/post_item.dart';
import '../models/saved_post_store.dart';
import '../models/story_seen_store.dart';
import '../models/story_item.dart';
import '../pages/chat_profile_info_page.dart';
import '../pages/job_apply_page.dart';
import '../pages/saved_posts_page.dart';
import '../pages/story_viewer_page.dart';
import '../services/social_service.dart';
import 'app_button.dart';
import 'expandable_text.dart';
import 'pop_icon_button.dart';
import 'story_ring_avatar.dart';

class FeedPost extends StatefulWidget {
  const FeedPost({
    super.key,
    required this.post,
    required this.hasStory,
    this.openSavedPageOnSave = true,
  });

  final PostItem post;
  final bool hasStory;
  final bool openSavedPageOnSave;

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  final SocialService _socialService = SocialService();

  late bool _isFollowed;
  late bool _isStoryViewed;
  late int _likeCount;
  late int _commentCount;
  late int _shareCount;
  bool _liked = false;
  bool _commented = false;
  bool _shared = false;
  bool _saved = false;
  int _currentImageIndex = 0;

  void _openOwnerProfile(PostItem post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatProfileInfoPage(
          name: post.name,
          userId: post.authorId,
          role: post.role,
          bio: _ownerBio(post),
        ),
      ),
    );
  }

  String _ownerBio(PostItem post) {
    switch (post.name) {
      case 'TiffanyPhylicia':
        return 'Suka bangun produk digital dan kolaborasi bareng tim lintas divisi.';
      case 'fajar.engineer':
        return 'Mobile engineer yang fokus di arsitektur Flutter, clean code, dan performance.';
      case 'NexaTech Careers':
        return 'Akun resmi rekrutmen NexaTech untuk update lowongan terbaru.';
      default:
        return 'Aktif berbagi update profesional.';
    }
  }

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.post.isFollowed;
    _isStoryViewed = StorySeenStore.isSeen(
      authorId: widget.post.authorId,
      label: widget.post.name,
    );
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;
    _shareCount = widget.post.shareCount;
    _liked = widget.post.isLiked;
    _shared = widget.post.isShared;
    _saved = SavedPostStore.contains(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final PostItem post = widget.post;
    final bool isOwnPost = _socialService.currentUser?.id == post.authorId;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13151A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF24262E)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _storyAvatar,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _openOwnerProfile(post),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            post.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.role,
                        style: const TextStyle(
                          color: Color(0xFF9BA0A6),
                          fontSize: 11,
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
                if (!_isFollowed &&
                    _socialService.currentUser?.id != post.authorId)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _followUser,
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
                      final String imageUrl = post.imageUrls[index];

                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) => Container(
                              color: const Color(0xFFCFCFCF),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                      );
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
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 12),
                _EngagementButton(
                  icon: _commented
                      ? Icons.mode_comment
                      : Icons.mode_comment_outlined,
                  color: _commented ? const Color(0xFF7DD3FC) : Colors.white,
                  count: _commentCount,
                  onTap: _addComment,
                ),
                const SizedBox(width: 12),
                _EngagementButton(
                  icon: _shared ? Icons.send : Icons.send_outlined,
                  color: _shared ? const Color(0xFF93C5FD) : Colors.white,
                  count: _shareCount,
                  onTap: _toggleShare,
                ),
                const Spacer(),
                PopIconButton(
                  icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                  activeColor: const Color(0xFFF4A640),
                  size: 18,
                  toggle: false,
                  onTap: (_) => _savePost(),
                ),
              ],
            ),
          ),
          if (post.canApply && !isOwnPost)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      post.jobTitle?.trim().isNotEmpty == true
                          ? post.jobTitle!
                          : post.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (post.canApply && !isOwnPost)
                    SizedBox(
                      width: 90,
                      child: AppButton(
                        label: 'Apply',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => JobApplyPage(post: post),
                            ),
                          );
                        },
                        height: 34,
                        fontSize: 12,
                        borderRadius: 10,
                      ),
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _followUser() async {
    try {
      await _socialService.followUser(widget.post.authorId);
      if (!mounted) return;
      setState(() {
        _isFollowed = true;
      });
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    final bool next = !_liked;
    setState(() {
      _liked = next;
      _likeCount = (_likeCount + (next ? 1 : -1)).clamp(0, 1000000).toInt();
    });
    try {
      await _socialService.toggleLike(widget.post.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _liked = !next;
        _likeCount = (_likeCount + (next ? -1 : 1)).clamp(0, 1000000).toInt();
      });
    }
  }

  Future<void> _toggleShare() async {
    setState(() {
      _shared = true;
      _shareCount = (_shareCount + 1).clamp(0, 1000000).toInt();
    });

    try {
      await _socialService.sharePost(widget.post.id);
      if (!mounted) return;
      await _openShareSheet();
    } catch (_) {
      if (!mounted) return;
      await _openShareSheet();
    }
  }

  Future<void> _savePost() async {
    SavedPostStore.save(widget.post);
    if (!mounted) return;
    setState(() {
      _saved = true;
    });
    if (!widget.openSavedPageOnSave) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SavedPostsPage()));
    if (!mounted) return;
    setState(() {
      _saved = SavedPostStore.contains(widget.post.id);
    });
  }

  Future<void> _openShareSheet() async {
    final PostItem post = widget.post;
    final String shareText =
        'Lihat postingan dari ${post.name} di UNO:\n\n${post.content}';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bagikan Postingan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _ShareTile(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp',
                  subtitle: 'Kirim postingan ke WhatsApp',
                  onTap: () async {
                    final NavigatorState sheetNavigator = Navigator.of(context);
                    final ScaffoldMessengerState pageMessenger =
                        ScaffoldMessenger.of(this.context);
                    await Clipboard.setData(ClipboardData(text: shareText));
                    if (!context.mounted || !mounted) return;
                    sheetNavigator.pop();
                    pageMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Teks postingan disalin. Tempel di WhatsApp.',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _ShareTile(
                  icon: Icons.copy_outlined,
                  title: 'Copy Link',
                  subtitle: 'Salin teks postingan',
                  onTap: () async {
                    final NavigatorState sheetNavigator = Navigator.of(context);
                    final ScaffoldMessengerState pageMessenger =
                        ScaffoldMessenger.of(this.context);
                    await Clipboard.setData(ClipboardData(text: shareText));
                    if (!context.mounted || !mounted) return;
                    sheetNavigator.pop();
                    pageMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Teks postingan berhasil disalin.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addComment() async {
    final TextEditingController controller = TextEditingController();
    List<PostCommentItem> comments = await _socialService.fetchComments(
      widget.post.id,
    );
    if (!mounted) return;
    setState(() {
      _commentCount = comments.length;
      _commented = comments.isNotEmpty;
    });
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13151A),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> submitComment() async {
              final String text = controller.text.trim();
              if (text.isEmpty) return;
              controller.clear();
              try {
                await _socialService.addComment(
                  postId: widget.post.id,
                  content: text,
                );
                comments = await _socialService.fetchComments(widget.post.id);
                setModalState(() {});
                if (!mounted) return;
                setState(() {
                  _commented = true;
                  _commentCount = comments.length;
                });
              } catch (_) {}
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: SizedBox(
                height: 420,
                child: Column(
                  children: [
                    const Text(
                      'Komentar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: comments.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada komentar.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.separated(
                              itemCount: comments.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (BuildContext context, int index) {
                                final PostCommentItem comment = comments[index];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E1014),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF2D313B),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment.content,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: submitComment,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
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
        child: _Dot(
          active: imageIndex == _currentImageIndex || i == activeDotIndex,
        ),
      );
    });
  }

  Widget get _storyAvatar {
    final PostItem post = widget.post;
    return StoryRingProfileAvatar(
      size: 32,
      hasStory: widget.hasStory,
      viewed: _isStoryViewed,
      label: post.name,
      onTap: widget.hasStory
          ? () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoryViewerPage(
                    story: StoryItem(
                      label: post.name,
                      authorId: post.authorId,
                      isViewed: _isStoryViewed,
                    ),
                  ),
                ),
              );
              StorySeenStore.markSeen(
                authorId: post.authorId,
                label: post.name,
              );
              if (!mounted) return;
              setState(() {
                _isStoryViewed = true;
              });
            }
          : null,
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

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1013),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D313B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
