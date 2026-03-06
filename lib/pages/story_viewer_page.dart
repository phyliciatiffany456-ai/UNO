import 'dart:async';

import 'package:flutter/material.dart';

import '../models/story_item.dart';
import '../widgets/pop_icon_button.dart';

class StoryViewerPage extends StatefulWidget {
  const StoryViewerPage({super.key, required this.story});

  final StoryItem story;

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  static const Duration _shortDuration = Duration(seconds: 30);

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _commentListKey =
      GlobalKey<AnimatedListState>();
  final List<String> _comments = <String>[];

  late final PageController _pageController;
  late final List<String> _shorts;
  Timer? _timer;
  int _currentShort = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _shorts = <String>[
      'Short dari ${widget.story.label}',
      '${widget.story.label} lagi share tips kerja cepat',
      '${widget.story.label} lagi update project terbaru',
    ];
    _startShortTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _startShortTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_shortDuration, (_) {
      if (!mounted) return;
      if (_currentShort >= _shorts.length - 1) {
        Navigator.of(context).pop();
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
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
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF121417),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.story.label,
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
                  Container(
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
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentShort = index;
                          });
                          _startShortTimer();
                        },
                        itemCount: _shorts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Text(
                                _shorts[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
