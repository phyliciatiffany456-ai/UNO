import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleMeetCreateResult {
  const GoogleMeetCreateResult({
    required this.meetingLink,
    this.spaceName,
  });

  final String meetingLink;
  final String? spaceName;
}

class GoogleMeetService {
  GoogleMeetService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<GoogleMeetCreateResult> createMeeting({
    required String title,
  }) async {
    dynamic data;
    try {
      final FunctionResponse response = await _client.functions.invoke(
        'create-google-meet',
        body: <String, dynamic>{
          'title': title.trim(),
        },
      );
      data = response.data;
    } catch (error) {
      throw Exception(_readableError(error));
    }

    if (data is! Map) {
      throw Exception('Response Google Meet tidak valid.');
    }

    final String meetingLink = (data['meetingUri'] as String?)?.trim() ?? '';
    if (meetingLink.isEmpty) {
      final String? functionError = (data['error'] as String?)?.trim();
      if (functionError != null && functionError.isNotEmpty) {
        throw Exception(functionError);
      }
      throw Exception('Meeting link dari Google Meet kosong.');
    }

    return GoogleMeetCreateResult(
      meetingLink: meetingLink,
      spaceName: (data['spaceName'] as String?)?.trim(),
    );
  }

  String _readableError(Object error) {
    final String raw = error.toString();
    final String lower = raw.toLowerCase();

    final bool isFetchFailure =
        lower.contains('failed to fetch') ||
        lower.contains('clientexception') ||
        lower.contains('/functions/v1/create-google-meet');

    if (isFetchFailure) {
      return 'Function Google Meet belum bisa diakses. Biasanya karena Edge Function `create-google-meet` belum dideploy, project Supabase sedang pause, atau browser gagal menjangkau endpoint function.';
    }

    final bool isNotFoundFailure =
        lower.contains('status code 404') || lower.contains('404 not found');

    if (isNotFoundFailure) {
      return 'Edge Function `create-google-meet` tidak ditemukan di project Supabase ini. Pastikan function itu sudah dideploy ke project yang sama.';
    }

    if (lower.contains('google meet belum dikonfigurasi') ||
        lower.contains('google_client_id') ||
        lower.contains('google_client_secret') ||
        lower.contains('google_refresh_token')) {
      return 'Secret Google Meet di Supabase belum lengkap. Pastikan GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, dan GOOGLE_REFRESH_TOKEN sudah tersimpan.';
    }

    if (lower.contains('gagal mengambil access token google')) {
      return 'Google token gagal dibuat. Biasanya refresh token, client ID, atau client secret tidak cocok.';
    }

    if (lower.contains('gagal membuat google meet space')) {
      return 'Google Meet API menolak request. Cek apakah Google Meet API aktif dan scope OAuth yang dipakai benar.';
    }

    return raw.replaceFirst('Exception: ', '');
  }
}
