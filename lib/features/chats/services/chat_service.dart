
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bychat/features/chats/models/chat_message_model.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesCollection(
      String chatId,
      ) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  /// Real-time messages for one conversation.
  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    return _messagesCollection(chatId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return ChatMessageModel.fromMap(
          document.data(),
          id: document.id,
        );
      }).toList();
    });
  }

  /// Real-time conversations for the logged-in user.
  Stream<List<Map<String, dynamic>>> watchConversations(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final conversations = snapshot.docs.map((document) {
        return <String, dynamic>{
          ...document.data(),
          'chatId': document.id,
        };
      }).toList();

      // Sort locally so this query does not require an orderBy index.
      conversations.sort((a, b) {
        final aTime = _dateFromFirestore(a['updatedAt']);
        final bTime = _dateFromFirestore(b['updatedAt']);
        return bTime.compareTo(aTime);
      });

      return conversations;
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final messageText = text.trim();

    if (chatId.trim().isEmpty) {
      throw ArgumentError('Chat ID cannot be empty.');
    }

    if (senderId.trim().isEmpty || receiverId.trim().isEmpty) {
      throw ArgumentError('Sender ID and receiver ID are required.');
    }

    if (senderId == receiverId) {
      throw ArgumentError('A user cannot message themselves.');
    }

    if (messageText.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    final chatDocument = _firestore.collection('chats').doc(chatId);
    final messageDocument = _messagesCollection(chatId).doc();

    final message = ChatMessageModel(
      id: messageDocument.id,
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: messageText,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();

    // Conversation metadata makes this chat appear on the Home Screen.
    batch.set(
      chatDocument,
      {
        'participants': [senderId, receiverId],
        'lastMessage': messageText,
        'lastMessageSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(messageDocument, message.toMap());

    await batch.commit();
  }

  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    if (chatId.trim().isEmpty || messageId.trim().isEmpty) {
      throw ArgumentError('Chat ID and message ID are required.');
    }

    await _messagesCollection(chatId)
        .doc(messageId)
        .update({'isRead': true});
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
