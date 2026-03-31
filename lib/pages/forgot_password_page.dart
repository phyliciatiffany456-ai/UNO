import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_ui.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link reset password sudah dikirim ke email kamu.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      subtitle: 'Masukkan email akun kamu untuk reset password.',
      bottomPrompt: 'Ingat password?',
      bottomActionText: 'Kembali Login',
      onBottomActionTap: () => AppRoutes.goLogin(context),
      form: AuthCard(
        title: 'Lupa Password',
        children: [
          AuthInputField(
            label: 'Email',
            controller: _emailController,
            hintText: 'contoh: tiffany@uno.app',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Kirim Link Reset',
            onTap: _sendResetLink,
            height: 44,
            fontSize: 15,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
