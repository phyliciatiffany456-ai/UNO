import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    AppRoutes.goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      subtitle: 'Masuk untuk lanjut networking dan cari peluang baru.',
      bottomPrompt: 'Belum punya akun?',
      bottomActionText: 'Daftar',
      onBottomActionTap: () => AppRoutes.goRegister(context),
      form: AuthCard(
        title: 'Login',
        children: [
          AuthInputField(
            label: 'Email / Username',
            controller: _emailController,
            hintText: 'contoh: tiffany@uno.app',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Password',
            controller: _passwordController,
            hintText: 'Masukkan password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => AppRoutes.goForgotPassword(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                foregroundColor: const Color(0xFFFF9A63),
              ),
              child: const Text(
                'Lupa password?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          AppButton(
            label: 'Masuk',
            onTap: _handleLogin,
            height: 44,
            fontSize: 16,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
