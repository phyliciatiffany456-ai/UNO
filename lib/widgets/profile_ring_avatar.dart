import 'package:flutter/material.dart';

class ProfileRingAvatar extends StatelessWidget {
  const ProfileRingAvatar({
    super.key,
    required this.label,
    required this.viewed,
    this.onTap,
    this.size = 84,
    this.showAdd = false,
    this.onAddTap,
  });

  final String label;
  final bool viewed;
  final VoidCallback? onTap;
  final double size;
  final bool showAdd;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final Gradient ringGradient = viewed
        ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF6B7280)])
        : const LinearGradient(
            colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final double innerDark = size - 8;
    final double innerLight = size - 16;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(size),
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ringGradient,
              ),
              child: Center(
                child: Container(
                  width: innerDark,
                  height: innerDark,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F1013),
                  ),
                  child: Center(
                    child: Container(
                      width: innerLight,
                      height: innerLight,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5E7EB),
                      ),
                      child: Center(
                        child: Text(
                          _initials(label),
                          style: TextStyle(
                            color: const Color(0xFF121417),
                            fontSize: size * 0.19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showAdd)
            Positioned(
              right: -1,
              bottom: -1,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onAddTap,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D9BFF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F1013),
                      width: 2.2,
                    ),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
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
