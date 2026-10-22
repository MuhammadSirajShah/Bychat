
import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  final List<Map<String, dynamic>> _calls = const [
    {
      'name': 'Ali Khan',
      'type': 'Incoming',
      'video': false,
      'missed': false,
      'time': '10:30 AM',
    },
    {
      'name': 'Ahmed',
      'type': 'Outgoing',
      'video': true,
      'missed': false,
      'time': 'Yesterday',
    },
    {
      'name': 'Usman',
      'type': 'Incoming',
      'video': true,
      'missed': true,
      'time': 'Yesterday',
    },
    {
      'name': 'Hassan',
      'type': 'Outgoing',
      'video': false,
      'missed': false,
      'time': 'Monday',
    },
    {
      'name': 'Family Group',
      'type': 'Incoming',
      'video': false,
      'missed': true,
      'time': 'Monday',
    },
  ];

  void _showCallMessage(BuildContext context, String name, bool video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${video ? 'Video' : 'Voice'} call with $name will be enabled later.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 90),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create call link',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share a link for your ByChat call',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Text(
              'Recent',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ..._calls.map((call) {
            final name = call['name'] as String;
            final isVideo = call['video'] as bool;
            final isMissed = call['missed'] as bool;
            final type = call['type'] as String;

            final Color callColor =
            isMissed ? Colors.red : Colors.green;

            final IconData callIcon = type == 'Incoming'
                ? Icons.call_received
                : Icons.call_made;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              leading: CircleAvatar(
                radius: 27,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  call['name'] == 'Family Group'
                      ? Icons.groups
                      : Icons.person,
                  size: 29,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isMissed
                      ? Colors.red
                      : theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      callIcon,
                      size: 17,
                      color: callColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$type · ${call['time']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                tooltip: isVideo ? 'Video call' : 'Voice call',
                onPressed: () {
                  _showCallMessage(context, name, isVideo);
                },
                icon: Icon(
                  isVideo ? Icons.videocam_outlined : Icons.call_outlined,
                  color: const Color(0xFF6558F5),
                ),
              ),
              onTap: () {
                _showCallMessage(context, name, isVideo);
              },
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCallMessage(context, 'new contact', false);
        },
        backgroundColor: const Color(0xFF6558F5),
        foregroundColor: Colors.white,
        tooltip: 'New call',
        child: const Icon(Icons.add_call),
      ),
    );
  }
}
