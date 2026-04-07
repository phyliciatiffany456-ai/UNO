import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'full_name': fullName,
      },
    );
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
        'target_email': email,
        'new_password': newPassword,
      },
    );

    if (result is bool) return result;
    return false;
  }
}
