import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRoomItem {
  const ChatRoomItem({
    required this.id,
    required this.name,
    required this.isGroup,
  });

  final String id;
  final String name;
  final bool isGroup;
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
}

class ChatService {
  ChatService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<List<ChatRoomItem>> fetchMyRooms() async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> memberRows = await _client
        .from('chat_room_members')
        .select('room_id,chat_rooms(id,name,is_group)')
        .eq('user_id', user.id);

    return memberRows.map((Map<String, dynamic> row) {
      final Map<String, dynamic> room =
          row['chat_rooms'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return ChatRoomItem(
        id: room['id'].toString(),
        name: (room['name'] as String?)?.trim().isNotEmpty == true
            ? room['name'].toString()
            : 'Chat',
        isGroup: room['is_group'] as bool? ?? false,
      );
    }).toList();
  }

  Future<String> ensureGlobalCommunityRoom() async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> existing = await _client
        .from('chat_rooms')
        .select('id')
        .eq('name', 'Komunitas UNO')
        .eq('is_group', true)
        .limit(1);

    String roomId;
    if (existing.isNotEmpty) {
      roomId = existing.first['id'].toString();
    } else {
      final Map<String, dynamic> created = await _client
          .from('chat_rooms')
          .insert(<String, dynamic>{'name': 'Komunitas UNO', 'is_group': true})
          .select('id')
          .single();
      roomId = created['id'].toString();
    }

    await _client.from('chat_room_members').upsert(<String, dynamic>{
      'room_id': roomId,
      'user_id': user.id,
    }, onConflict: 'room_id,user_id');

    return roomId;
  }

  Future<List<ChatMessageItem>> fetchMessages(String roomId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at');
    return rows.map(_mapMessage).toList();
  }

  Stream<List<ChatMessageItem>> watchMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: <String>['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((List<Map<String, dynamic>> rows) =>
            rows.map(_mapMessage).toList());
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
  }) async {
    final User user = _requireUser();
    final String trimmed = content.trim();
    if (trimmed.isEmpty) return;

    await _client.from('chat_messages').insert(<String, dynamic>{
      'room_id': roomId,
      'sender_id': user.id,
      'content': trimmed,
    });
  }

  ChatMessageItem _mapMessage(Map<String, dynamic> row) {
    return ChatMessageItem(
      id: row['id'].toString(),
      roomId: row['room_id'].toString(),
      senderId: row['sender_id'].toString(),
      content: row['content'].toString(),
      createdAt: DateTime.tryParse(row['created_at'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  User _requireUser() {
    final User? user = currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }
    return user;
  }
}
