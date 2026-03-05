import 'package:flutter/material.dart';

void main() {
  runApp(const UnoApp());
}

class UnoApp extends StatelessWidget {
  const UnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uno Home',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F1013),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const _TopBar(),
            const SizedBox(height: 12),
            const _Stories(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 10),
                children: const [
                  _FeedPost(
                    name: 'TiffanyPfiyicia',
                    subtitle: '@ never-view Walker',
                    badgeText: 'Insight!',
                  ),
                  SizedBox(height: 10),
                  _FeedPost(
                    name: 'tiffany_pfiyicia',
                    subtitle: 'Lorem Ipsum dolor sit amet..',
                    badgeText: 'About',
                    withQuestion: true,
                  ),
                  SizedBox(height: 10),
                  _FeedPost(
                    name: 'TiffanyPfyicia',
                    subtitle: '@ never-view Walker',
                    badgeText: 'Labor',
                  ),
                ],
              ),
            ),
            const _BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 0),
      child: Row(
        children: const [
          Text(
            'uno',
            style: TextStyle(
              color: Color(0xFFFF6A2D),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          Spacer(),
          Icon(Icons.search, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: const [
          _StoryBubble(label: 'your Story', selected: true),
          _StoryBubble(label: 'tiffanycla...'),
          _StoryBubble(label: 'tiffanyly55'),
          _StoryBubble(label: '#iffoyy_ph...'),
          _StoryBubble(label: 'pii...'),
        ],
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF2F2F2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPost extends StatelessWidget {
  const _FeedPost({
    required this.name,
    required this.subtitle,
    required this.badgeText,
    this.withQuestion = false,
  });

  final String name;
  final String subtitle;
  final String badgeText;
  final bool withQuestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF13151A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const CircleAvatar(radius: 10, backgroundColor: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name  🍓',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF9BA0A6),
                          fontSize: 9,
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
                    border: Border.all(color: Colors.red.shade600),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.more_vert, color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFFCFCFCF),
            alignment: Alignment.bottomCenter,
            child: const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(active: true),
                  SizedBox(width: 5),
                  _Dot(),
                  SizedBox(width: 5),
                  _Dot(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                const Spacer(),
                if (withQuestion)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.2),
                    ),
                    child: const Text(
                      '?',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                    size: 18,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Lorem Ipsum dolor sit amet..',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9),
                  ),
                ),
                if (withQuestion)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0B0F),
        border: Border(top: BorderSide(color: Color(0xFF24262E))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home_rounded, active: true),
          _navIcon(Icons.sms_outlined),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF26A45), Color(0xFFF4A640)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          _navIcon(Icons.group_outlined),
          _navIcon(Icons.person_outline),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, {bool active = false}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? const Color(0xFFFF4C24) : const Color(0xFF4A4D57),
        ),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
