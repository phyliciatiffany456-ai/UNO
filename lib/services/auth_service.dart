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
}
