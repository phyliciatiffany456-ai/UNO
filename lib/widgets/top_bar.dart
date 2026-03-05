import 'package:flutter/material.dart';

import 'pop_icon_button.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 8, 12, 0),
      child: Row(
        children: [
          PopIconButton(
            icon: Icons.notifications_none,
            color: Colors.white,
            size: 20,
            toggle: false,
          ),
          SizedBox(width: 10),
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
    );
  }
}
