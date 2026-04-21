import 'package:flutter/material.dart';

class StoryRingAvatar extends StatelessWidget {
  const StoryRingAvatar({
    super.key,
    this.size = 42,
    this.viewed = false,
    this.innerColor = const Color(0xFFE5E7EB),
    this.onTap,
  });

  final double size;
  final bool viewed;
  final Color innerColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double innerSize = size - 6;
    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: viewed
              ? const LinearGradient(
                  colors: [Color(0xFF6B7280), Color(0xFF6B7280)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Center(
          child: CircleAvatar(
            radius: innerSize / 2,
            backgroundColor: innerColor,
          ),
        ),
      ),
    );
  }
}

class StoryRingProfileAvatar extends StatelessWidget {
  const StoryRingProfileAvatar({
    super.key,
    this.size = 34,
    this.viewed = false,
    this.hasStory = true,
    this.label = 'User',
    this.imageUrl,
    this.onTap,
  });

  final double size;
  final bool viewed;
  final bool hasStory;
  final String label;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double middleSize = size - 6;
    final double profileSize = size - 12;
    final double iconSize = profileSize * 0.55;
    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasStory
                    ? (viewed
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
                color: hasStory ? null : const Color(0xFF2D313B),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: middleSize,
                height: middleSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F1013),
                ),
                child: Center(
                  child: Container(
                    width: profileSize,
                    height: profileSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5E7EB),
                    ),
                    alignment: Alignment.center,
                    child: (imageUrl?.isNotEmpty == true)
                        ? ClipOval(
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              width: profileSize,
                              height: profileSize,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) => _InitialAvatar(
                                label: label,
                                iconSize: iconSize,
                              ),
                            ),
                          )
                        : _InitialAvatar(label: label, iconSize: iconSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.label, required this.iconSize});

  final String label;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      _initials(label),
      style: TextStyle(
        color: const Color(0xFF121417),
        fontSize: iconSize * 0.52,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  String _initials(String raw) {
    final List<String> words = raw
        .split(' ')
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }
}
