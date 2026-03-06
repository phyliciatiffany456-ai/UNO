import 'package:flutter/material.dart';

import '../models/story_item.dart';

class Stories extends StatelessWidget {
  const Stories({
    super.key,
    required this.stories,
    required this.onStoryTap,
    this.onMineAddTap,
  });

  final List<StoryItem> stories;
  final ValueChanged<int> onStoryTap;
  final VoidCallback? onMineAddTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: stories.asMap().entries.map((MapEntry<int, StoryItem> entry) {
          final int index = entry.key;
          final StoryItem item = entry.value;
          return StoryBubble(
            label: item.label,
            isMine: item.isMine,
            isViewed: item.isViewed,
            onTap: () => onStoryTap(index),
            onAddTap: item.isMine ? onMineAddTap : null,
          );
        }).toList(),
      ),
    );
  }
}

class StoryBubble extends StatelessWidget {
  const StoryBubble({
    super.key,
    required this.label,
    required this.onTap,
    this.isMine = false,
    this.isViewed = false,
    this.onAddTap,
  });

  final String label;
  final VoidCallback onTap;
  final bool isMine;
  final bool isViewed;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final Gradient ringGradient = isViewed
        ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF6B7280)])
        : const LinearGradient(
            colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return SizedBox(
      width: 76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ringGradient,
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0F1013),
                        ),
                        child: Center(
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE5E7EB),
                            ),
                            child: Center(
                              child: Text(
                                _initials(label),
                                style: const TextStyle(
                                  color: Color(0xFF121417),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isMine)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: onAddTap,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D9BFF),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0F1013),
                                width: 1.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String raw) {
    final List<String> words = raw
        .split(' ')
        .where((String word) => word.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
