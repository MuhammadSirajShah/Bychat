
import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final List<Map<String, dynamic>> _statuses = [
    {
      'name': 'Ali Khan',
      'time': '10 minutes ago',
      'color': Colors.blue,
      'viewed': false,
    },
    {
      'name': 'Ahmed',
      'time': '25 minutes ago',
      'color': Colors.orange,
      'viewed': false,
    },
    {
      'name': 'Usman',
      'time': '1 hour ago',
      'color': Colors.purple,
      'viewed': true,
    },
  ];

  void _addStatus() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create a Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE4DFFF),
                    child: Icon(
                      Icons.edit,
                      color: Color(0xFF6558F5),
                    ),
                  ),
                  title: const Text('Text Status'),
                  subtitle: const Text('Share a thought or message'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _createTextStatus();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE8D6),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.deepOrange,
                    ),
                  ),
                  title: const Text('Photo or Video'),
                  subtitle: const Text('Choose from your gallery'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon('Photo and video status');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDDF5E5),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Capture a new moment'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showComingSoon('Camera');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createTextStatus() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Text Status'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 300,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'What is on your mind?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) return;

                setState(() {
                  _statuses.insert(0, {
                    'name': 'My Status',
                    'time': 'Just now',
                    'color': const Color(0xFF6558F5),
                    'viewed': false,
                    'text': text,
                  });
                });

                Navigator.pop(dialogContext);
                _showComingSoon(
                  'Status saved in this demo only',
                );
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  void _openStatus(Map<String, dynamic> status) {
    setState(() {
      status['viewed'] = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _StatusViewerScreen(
          status: status,
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be connected in a later step.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Text(
              'Share your moments with friends.',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5,
            ),
            leading: Stack(
              children: [
                const CircleAvatar(
                  radius: 29,
                  child: Icon(Icons.person, size: 32),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6558F5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            title: const Text(
              'My Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Tap to add a status update'),
            onTap: _addStatus,
            trailing: IconButton(
              onPressed: _addStatus,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add status',
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Recent updates',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ..._statuses.map((status) {
            final color = status['color'] as Color;
            final viewed = status['viewed'] as bool;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              leading: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: viewed ? Colors.grey : color,
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(
                    status.containsKey('text')
                        ? Icons.text_fields
                        : Icons.person,
                    color: color,
                    size: 27,
                  ),
                ),
              ),
              title: Text(
                status['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(status['time'] as String),
              onTap: () => _openStatus(status),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStatus,
        backgroundColor: const Color(0xFF6558F5),
        foregroundColor: Colors.white,
        tooltip: 'Add status',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatusViewerScreen extends StatelessWidget {
  const _StatusViewerScreen({
    required this.status,
  });

  final Map<String, dynamic> status;

  @override
  Widget build(BuildContext context) {
    final text = status['text'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFF202033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202033),
        foregroundColor: Colors.white,
        title: Text(status['name'] as String),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text ?? 'Status preview',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
