import 'package:flutter/material.dart';

import '../models/story_item.dart';
import '../widgets/app_button.dart';
import '../widgets/expandable_text.dart';
import '../widgets/profile_ring_avatar.dart';
import 'chat_box_page.dart';
import 'post_zoom_page.dart';
import 'story_viewer_page.dart';

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
  bool _following = true;

  List<String> get _posts {
    switch (widget.name) {
      case 'TiffanyPhylicia':
        return <String>[
          'Insight: Portofolio yang kuat bukan cuma visual bagus, tapi proses problem solving yang jelas.',
          'Weekly design notes: sebelum finalize UI, selalu validasi flow dengan user scenario.',
          'Lagi eksperimen component library yang rapi biar handoff ke dev lebih cepat.',
        ];
      case 'fajar.engineer':
        return <String>[
          'Short: Flutter tip hari ini, pisahkan widget reusable dari awal supaya scaling lebih gampang.',
          'Tips debugging: cek state lifecycle dulu sebelum nyalahin API.',
        ];
      case 'NexaTech Careers':
        return <String>[
          'Loker: Flutter Developer (Remote). Butuh pengalaman state management dan integrasi API.',
          'Open role: UI Engineer hybrid Jakarta, kolaborasi langsung bareng product team.',
        ];
      default:
        return <String>[
          '${widget.name} belum banyak posting, tapi aktif berbagi update profesional.',
        ];
    }
  }

  Future<void> _openStory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(story: StoryItem(label: widget.name)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _viewedStory = true;
    });
  }

  Future<void> _openShareSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bagikan Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _ShareTile(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp',
                  subtitle: 'Kirim profil ke WhatsApp',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
                _ShareTile(
                  icon: Icons.copy_outlined,
                  title: 'Copy Link',
                  subtitle: 'Salin link profil',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileRingAvatar(
                label: widget.name,
                size: 80,
                viewed: _viewedStory,
                onTap: _openStory,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.role,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ProfileStat(
                          label: 'Postingan',
                          value: '${_posts.length}',
                        ),
                        const _ProfileStat(label: 'Pengikut', value: '4.2K'),
                        const _ProfileStat(label: 'Mengikuti', value: '173'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExpandableText(
            text: widget.bio,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _following ? 'Mengikuti' : 'Ikuti',
                  onTap: () {
                    setState(() {
                      _following = !_following;
                    });
                  },
                  variant: _following
                      ? AppButtonVariant.outline
                      : AppButtonVariant.primary,
                  height: 32,
                  fontSize: 12,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppButton(
                  label: 'Chat',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChatBoxPage(),
                    ),
                  ),
                  variant: AppButtonVariant.outline,
                  height: 32,
                  fontSize: 12,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppButton(
                  label: 'Bagikan Profil',
                  onTap: _openShareSheet,
                  variant: AppButtonVariant.outline,
                  height: 32,
                  fontSize: 12,
                  borderRadius: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Postingan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ..._posts.map((String text) => _PostItemCard(text: text)),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostItemCard extends StatelessWidget {
  const _PostItemCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const PostZoomPage())),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF13151A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF24262E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 130,
                width: double.infinity,
                child: ColoredBox(color: Color(0xFFC8C8C8)),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1013),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D313B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
