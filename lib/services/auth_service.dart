import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_switch_service.dart';

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client,
        _accountSwitchService =
            AccountSwitchService(client: client ?? Supabase.instance.client);

  final SupabaseClient _client;
  final AccountSwitchService _accountSwitchService;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: _normalizeEmail(email),
      password: password,
    );
    await _accountSwitchService.registerCurrentSession();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _client.auth.signUp(
      email: _normalizeEmail(email),
      password: password,
      data: <String, dynamic>{
        'full_name': fullName,
      },
    );
    await _accountSwitchService.registerCurrentSession(displayName: fullName);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<bool> resetPasswordDirect({
    required String email,
    required String newPassword,
  }) async {
    final dynamic result = await _client.rpc(
      'prototype_reset_password_by_email',
      params: <String, dynamic>{
        'target_email': _normalizeEmail(email),
        'new_password': newPassword,
      },
    );

    if (result is bool) return result;
    return false;
  }

  Future<void> changePasswordWithOldPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.auth.signInWithPassword(
      email: _normalizeEmail(email),
      password: oldPassword,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    await _client.auth.signOut();
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String readableError(Object error) {
    if (error is AuthException) {
      final String message = error.message.trim();
      if (message.isNotEmpty &&
          message != 'AuthRetryableFetchException' &&
          message != 'AuthUnknownException') {
        return message;
      }
    }

    final String raw = error.toString();
    final String lower = raw.toLowerCase();

    final bool isFetchFailure =
        lower.contains('failed to fetch') ||
        lower.contains('clientexception') ||
        lower.contains('unable to connect') ||
        lower.contains('authretryablefetchexception');

    if (isFetchFailure) {
      return 'Koneksi ke server Supabase gagal. Cek internet, status project Supabase, dan pastikan URL/key yang dipakai masih aktif.';
    }

    final bool isNotFoundFailure =
        lower.contains('status code 404') ||
        lower.contains('empty response with status code 404') ||
        lower.contains('404 not found');

    if (isNotFoundFailure) {
      return 'Endpoint Supabase tidak ditemukan. Biasanya ini berarti SUPABASE_URL salah, project Supabase berbeda dari key yang dipakai, atau project sedang tidak aktif.';
    }

    if (lower.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }

    return 'Terjadi kesalahan. Coba lagi sebentar.';
  }
}
