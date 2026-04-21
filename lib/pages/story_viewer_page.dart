import 'dart:async';

import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../models/story_item.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../widgets/pop_icon_button.dart';

class StoryViewerPage extends StatefulWidget {
  const StoryViewerPage({super.key, required this.story});

  final StoryItem story;

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  static const Duration _shortDuration = Duration(seconds: 8);
  final PostService _postService = PostService();
  final ProfileService _profileService = ProfileService();

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _commentListKey =
      GlobalKey<AnimatedListState>();
  final List<String> _comments = <String>[];

  late final PageController _pageController;
  List<PostItem> _shorts = <PostItem>[];
  Timer? _timer;
  int _currentShort = 0;
  bool _loading = true;
  String _authorName = 'User';
  String? _authorAvatarUrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadShorts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadShorts() async {
    final String? authorId = widget.story.authorId;
    final String fallbackName = widget.story.label.trim().isEmpty
        ? 'User'
        : widget.story.label.trim();
    if (authorId == null) {
      if (!mounted) return;
      setState(() {
        _shorts = <PostItem>[];
        _loading = false;
        _authorName = fallbackName;
        _authorAvatarUrl = widget.story.avatarUrl;
      });
      return;
    }

    try {
      final profile = await _profileService.fetchProfileByUserId(authorId);
      final List<PostItem> shorts = await _postService.fetchShortPostsByAuthor(
        authorId,
      );
      if (!mounted) return;
      final String resolvedName = shorts.isNotEmpty
          ? shorts.first.name
          : (profile?.fullName.trim().isNotEmpty == true
                ? profile!.fullName
                : fallbackName);
      final String? resolvedAvatarUrl = shorts.isNotEmpty
          ? shorts.first.avatarUrl
          : profile?.avatarUrl;
      setState(() {
        _shorts = shorts;
        _loading = false;
        _authorName = resolvedName;
        _authorAvatarUrl = resolvedAvatarUrl?.trim().isNotEmpty == true
            ? resolvedAvatarUrl
            : widget.story.avatarUrl;
      });
      if (shorts.isNotEmpty) {
        _startShortTimer();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _authorName = fallbackName;
        _authorAvatarUrl = widget.story.avatarUrl;
      });
    }
  }

  void _startShortTimer() {
    _timer?.cancel();
    _timer = Timer(_shortDuration, () {
      if (!mounted) return;
      _goToNextShort();
    });
  }

  void _goToNextShort() {
    if (_shorts.isEmpty || _currentShort >= _shorts.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goToPreviousShort() {
    if (_shorts.isEmpty) return;
    if (_currentShort <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _handleStoryTap(TapUpDetails details, BoxConstraints constraints) {
    final double tapX = details.localPosition.dx;
    final double split = constraints.maxWidth * 0.35;
    if (tapX <= split) {
      _goToPreviousShort();
      return;
    }
    if (tapX >= constraints.maxWidth - split) {
      _goToNextShort();
    }
  }

  void _submitReply() {
    final String value = _replyController.text.trim();
    if (value.isEmpty) return;
    _replyController.clear();
    _replyFocusNode.unfocus();
    _comments.insert(0, value);
    _commentListKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090C),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: _authorAvatarUrl?.isNotEmpty == true
                        ? NetworkImage(_authorAvatarUrl!)
                        : null,
                    child: _authorAvatarUrl?.isNotEmpty == true
                        ? null
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF121417),
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  PopIconButton(
                    icon: Icons.close,
                    color: Colors.white,
                    size: 22,
                    toggle: false,
                    onTap: (_) => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List<Widget>.generate(_shorts.length, (int index) {
                  final bool active = index == _currentShort;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index == _shorts.length - 1 ? 0 : 4,
                      ),
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : const Color(0x55FFFFFF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (TapUpDetails details) =>
                            _handleStoryTap(details, constraints),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF334155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _loading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _shorts.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Belum ada short di database.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  )
                                : PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (int index) {
                                      setState(() {
                                        _currentShort = index;
                                      });
                                      _startShortTimer();
                                    },
                                    itemCount: _shorts.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final PostItem short = _shorts[index];
                                          final String? image =
                                              short.imageUrls.isNotEmpty
                                              ? short.imageUrls.first
                                              : null;
                                          return Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              if (image != null)
                                                Image.network(
                                                  image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        BuildContext context,
                                                        Object error,
                                                        StackTrace? stackTrace,
                                                      ) => const ColoredBox(
                                                        color: Color(
                                                          0xFF243042,
                                                        ),
                                                      ),
                                                )
                                              else
                                                const ColoredBox(
                                                  color: Color(0xFF243042),
                                                ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.black.withValues(
                                                        alpha: 0.1,
                                                      ),
                                                      Colors.black.withValues(
                                                        alpha: 0.7,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                      ),
                                                  child: Text(
                                                    short.content,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 26,
                    right: 26,
                    bottom: 8,
                    child: SizedBox(
                      height: 120,
                      child: AnimatedList(
                        key: _commentListKey,
                        reverse: true,
                        initialItemCount: _comments.length,
                        itemBuilder:
                            (
                              BuildContext context,
                              int index,
                              Animation<double> animation,
                            ) {
                              return SizeTransition(
                                sizeFactor: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.4),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xA6000000),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: const Color(0x22FFFFFF),
                                          ),
                                        ),
                                        child: Text(
                                          _comments[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      focusNode: _replyFocusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitReply(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Balas short...',
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF12151B),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6A2D),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopIconButton(
                    icon: Icons.send_outlined,
                    activeIcon: Icons.send,
                    color: Colors.white,
                    activeColor: const Color(0xFF93C5FD),
                    size: 20,
                    onTap: (_) => _submitReply(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
