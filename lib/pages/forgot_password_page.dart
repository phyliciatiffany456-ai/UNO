import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_ui.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetDirect() async {
    FocusScope.of(context).unfocus();
    final String email = _emailController.text.trim();
    final String oldPassword = _oldPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Email, password lama, dan password baru wajib diisi.');
      return;
    }
    if (newPassword.length < 6) {
      _showMessage('Password minimal 6 karakter.');
      return;
    }
    if (oldPassword == newPassword) {
      _showMessage('Password baru harus berbeda dari password lama.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage('Konfirmasi password tidak sama.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.changePasswordWithOldPassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;
      _showMessage('Password berhasil diganti. Silakan login.');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        );
      }
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Gagal ganti password. Coba lagi.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      subtitle: 'Ubah password dengan verifikasi email dan password lama.',
      bottomPrompt: 'Ingat password?',
      bottomActionText: 'Kembali Login',
      onBottomActionTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        );
      },
      form: AuthCard(
        title: 'Lupa Password',
        children: [
          AuthInputField(
            label: 'Email',
            controller: _emailController,
            hintText: 'contoh: nama@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Password Lama',
            controller: _oldPasswordController,
            hintText: 'Masukkan password lama',
            obscureText: _obscureOld,
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _obscureOld = !_obscureOld;
                });
              },
              icon: Icon(
                _obscureOld
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Password Baru',
            controller: _newPasswordController,
            hintText: 'Masukkan password baru',
            obscureText: _obscureNew,
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
              icon: Icon(
                _obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AuthInputField(
            label: 'Konfirmasi Password Baru',
            controller: _confirmPasswordController,
            hintText: 'Ulangi password baru',
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _isSubmitting ? 'Memproses...' : 'Ganti Password',
            onTap: _isSubmitting ? null : _resetDirect,
            height: 44,
            fontSize: 15,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
