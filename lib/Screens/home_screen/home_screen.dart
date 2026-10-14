
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const Color primaryColor = Color(0xFF6558F5);

  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Ahmed Khan',
      'message': 'Assalam o Alaikum!',
      'time': '10:45 AM',
      'unread': 2,
      'avatar': 'A',
      'color': Color(0xFF6558F5),
      'online': true,
    },
    {
      'name': 'Ali Raza',
      'message': 'How are you? 😊',
      'time': '10:20 AM',
      'unread': 0,
      'avatar': 'A',
      'color': Color(0xFF00897B),
      'online': true,
    },
    {
      'name': 'Sara Ahmed',
      'message': '📷 Photo',
      'time': '09:55 AM',
      'unread': 3,
      'avatar': 'S',
      'color': Color(0xFFE57373),
      'online': false,
    },
    {
      'name': 'Usman Malik',
      'message': 'Thank you!',
      'time': 'Yesterday',
      'unread': 0,
      'avatar': 'U',
      'color': Color(0xFF5C6BC0),
      'online': false,
    },
    {
      'name': 'Hassan Ali',
      'message': 'Voice message 🎤',
      'time': 'Yesterday',
      'unread': 0,
      'avatar': 'H',
      'color': Color(0xFFFF9800),
      'online': false,
    },
    {
      'name': 'Family Group',
      'message': 'Ammi: Allah khush rakhe ❤️',
      'time': 'Monday',
      'unread': 5,
      'avatar': 'F',
      'color': Color(0xFF26A69A),
      'online': false,
    },
  ];

  final List<Map<String, dynamic>> statuses = [
    {
      'name': 'Ahmed',
      'color': Color(0xFF6558F5),
      'seen': false,
    },
    {
      'name': 'Sara',
      'color': Color(0xFFE57373),
      'seen': false,
    },
    {
      'name': 'Ali',
      'color': Color(0xFF00897B),
      'seen': true,
    },
    {
      'name': 'Usman',
      'color': Color(0xFFFF9800),
      'seen': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6558F5),
                    Color(0xFF9388FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ByChat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(chats: chats),
              );
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search chats',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value will be added later.')),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'New group',
                child: Text('New group'),
              ),
              PopupMenuItem(
                value: 'Starred messages',
                child: Text('Starred messages'),
              ),
              PopupMenuItem(
                value: 'Settings',
                child: Text('Settings'),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildChatsPage(),
          _buildUpdatesPage(),
          _buildCallsPage(),
          _buildSettingsPage(),
        ],
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'New chat will be connected to contacts later.',
              ),
            ),
          );
        },
        child: const Icon(Icons.add_comment_rounded),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.donut_large_rounded),
            label: 'Updates',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call_rounded),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildChatsPage() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        _buildWelcomeBanner(),
        _buildSectionTitle('Recent updates', 'See all'),
        _buildStatusList(),
        const Divider(height: 24, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          child: Row(
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${chats.length} chats',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ...chats.map(_buildChatTile),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6558F5),
            Color(0xFF8276FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your world, connected.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Chat, share and stay closer.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.forum_rounded,
            color: Colors.white,
            size: 43,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                selectedIndex = 1;
              });
            },
            child: Text(
              action,
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList() {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildMyStatus(),
          ...statuses.map(_buildStatusItem),
        ],
      ),
    );
  }

  Widget _buildMyStatus() {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 29,
                backgroundColor: Color(0xFFEAE7FF),
                child: Icon(
                  Icons.person_rounded,
                  size: 35,
                  color: primaryColor,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'My status',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(Map<String, dynamic> status) {
    final bool seen = status['seen'] as bool;
    final Color color = status['color'] as Color;

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: seen ? Colors.grey.shade400 : primaryColor,
                width: seen ? 1.5 : 2.5,
              ),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: color,
              child: Text(
                status['name'].toString()[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            status['name'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    final int unread = chat['unread'] as int;
    final Color avatarColor = chat['color'] as Color;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: avatarColor,
            child: Text(
              chat['avatar'].toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (chat['online'] == true)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 13,
                width: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat['name'].toString(),
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          chat['message'].toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unread > 0
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey.shade600,
            fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'].toString(),
            style: TextStyle(
              fontSize: 11,
              color: unread > 0 ? primaryColor : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chat with ${chat['name']} will be added in the next step.',
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpdatesPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Updates',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          'Share moments with your friends.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFEAE7FF),
              child: Icon(Icons.add_a_photo_rounded, color: primaryColor),
            ),
            title: const Text('Add a status'),
            subtitle: const Text('Share a photo, video or text'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status creation will be added later.'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Recent updates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...statuses.map((status) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: status['color'] as Color,
              child: Text(
                status['name'].toString()[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(status['name'].toString()),
            subtitle: const Text('Tap to view status'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status viewer coming later.')),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildCallsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Calls',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Stay connected with voice and video calls.'),
        const SizedBox(height: 20),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFEAE7FF),
            child: Icon(Icons.link_rounded, color: primaryColor),
          ),
          title: const Text('Create call link'),
          subtitle: const Text('Share a link to start a call'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Call links will be added later.'),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        const Text(
          'Recent',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(35),
            child: Column(
              children: [
                Icon(Icons.call_outlined, size: 50, color: primaryColor),
                SizedBox(height: 12),
                Text('Your call history will appear here.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFFEAE7FF),
            child: Icon(Icons.person_rounded, color: primaryColor),
          ),
          title: Text('Your profile'),
          subtitle: Text('Name, profile picture and about'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.key_rounded),
          title: Text('Account'),
          subtitle: Text('Security and account information'),
        ),
        const ListTile(
          leading: Icon(Icons.lock_outline_rounded),
          title: Text('Privacy'),
        ),
        const ListTile(
          leading: Icon(Icons.notifications_none_rounded),
          title: Text('Notifications'),
        ),
        const ListTile(
          leading: Icon(Icons.chat_bubble_outline_rounded),
          title: Text('Chats'),
        ),
        const ListTile(
          leading: Icon(Icons.storage_rounded),
          title: Text('Storage and data'),
        ),
        const ListTile(
          leading: Icon(Icons.help_outline_rounded),
          title: Text('Help'),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'ByChat • Stay connected',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> chats;

  ChatSearchDelegate({required this.chats});

  @override
  String get searchFieldLabel => 'Search chats';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = chats.where((chat) {
      return chat['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = chats.where((chat) {
      return chat['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          chat['message']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();

    return _buildResultsList(results);
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No chats found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: chat['color'] as Color,
            child: Text(
              chat['avatar'].toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(chat['name'].toString()),
          subtitle: Text(chat['message'].toString()),
        );
      },
    );
  }
}
