import 'package:flutter/material.dart';

import '../models/story_item.dart';
import '../widgets/bottom_nav.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'create_post_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'story_viewer_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCreate(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreatePostPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            InkWell(
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const HomePage()),
                (Route<dynamic> route) => false,
              ),
              child: const Text(
                'uno',
                style: TextStyle(
                  color: Color(0xFFFF6A2D),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  hintText: 'Cari user, short, atau loker',
                  hintStyle: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                  suffixIcon: const Icon(Icons.search, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF6A2D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF6A2D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SearchTile(
              username: 'TiffanyPhylicia',
              text: 'Lorem Ipsum dolor sim amet...',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StoryViewerPage(
                      story: StoryItem(label: 'TiffanyPhylicia'),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.home,
        onHomeTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
        ),
        onApplyTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ApplyPage())),
        onCreateTap: () => _openCreate(context),
        onCommunityTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CommunityPage())),
        onProfileTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({
    required this.username,
    required this.text,
    required this.onTap,
  });

  final String username;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: Row(
          children: [
            const CircleAvatar(radius: 13, backgroundColor: Color(0xFFFF1010)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$username *',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.local_fire_department,
              color: Color(0xFFFFA84D),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
