import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'apply_page.dart';
import 'community_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool hideLikeAndViewCount = true;
  bool turnOffCommenting = true;
  String selectedCategory = 'Insight';
  String selectedAccessibility = 'Public';

  void _goHome() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 14),
          children: [
            TopBar(
              onNotificationTap: _openNotifications,
              onSearchTap: _openSearch,
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
                  Icon(Icons.add, color: Colors.white, size: 30),
                ],
              ),
            ),
            Container(
              height: 320,
              width: double.infinity,
              color: const Color(0xFFC8C8C8),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _CreateDropdownField(
                      label: 'Kategori',
                      value: selectedCategory,
                      options: const <String>[
                        'Insight',
                        'Short',
                        'Loker',
                        'Portofolio',
                      ],
                      onChanged: (String value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CreateDropdownField(
                      label: 'Accessibility',
                      value: selectedAccessibility,
                      options: const <String>['Public', 'Private'],
                      onChanged: (String value) {
                        setState(() {
                          selectedAccessibility = value;
                        });
                      },
                    ),
                  ),
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
                child: SizedBox(
                  width: 110,
                  child: AppButton(
                    label: 'POST',
                    onTap: () {},
                    height: 40,
                    fontSize: 14,
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
        onApplyTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ApplyPage())),
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

class _CreateDropdownField extends StatelessWidget {
  const _CreateDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D00)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          dropdownColor: const Color(0xFF1A1C22),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          isExpanded: true,
          items: options
              .map(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text('$label: $item'),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
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
