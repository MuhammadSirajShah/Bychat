
import 'package:bychat/features/chats/models/chat_message_model.dart';
import 'package:bychat/features/chats/providers/chat_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.contactName,
    required this.receiverUid,
    required this.chatId,
  });

  final String contactName;
  final String receiverUid;
  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  String? _lastMessageId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (text.isEmpty || _sending) return;

    if (currentUser == null) {
      _showMessage('Please sign in to send messages.');
      return;
    }

    if (widget.receiverUid.trim().isEmpty ||
        widget.chatId.trim().isEmpty) {
      _showMessage('Chat details are missing. Please reopen this chat.');
      return;
    }

    setState(() => _sending = true);

    // Clear only after Firestore confirms the message was saved.
    try {
      await ref.read(chatMessageActionsProvider).sendMessage(
        chatId: widget.chatId,
        senderId: currentUser.uid,
        receiverId: widget.receiverUid,
        text: text,
      );

      if (!mounted) return;

      if (_messageController.text.trim() == text) {
        _messageController.clear();
      }

      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        _showMessage('Message send nahi hua. Internet aur Firestore rules check karein.');
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatTime(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime.toLocal());
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _attachmentItem(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.blue,
                  sheetContext: sheetContext,
                ),
                _attachmentItem(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  sheetContext: sheetContext,
                ),
                _attachmentItem(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.pink,
                  sheetContext: sheetContext,
                ),
                _attachmentItem(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.green,
                  sheetContext: sheetContext,
                ),
                _attachmentItem(
                  icon: Icons.person,
                  label: 'Contact',
                  color: Colors.orange,
                  sheetContext: sheetContext,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext sheetContext,
  }) {
    return SizedBox(
      width: 75,
      child: InkWell(
        onTap: () {
          Navigator.pop(sheetContext);
          _showMessage('$label sharing will be implemented later.');
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showCallMessage(String type) {
    _showMessage('$type feature will be connected later.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesAsync = ref.watch(
      chatMessagesProvider(widget.chatId),
    );
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'ByChat',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showCallMessage('Voice call'),
            icon: const Icon(Icons.call_outlined),
            tooltip: 'Voice call',
          ),
          IconButton(
            onPressed: () => _showCallMessage('Video call'),
            icon: const Icon(Icons.videocam_outlined),
            tooltip: 'Video call',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _showMessage('$value selected');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'View contact',
                child: Text('View contact'),
              ),
              PopupMenuItem(
                value: 'Search',
                child: Text('Search'),
              ),
              PopupMenuItem(
                value: 'Clear chat',
                child: Text('Clear chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 42),
                      const SizedBox(height: 12),
                      const Text(
                        'Messages load nahi ho sake.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(
                            chatMessagesProvider(widget.chatId),
                          );
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (messages) {
                if (messages.isNotEmpty &&
                    messages.last.id != _lastMessageId) {
                  _lastMessageId = messages.last.id;
                  _scrollToBottom();
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.waving_hand_outlined,
                            size: 44,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Start your conversation!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Send your first message to ${widget.contactName}.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final ChatMessageModel message = messages[index];
                    final isMe = message.senderId == currentUid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.sizeOf(context).width * 0.78,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.fromLTRB(12, 9, 10, 6),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFE4DFFF)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isMe ? 14 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _showMessage(
                                'Emoji picker will be added later.',
                              );
                            },
                            icon: const Icon(
                              Icons.emoji_emotions_outlined,
                            ),
                            tooltip: 'Emoji',
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 5,
                              textCapitalization:
                              TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            onPressed: _showAttachmentOptions,
                            icon: const Icon(Icons.attach_file),
                            tooltip: 'Attach',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF6558F5),
                    child: IconButton(
                      onPressed: _sending ? null : _sendMessage,
                      icon: _sending
                          ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      tooltip: 'Send message',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
