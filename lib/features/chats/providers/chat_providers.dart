
import 'package:bychat/features/chats/models/chat_message_model.dart';
import 'package:bychat/features/chats/services/chat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatConversationsProvider =
StreamProvider.family<List<Map<String, dynamic>>, String>(
      (ref, uid) {
    return ref.watch(chatServiceProvider).watchConversations(uid);
  },
);

final chatMessagesProvider =
StreamProvider.family<List<ChatMessageModel>, String>(
      (ref, chatId) {
    return ref.watch(chatServiceProvider).watchMessages(chatId);
  },
);

final chatMessageActionsProvider = Provider<ChatMessageActions>((ref) {
  return ChatMessageActions(ref.watch(chatServiceProvider));
});

class ChatMessageActions {
  const ChatMessageActions(this._chatService);

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
