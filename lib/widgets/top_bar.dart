import 'package:flutter/material.dart';

import '../models/notification_store.dart';
import 'pop_icon_button.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.onNotificationTap, this.onSearchTap});

  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 0),
      child: SizedBox(
        height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Text(
                'uno',
                style: TextStyle(
                  color: Color(0xFFFF6A2D),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Row(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: NotificationStore.hasUnread,
                  builder: (
                    BuildContext context,
                    bool hasUnread,
                    Widget? child,
                  ) {
                    return _AnimatedNotificationButton(
                      hasUnread: hasUnread,
                      onTap: () {
                        NotificationStore.markRead();
                        onNotificationTap?.call();
                      },
                    );
                  },
                ),
                const Spacer(),
                PopIconButton(
                  icon: Icons.search,
                  color: Colors.white,
                  size: 20,
                  toggle: false,
                  onTap: (_) => onSearchTap?.call(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedNotificationButton extends StatefulWidget {
  const _AnimatedNotificationButton({required this.hasUnread, this.onTap});

  final bool hasUnread;
  final VoidCallback? onTap;

  @override
  State<_AnimatedNotificationButton> createState() =>
      _AnimatedNotificationButtonState();
}

class _AnimatedNotificationButtonState
    extends State<_AnimatedNotificationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = _controller.value;
          return Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none, color: Colors.white, size: 19),
                if (widget.hasUnread)
                  Positioned(
                    right: -1,
                    top: 1,
                    child: Container(
                      width: 8 + (t * 2),
                      height: 8 + (t * 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFF3EA5FF,
                        ).withValues(alpha: 0.75 - (t * 0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3EA5FF,
                            ).withValues(alpha: 0.7 - (t * 0.35)),
                            blurRadius: 8 + (t * 4),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
