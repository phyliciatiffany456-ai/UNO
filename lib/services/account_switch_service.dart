import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KnownAccount {
  const KnownAccount({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.sessionJson,
    required this.lastUsedAt,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String displayName;
  final String sessionJson;
  final DateTime lastUsedAt;
  final String? avatarUrl;

  KnownAccount copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? sessionJson,
    DateTime? lastUsedAt,
    String? avatarUrl,
  }) {
    return KnownAccount(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      sessionJson: sessionJson ?? this.sessionJson,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user_id': userId,
        'email': email,
        'display_name': displayName,
        'session_json': sessionJson,
        'last_used_at': lastUsedAt.toIso8601String(),
        'avatar_url': avatarUrl,
      };

  static KnownAccount? fromJson(Map<String, dynamic> json) {
    final String sessionJson = (json['session_json'] as String?) ?? '';
    final String email = (json['email'] as String?)?.trim() ?? '';
    final String userId = (json['user_id'] as String?)?.trim() ?? '';
    if (sessionJson.isEmpty || email.isEmpty || userId.isEmpty) {
      return null;
    }
    return KnownAccount(
      userId: userId,
      email: email,
      displayName: (json['display_name'] as String?)?.trim().isNotEmpty == true
          ? json['display_name'].toString()
          : email,
      sessionJson: sessionJson,
      lastUsedAt: DateTime.tryParse((json['last_used_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      avatarUrl: (json['avatar_url'] as String?)?.trim().isNotEmpty == true
          ? json['avatar_url'].toString()
          : null,
    );
  }
}

class AccountSwitchService {
  AccountSwitchService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _knownAccountsKey = 'known_accounts_v1';

  final SupabaseClient _client;

  Future<void> registerCurrentSession({
    String? displayName,
    String? avatarUrl,
  }) async {
    final Session? session = _client.auth.currentSession;
    final User? user = _client.auth.currentUser;
    if (session == null || user == null) return;

    final String? email = user.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return;

    final List<KnownAccount> accounts = await loadKnownAccounts();
    final KnownAccount next = KnownAccount(
      userId: user.id,
      email: email,
      displayName: _displayNameFor(
        user: user,
        overrideName: displayName,
      ),
      sessionJson: jsonEncode(session.toJson()),
      lastUsedAt: DateTime.now(),
      avatarUrl: _normalizedAvatar(
        overrideAvatar: avatarUrl,
        metadataAvatar: user.userMetadata?['avatar_url']?.toString(),
      ),
    );

    final int existingIndex = accounts.indexWhere(
      (KnownAccount item) => item.userId == next.userId || item.email == next.email,
    );
    if (existingIndex >= 0) {
      accounts[existingIndex] = next;
    } else {
      accounts.add(next);
    }

    await _saveKnownAccounts(accounts);
  }

  Future<List<KnownAccount>> loadKnownAccounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_knownAccountsKey) ?? <String>[];
    final List<KnownAccount> accounts = raw
        .map((String item) {
          try {
            return KnownAccount.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<KnownAccount>()
        .toList()
      ..sort((KnownAccount a, KnownAccount b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return accounts;
  }

  Future<void> switchToAccount(KnownAccount account) async {
    await _client.auth.recoverSession(account.sessionJson);
    await registerCurrentSession(
      displayName: account.displayName,
      avatarUrl: account.avatarUrl,
    );
  }

  Future<void> removeAccount(String userId) async {
    final List<KnownAccount> accounts = await loadKnownAccounts();
    accounts.removeWhere((KnownAccount item) => item.userId == userId);
    await _saveKnownAccounts(accounts);
  }

  Future<void> _saveKnownAccounts(List<KnownAccount> accounts) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _knownAccountsKey,
      accounts
          .map((KnownAccount item) => jsonEncode(item.toJson()))
          .toList(growable: false),
    );
  }

  String _displayNameFor({
    required User user,
    String? overrideName,
  }) {
    if (overrideName?.trim().isNotEmpty == true) {
      return overrideName!.trim();
    }
    final String? fullName = user.userMetadata?['full_name']?.toString().trim();
    if (fullName?.isNotEmpty == true) return fullName!;
    return user.email ?? 'User';
  }

  String? _normalizedAvatar({
    String? overrideAvatar,
    String? metadataAvatar,
  }) {
    if (overrideAvatar?.trim().isNotEmpty == true) {
      return overrideAvatar!.trim();
    }
    if (metadataAvatar?.trim().isNotEmpty == true) {
      return metadataAvatar!.trim();
    }
    return null;
  }
}
