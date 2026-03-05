import 'package:flutter/material.dart';

import 'pop_icon_button.dart';

enum NavTab { home, apply, create, community, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentTab,
    this.onHomeTap,
    this.onCreateTap,
  });

  final NavTab currentTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0B0F),
        border: Border(top: BorderSide(color: Color(0xFF24262E))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(
            Icons.home_rounded,
            label: 'Home',
            active: currentTab == NavTab.home,
            onTap: onHomeTap,
          ),
          _navIcon(
            Icons.work_outline,
            label: 'Apply',
            active: currentTab == NavTab.apply,
          ),
          CreateNavButton(onTap: onCreateTap ?? () {}),
          _navIcon(
            Icons.groups_outlined,
            label: 'Community',
            active: currentTab == NavTab.community,
          ),
          _navIcon(
            Icons.person_outline,
            label: 'Profile',
            active: currentTab == NavTab.profile,
          ),
        ],
      ),
    );
  }

  Widget _navIcon(
    IconData icon, {
    required String label,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? const Color(0xFFFF4C24)
                    : const Color(0xFF4A4D57),
              ),
            ),
            child: PopIconButton(
              icon: icon,
              color: Colors.white,
              size: 14,
              toggle: false,
              onTap: (_) => onTap?.call(),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }
}
