import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusScope.of(context).unfocus();
    AppRoutes.goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      subtitle: 'Bikin akun baru untuk mulai bangun relasi profesionalmu.',
      bottomPrompt: 'Sudah punya akun?',
      bottomActionText: 'Masuk',
      onBottomActionTap: () => AppRoutes.goLogin(context),
      form: AuthCard(
        title: 'Register',
        children: [
          AuthInputField(
            label: 'Nama Lengkap',
            controller: _nameController,
            hintText: 'contoh: Tiffany Phylicia',
          ),
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Email',
            controller: _emailController,
            hintText: 'contoh: tiffany@uno.app',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Password',
            controller: _passwordController,
            hintText: 'Buat password',
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
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Konfirmasi Password',
            controller: _confirmPasswordController,
            hintText: 'Ulangi password',
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Buat Akun',
            onTap: _handleRegister,
            height: 44,
            fontSize: 16,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
