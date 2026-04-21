import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_ui.dart';
import 'login_page.dart';

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
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    final String fullName = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Nama, email, dan password wajib diisi.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Konfirmasi password tidak sama.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (!mounted) return;
      _showMessage('Registrasi berhasil. Silakan login.');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        );
      }
    } on AuthException catch (error) {
      final String message = error.message.toLowerCase();
      final bool isEmailRateLimited =
          message.contains('email rate limit exceeded') ||
          message.contains('rate limit');
      if (isEmailRateLimited) {
        _showMessage(
          'Pendaftaran dibatasi sementara. Coba login dulu; jika belum bisa, tunggu sebentar lalu ulangi.',
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          );
        }
      } else {
        _showMessage(_authService.readableError(error));
      }
    } catch (error) {
      _showMessage(_authService.readableError(error));
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
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      subtitle: 'Bikin akun baru untuk mulai bangun relasi profesionalmu.',
      bottomPrompt: 'Sudah punya akun?',
      bottomActionText: 'Masuk',
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
            hintText: 'contoh: nama@email.com',
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
            label: _isSubmitting ? 'Memproses...' : 'Buat Akun',
            onTap: _isSubmitting ? null : _handleRegister,
            height: 44,
            fontSize: 16,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
