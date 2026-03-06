import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class ChatBoxPage extends StatefulWidget {
  const ChatBoxPage({super.key});

  @override
  State<ChatBoxPage> createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chat Box',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Text(
              'uno',
              style: TextStyle(
                color: Color(0xFFFF6A2D),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: Color(0xFFFF2B2B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TiffanyPhylicia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFFA84D),
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _bubble(width: 165, height: 70, alignRight: false),
            const SizedBox(height: 10),
            _bubble(width: 165, height: 70, alignRight: true),
            const SizedBox(height: 10),
            _typingBubble(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFF6A2D)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFE23E6B), Color(0xFFF2A63D)],
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.community,
        onHomeTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
        ),
        onApplyTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ApplyPage())),
        onCreateTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage())),
        onCommunityTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CommunityPage())),
        onProfileTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
      ),
    );
  }

  Widget _bubble({
    required double width,
    required double height,
    required bool alignRight,
  }) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF6A2D)),
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 74,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF6A2D)),
        ),
        child: const Center(
          child: Icon(Icons.more_horiz, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
