
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.contactName,
  });

  final String contactName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Assalam o Alaikum!',
      'isMe': false,
      'time': '10:30 AM',
    },
    {
      'text': 'Wa Alaikum Assalam!',
      'isMe': true,
      'time': '10:31 AM',
    },
    {
      'text': 'How are you?',
      'isMe': false,
      'time': '10:32 AM',
    },
    {
      'text': 'I am fine, thank you!',
      'isMe': true,
      'time': '10:33 AM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
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
                ),
                _attachmentItem(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                ),
                _attachmentItem(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.pink,
                ),
                _attachmentItem(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.green,
                ),
                _attachmentItem(
                  icon: Icons.person,
                  label: 'Contact',
                  color: Colors.orange,
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
  }) {
    return SizedBox(
      width: 75,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$label sharing will be implemented later.',
              ),
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value selected')),
              );
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;

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
                            message['text'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['time'] as String,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Emoji picker will be added later.',
                                  ),
                                ),
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
                      onPressed: _sendMessage,
                      icon: const Icon(
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

  void _showCallMessage(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type feature will be connected later.'),
      ),
    );
  }
}
