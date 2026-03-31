import 'package:flutter/material.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.subtitle,
    required this.form,
    required this.bottomPrompt,
    required this.bottomActionText,
    required this.onBottomActionTap,
  });

  final String subtitle;
  final Widget form;
  final String bottomPrompt;
  final String bottomActionText;
  final VoidCallback onBottomActionTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF14171D), Color(0xFF0F1013), Color(0xFF0A0B0F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'uno',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFF6A2D),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB7BDC7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    form,
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bottomPrompt,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: onBottomActionTap,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF9A63),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(
                            bottomActionText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF13151A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF24262E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          cursorColor: const Color(0xFFFF6A2D),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF7E8590), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF0E1014),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D313B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF6A2D), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
