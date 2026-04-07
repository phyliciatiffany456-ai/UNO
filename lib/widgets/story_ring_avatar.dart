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
    this.onTap,
  });

  final double size;
  final bool viewed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double middleSize = size - 6;
    final double profileSize = size - 12;
    final double profileRadius = profileSize / 2;
    final double iconSize = profileSize * 0.55;
    return Stack(
      alignment: Alignment.center,
      children: [
        StoryRingAvatar(size: size, viewed: viewed, onTap: onTap),
        Container(
          width: middleSize,
          height: middleSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0F1013),
          ),
          child: Center(
            child: CircleAvatar(
              radius: profileRadius,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Icon(
                Icons.person,
                size: iconSize,
                color: const Color(0xFF121417),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
