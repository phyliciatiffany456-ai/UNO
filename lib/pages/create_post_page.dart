import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/pop_icon_button.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool hideLikeAndViewCount = true;
  bool turnOffCommenting = true;

  void _goHome() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 14),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 12, 8),
              child: Row(
                children: [
                  PopIconButton(
                    icon: Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                    toggle: false,
                  ),
                  Spacer(),
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
                  PopIconButton(
                    icon: Icons.search,
                    color: Colors.white,
                    size: 22,
                    toggle: false,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Text(
                    'Postingan Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Spacer(),
                  PopIconButton(
                    icon: Icons.add,
                    color: Colors.white,
                    size: 34,
                    toggle: false,
                  ),
                ],
              ),
            ),
            Container(
              height: 320,
              width: double.infinity,
              color: const Color(0xFFC8C8C8),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Expanded(child: _CreateField(label: 'Kategori')),
                  SizedBox(width: 10),
                  Expanded(child: _CreateField(label: 'Accessibility')),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: _DescriptionField(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _ToggleRow(
                label: 'Hide like and view counts on this post',
                value: hideLikeAndViewCount,
                onChanged: (bool value) {
                  setState(() {
                    hideLikeAndViewCount = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _ToggleRow(
                label: 'Turn off commenting',
                value: turnOffCommenting,
                onChanged: (bool value) {
                  setState(() {
                    turnOffCommenting = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF130D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'POST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentTab: NavTab.create,
        onHomeTap: _goHome,
      ),
    );
  }
}

class _CreateField extends StatelessWidget {
  const _CreateField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: const Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Deskripsi',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFFF1E13),
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
