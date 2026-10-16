
import 'package:bychat/Screens/Setting%20Screen/setting_screen.dart';
import 'package:flutter/material.dart';

import '../Call Screens/calls_screen.dart';
import '../Chat Screen/chat_screen.dart';
import '../Profile Screen/profile_screen.dart';
import '../Status Screen/status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Ali Khan',
      'message': 'Assalam o Alaikum!',
      'time': '10:30 AM',
      'unread': 2,
      'color': Colors.blue,
      'icon': Icons.person,
    },
    {
      'name': 'Ahmed',
      'message': 'How are you?',
      'time': '09:45 AM',
      'unread': 1,
      'color': Colors.orange,
      'icon': Icons.person,
    },
    {
      'name': 'Family Group',
      'message': 'See you tomorrow.',
      'time': 'Yesterday',
      'unread': 0,
      'color': Colors.green,
      'icon': Icons.groups,
    },
    {
      'name': 'Usman',
      'message': 'Photo',
      'time': 'Yesterday',
      'unread': 0,
      'color': Colors.purple,
      'icon': Icons.person,
    },
    {
      'name': 'Hassan',
      'message': 'Thank you!',
      'time': 'Monday',
      'unread': 0,
      'color': Colors.teal,
      'icon': Icons.person,
    },
  ];

  final List<String> _titles = [
    'ByChat',
    'Status',
    'Calls',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (_selectedIndex == 0) ...[
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _ChatSearchDelegate(_chats),
                );
              },
              icon: const Icon(Icons.search),
              tooltip: 'Search chats',
            ),
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value selected')),
                );
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'New group',
                  child: Text('New group'),
                ),
                PopupMenuItem(
                  value: 'New broadcast',
                  child: Text('New broadcast'),
                ),
                PopupMenuItem(
                  value: 'Settings',
                  child: Text('Settings'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _selectedIndex == 0
          ? _buildChatsList()
          : _selectedIndex == 1
          ? const StatusScreen()
          : _selectedIndex == 2
          ? const CallsScreen()
          : const SettingScreen(),

      // Center(
      //   child: Text(
      //     '${_titles[_selectedIndex]} screen will be connected next.',
      //     textAlign: TextAlign.center,
      //     style: const TextStyle(fontSize: 16),
      //   ),
      // ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New chat feature will be added next.'),
            ),
          );
        },
        backgroundColor: const Color(0xFF6558F5),
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    if (_chats.isEmpty) {
      return const Center(
        child: Text('No chats yet. Start a new conversation!'),
      );
    }

    return ListView.separated(
      itemCount: _chats.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 82,
      ),
      itemBuilder: (context, index) {
        final chat = _chats[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          leading: CircleAvatar(
            radius: 27,
            backgroundColor: (chat['color'] as Color).withValues(alpha: 0.15),
            child: Icon(
              chat['icon'] as IconData,
              color: chat['color'] as Color,
              size: 28,
            ),
          ),
          title: Text(
            chat['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              chat['message'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: (chat['unread'] as int) > 0
                      ? const Color(0xFF6558F5)
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              if ((chat['unread'] as int) > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFF6558F5),
                  child: Text(
                    '${chat['unread']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChatScreen(
                contactName: chat['name'] as String,
              ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatSearchDelegate extends SearchDelegate<String> {
  _ChatSearchDelegate(this.chats);

  final List<Map<String, dynamic>> chats;

  @override
  String get searchFieldLabel => 'Search chats';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  Widget _buildResults() {
    final results = chats.where((chat) {
      return (chat['name'] as String)
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          (chat['message'] as String)
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No chats found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];

        return ListTile(
          leading: CircleAvatar(
            child: Icon(chat['icon'] as IconData),
          ),
          title: Text(chat['name'] as String),
          subtitle: Text(chat['message'] as String),
        );
      },
    );
  }
}

