import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRoomItem {
  const ChatRoomItem({
    required this.id,
    required this.name,
    required this.isGroup,
    this.roomCode,
    this.memberCount = 0,
    this.createdBy,
  });

  final String id;
  final String name;
  final bool isGroup;
  final String? roomCode;
  final int memberCount;
  final String? createdBy;
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
  static const String _groupCodeChars =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  User? get currentUser => _client.auth.currentUser;

  Future<List<ChatRoomItem>> fetchMyRooms() async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> memberRows = await _client
        .from('chat_room_members')
        .select('room_id,chat_rooms(id,name,is_group,created_by,room_code)')
        .eq('user_id', user.id);

    final List<String> roomIds = memberRows
        .map((Map<String, dynamic> row) => row['room_id'].toString())
        .where((String id) => id.isNotEmpty && id != 'null')
        .toList();
    final Map<String, int> memberCounts = await _fetchMemberCounts(roomIds);

    return memberRows.map((Map<String, dynamic> row) {
      final Map<String, dynamic> room =
          row['chat_rooms'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final String roomId = room['id'].toString();
      return ChatRoomItem(
        id: roomId,
        name: (room['name'] as String?)?.trim().isNotEmpty == true
            ? room['name'].toString()
            : 'Chat',
        isGroup: room['is_group'] as bool? ?? false,
        roomCode: (room['room_code'] as String?)?.trim().isNotEmpty == true
            ? room['room_code'].toString()
            : null,
        memberCount: memberCounts[roomId] ?? 0,
        createdBy: room['created_by']?.toString(),
      );
    }).toList();
  }

  Future<List<ChatRoomItem>> fetchMyGroupRooms() async {
    final List<ChatRoomItem> rooms = await fetchMyRooms();
    final List<ChatRoomItem> groups = rooms
        .where((ChatRoomItem room) => room.isGroup)
        .toList();
    groups.sort((ChatRoomItem a, ChatRoomItem b) => a.name.compareTo(b.name));
    return groups;
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

  Future<String> ensureDirectRoomWithUser({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final User user = _requireUser();
    if (otherUserId == user.id) {
      throw Exception('Tidak bisa membuat room chat dengan diri sendiri.');
    }
    final dynamic result = await _client.rpc(
      'ensure_direct_room',
      params: <String, dynamic>{
        'target_user_id': otherUserId,
        'target_room_name': otherUserName.trim().isEmpty
            ? 'Direct Chat'
            : otherUserName.trim(),
      },
    );
    return result.toString();
  }

  Future<String> createGroupRoom({required String name}) async {
    _requireUser();
    final dynamic result = await _client.rpc(
      'create_group_room',
      params: <String, dynamic>{
        'target_room_name': name.trim().isEmpty ? 'Grup Baru' : name.trim(),
        'member_ids': <String>[],
      },
    );
    final String roomId = result.toString();
    await _assignRandomGroupCode(roomId);
    return roomId;
  }

  Future<void> joinGroupByCode(String roomCode) async {
    _requireUser();
    final String normalizedCode = roomCode.trim();
    if (normalizedCode.isEmpty) {
      throw Exception('Kode grup wajib diisi.');
    }
    try {
      await _client.rpc(
        'join_group_by_code',
        params: <String, dynamic>{'target_room_code': normalizedCode},
      );
    } on PostgrestException catch (error) {
      if (error.message.contains('group_not_found')) {
        throw Exception('Kode grup tidak ditemukan.');
      }
      rethrow;
    }
  }

  Future<Map<String, int>> _fetchMemberCounts(List<String> roomIds) async {
    if (roomIds.isEmpty) return <String, int>{};
    final List<Map<String, dynamic>> rows = await _client
        .from('chat_room_members')
        .select('room_id')
        .inFilter('room_id', roomIds);
    final Map<String, int> counts = <String, int>{};
    for (final Map<String, dynamic> row in rows) {
      final String roomId = row['room_id'].toString();
      counts[roomId] = (counts[roomId] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _assignRandomGroupCode(String roomId) async {
    for (int attempt = 0; attempt < 8; attempt += 1) {
      final String code = _generateRandomGroupCode();
      final List<Map<String, dynamic>> existing = await _client
          .from('chat_rooms')
          .select('id')
          .eq('room_code', code)
          .limit(1);
      if (existing.isNotEmpty) {
        continue;
      }

      await _client
          .from('chat_rooms')
          .update(<String, dynamic>{'room_code': code})
          .eq('id', roomId);
      return;
    }
    throw Exception('Gagal membuat kode grup acak. Coba lagi.');
  }

  String _generateRandomGroupCode() {
    final DateTime now = DateTime.now();
    int seed = now.microsecondsSinceEpoch ^ now.millisecondsSinceEpoch;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 6; i += 1) {
      seed = (seed * 1664525 + 1013904223) & 0x7fffffff;
      buffer.write(_groupCodeChars[seed % _groupCodeChars.length]);
    }
    return buffer.toString();
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
        .map(
          (List<Map<String, dynamic>> rows) => rows.map(_mapMessage).toList(),
        );
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
      createdAt:
          DateTime.tryParse(row['created_at'].toString()) ??
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
