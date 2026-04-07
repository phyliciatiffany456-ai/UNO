import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:image_picker/image_picker.dart';

class ProfileRecord {
  const ProfileRecord({
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.pronoun,
    required this.gender,
    required this.education,
    required this.workExperience,
    required this.role,
    this.avatarUrl,
  });

  final String userId;
  final String fullName;
  final String bio;
  final String pronoun;
  final String gender;
  final String education;
  final String workExperience;
  final String role;
  final String? avatarUrl;
}

class ProfileService {
  ProfileService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Random _random = Random.secure();

  User? get currentUser => _client.auth.currentUser;

  Future<ProfileRecord> fetchMyProfile() async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .limit(1);

    if (rows.isNotEmpty) {
      return _map(rows.first, fallbackName: _nameFromUser(user));
    }

    await _client.from('profiles').upsert(<String, dynamic>{
      'user_id': user.id,
      'full_name': _nameFromUser(user),
      'role': 'UNO Member',
    }, onConflict: 'user_id');

    final List<Map<String, dynamic>> fallback = await _client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .limit(1);
    return _map(fallback.first, fallbackName: _nameFromUser(user));
  }

  Future<ProfileRecord?> fetchProfileByUserId(String userId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    return _map(rows.first, fallbackName: 'User');
  }

  Future<void> upsertMyProfile({
    required String fullName,
    required String bio,
    required String pronoun,
    required String gender,
    required String education,
    required String workExperience,
    required String role,
    String? avatarUrl,
  }) async {
    final User user = _requireUser();
    final Map<String, dynamic> payload = <String, dynamic>{
      'user_id': user.id,
      'full_name': fullName.trim().isEmpty ? _nameFromUser(user) : fullName.trim(),
      'bio': bio.trim(),
      'pronoun': pronoun.trim(),
      'gender': gender.trim(),
      'education': education.trim(),
      'work_experience': workExperience.trim(),
      'role': role.trim().isEmpty ? 'UNO Member' : role.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarUrl != null) {
      payload['avatar_url'] = avatarUrl.trim();
    }
    await _client.from('profiles').upsert(payload, onConflict: 'user_id');

    await _client.auth.updateUser(
      UserAttributes(
        data: <String, dynamic>{
          'full_name': fullName.trim(),
          'bio': bio.trim(),
          'role': role.trim().isEmpty ? 'UNO Member' : role.trim(),
          if (avatarUrl != null) 'avatar_url': avatarUrl.trim(),
        },
      ),
    );
  }

  Future<String> uploadMyAvatar(XFile file) async {
    final User user = _requireUser();
    final Uint8List bytes = await file.readAsBytes();
    final String extension = _extension(file.name);
    final String path =
        '${user.id}/avatar-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(100000)}$extension';
    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentType(extension),
          ),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  ProfileRecord _map(Map<String, dynamic> row, {required String fallbackName}) {
    return ProfileRecord(
      userId: row['user_id'].toString(),
      fullName: (row['full_name'] as String?)?.trim().isNotEmpty == true
          ? row['full_name'].toString()
          : fallbackName,
      bio: (row['bio'] as String?)?.trim().isNotEmpty == true
          ? row['bio'].toString()
          : 'Belum ada bio.',
      pronoun: (row['pronoun'] as String?)?.trim().isNotEmpty == true
          ? row['pronoun'].toString()
          : 'Ms.',
      gender: (row['gender'] as String?)?.trim().isNotEmpty == true
          ? row['gender'].toString()
          : 'Perempuan',
      education: (row['education'] as String?)?.trim().isNotEmpty == true
          ? row['education'].toString()
          : '-',
      workExperience:
          (row['work_experience'] as String?)?.trim().isNotEmpty == true
              ? row['work_experience'].toString()
              : '-',
      role: (row['role'] as String?)?.trim().isNotEmpty == true
          ? row['role'].toString()
          : 'UNO Member',
      avatarUrl: (row['avatar_url'] as String?)?.trim().isNotEmpty == true
          ? row['avatar_url'].toString()
          : null,
    );
  }

  String _nameFromUser(User user) {
    final Map<String, dynamic> metadata = user.userMetadata ?? <String, dynamic>{};
    return (metadata['full_name'] as String?)?.trim().isNotEmpty == true
        ? metadata['full_name'].toString()
        : (user.email ?? 'User');
  }

  User _requireUser() {
    final User? user = currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }
    return user;
  }

  String _extension(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '.jpg';
    final String ext = fileName.substring(dot).toLowerCase();
    if (ext.length > 10) return '.jpg';
    return ext;
  }

  String _contentType(String ext) {
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
