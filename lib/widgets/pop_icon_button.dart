import 'package:flutter/material.dart';

class PopIconButton extends StatefulWidget {
  const PopIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    this.activeIcon,
    this.activeColor,
    this.toggle = true,
    this.onTap,
  });

  final IconData icon;
  final IconData? activeIcon;
  final Color color;
  final Color? activeColor;
  final double size;
  final bool toggle;
  final ValueChanged<bool>? onTap;

  @override
  State<PopIconButton> createState() => _PopIconButtonState();
}

class _PopIconButtonState extends State<PopIconButton> {
  bool _active = false;
  bool _pop = false;

  void _handleTap() {
    setState(() {
      if (widget.toggle) {
        _active = !_active;
      }
      _pop = true;
    });
    widget.onTap?.call(_active);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _pop = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pop ? 1.2 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Icon(
          _active ? (widget.activeIcon ?? widget.icon) : widget.icon,
          color: _active ? (widget.activeColor ?? widget.color) : widget.color,
          size: widget.size,
        ),
      ),
    );
  }
}

class CreateNavButton extends StatefulWidget {
  const CreateNavButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<CreateNavButton> createState() => _CreateNavButtonState();
}

class _CreateNavButtonState extends State<CreateNavButton> {
  bool _pop = false;

  void _handleTap() {
    setState(() {
      _pop = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _pop = false;
      });
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pop ? 1.14 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
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
      ),
    );
  }
}
