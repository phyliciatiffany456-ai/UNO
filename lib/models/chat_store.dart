import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  const ChatMessage({required this.text, required this.fromMe});

  final String text;
  final bool fromMe;
}

class ChatStore {
  static final ValueNotifier<List<ChatMessage>> messages =
      ValueNotifier<List<ChatMessage>>(
        const <ChatMessage>[
          ChatMessage(text: 'Hai, kamu lagi cari tim untuk project?', fromMe: false),
          ChatMessage(text: 'Iya, lagi buka collab buat UI app.', fromMe: true),
        ],
      );

  static void add(String text) {
    final List<ChatMessage> next = List<ChatMessage>.from(messages.value)
      ..add(ChatMessage(text: text, fromMe: true));
    messages.value = next;
  }
}
