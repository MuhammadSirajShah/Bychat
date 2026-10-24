
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bychat/features/chats/models/chat_message_model.dart';
import 'package:bychat/features/chats/services/chat_service.dart';

/// Provides the ChatService instance.
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// Streams messages for a specific chat.
final chatMessagesProvider =
StreamProvider.family<List<ChatMessageModel>, String>(
      (ref, chatId) {
    final chatService = ref.watch(chatServiceProvider);
    return chatService.watchMessages(chatId);
  },
);

/// Provides actions for sending messages and marking them as read.
final chatMessageActionsProvider = Provider<ChatMessageActions>((ref) {
  return ChatMessageActions(ref.watch(chatServiceProvider));
});

class ChatMessageActions {
  ChatMessageActions(this._chatService);

  final ChatService _chatService;

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) {
    return _chatService.sendMessage(
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
    );
  }

  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) {
    return _chatService.markMessageAsRead(
      chatId: chatId,
      messageId: messageId,
    );
  }
}
