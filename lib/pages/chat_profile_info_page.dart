import 'package:flutter/material.dart';

import '../widgets/story_ring_avatar.dart';

class ChatProfileInfoPage extends StatefulWidget {
  const ChatProfileInfoPage({
    super.key,
    required this.name,
    this.role = 'Member',
    this.bio = 'Belum ada bio.',
  });

  final String name;
  final String role;
  final String bio;

  @override
  State<ChatProfileInfoPage> createState() => _ChatProfileInfoPageState();
}

class _ChatProfileInfoPageState extends State<ChatProfileInfoPage> {
  bool _viewedStory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoryRingAvatar(
                size: 78,
                viewed: _viewedStory,
                onTap: () {
                  setState(() {
                    _viewedStory = true;
                  });
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.role,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoStat(label: 'Postingan', value: '24'),
                        _InfoStat(label: 'Pengikut', value: '4.2K'),
                        _InfoStat(label: 'Mengikuti', value: '173'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF13151A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF24262E)),
            ),
            child: Text(
              widget.bio,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
