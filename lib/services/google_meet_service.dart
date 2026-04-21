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
    final dynamic data = await _client.functions.invoke(
      'create-google-meet',
      body: <String, dynamic>{
        'title': title.trim(),
      },
    );

    if (data is! Map) {
      throw Exception('Response Google Meet tidak valid.');
    }

    final String meetingLink = (data['meetingUri'] as String?)?.trim() ?? '';
    if (meetingLink.isEmpty) {
      throw Exception('Meeting link dari Google Meet kosong.');
    }

    return GoogleMeetCreateResult(
      meetingLink: meetingLink,
      spaceName: (data['spaceName'] as String?)?.trim(),
    );
  }
}
