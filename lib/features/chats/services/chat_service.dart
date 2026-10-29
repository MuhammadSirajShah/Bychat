
import 'package:bychat/features/chats/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      conversations.sort((a, b) {
        return _dateFromFirestore(b['updatedAt'])
            .compareTo(_dateFromFirestore(a['updatedAt']));
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
    final cleanChatId = chatId.trim();
    final cleanSenderId = senderId.trim();
    final cleanReceiverId = receiverId.trim();
    final messageText = text.trim();

    if (cleanChatId.isEmpty ||
        cleanSenderId.isEmpty ||
        cleanReceiverId.isEmpty ||
        messageText.isEmpty) {
      throw ArgumentError('Chat ID, user IDs and message are required.');
    }

    if (cleanSenderId == cleanReceiverId) {
      throw ArgumentError('A user cannot message themselves.');
    }

    final sortedUids = [cleanSenderId, cleanReceiverId]..sort();
    if (cleanChatId != '${sortedUids[0]}_${sortedUids[1]}') {
      throw ArgumentError('Chat ID does not match the participants.');
    }

    final chatDocument = _firestore.collection('chats').doc(cleanChatId);
    final messageDocument = _messagesCollection(cleanChatId).doc();

    final message = ChatMessageModel(
      id: messageDocument.id,
      chatId: cleanChatId,
      senderId: cleanSenderId,
      receiverId: cleanReceiverId,
      text: messageText,
      createdAt: DateTime.now().toUtc(),
    );

    await _firestore.runTransaction((transaction) async {
      final chatSnapshot = await transaction.get(chatDocument);

      if (chatSnapshot.exists) {
        final data = chatSnapshot.data()!;
        final participants =
        List<String>.from(data['participants'] ?? const <String>[]);

        if (participants.length != 2 ||
            !participants.contains(cleanSenderId) ||
            !participants.contains(cleanReceiverId)) {
          throw StateError('Chat participants do not match.');
        }

        transaction.update(chatDocument, {
          'lastMessage': messageText,
          'lastMessageSenderId': cleanSenderId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(chatDocument, {
          'participants': sortedUids,
          'lastMessage': messageText,
          'lastMessageSenderId': cleanSenderId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(messageDocument, {
        ...message.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
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
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
