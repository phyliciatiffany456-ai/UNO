import 'package:flutter/material.dart';

import '../models/story_item.dart';
import '../widgets/pop_icon_button.dart';

class StoryViewerPage extends StatelessWidget {
  const StoryViewerPage({super.key, required this.story});

  final StoryItem story;

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
                    story.label,
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      minHeight: 2.5,
                      value: 1,
                      color: Colors.white,
                      backgroundColor: Color(0x55FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Short dari ${story.label}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 20),
              child: Row(
                children: [
                  Expanded(child: _ReplyField()),
                  SizedBox(width: 10),
                  PopIconButton(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    color: Colors.white,
                    activeColor: Color(0xFFFF3B30),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  PopIconButton(
                    icon: Icons.send_outlined,
                    activeIcon: Icons.send,
                    color: Colors.white,
                    activeColor: Color(0xFF93C5FD),
                    size: 20,
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

class _ReplyField extends StatelessWidget {
  const _ReplyField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: const Text(
        'Balas short...',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
