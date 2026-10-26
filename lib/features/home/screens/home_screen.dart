
import 'package:bychat/features/settings/screens/setting_screen.dart';
import 'package:bychat/features/calls/screens/calls_screen.dart';
import 'package:bychat/features/chats/screens/chat_screen.dart';
import 'package:bychat/features/chats/providers/chat_providers.dart';
import 'package:bychat/features/chats/utils/chat_id_helper.dart';
import 'package:bychat/features/profile/screens/profile_screen.dart';
import 'package:bychat/features/search/screens/username_search_screen.dart';
import 'package:bychat/features/status/screens/status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

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
              tooltip: 'Search chats',
              icon: const Icon(Icons.search),
              onPressed: _openChatSearch,
            ),
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Settings') {
                  setState(() => _selectedIndex = 3);
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value is not available yet.')),
                );
              },
              itemBuilder: (_) => const [
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const UsernameSearchScreen(),
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
          setState(() => _selectedIndex = index);
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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Please sign in to view your chats.'),
      );
    }

    final conversationsAsync = ref.watch(
      chatConversationsProvider(currentUser.uid),
    );

    return conversationsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'Could not load your conversations.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ref.invalidate(
                    chatConversationsProvider(currentUser.uid),
                  );
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
      data: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No chats yet.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a new conversation!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UsernameSearchScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('New chat'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6558F5),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 82,
          ),
          itemBuilder: (context, index) {
            final chat = conversations[index];

            return _ConversationTile(
              chat: chat,
              currentUid: currentUser.uid,
            );
          },
        );
      },
    );
  }

  void _openChatSearch() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final conversationsAsync = ref.read(
      chatConversationsProvider(currentUser.uid),
    );

    conversationsAsync.when(
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading chats...')),
        );
      },
      error: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load chats.')),
        );
      },
      data: (conversations) {
        showSearch(
          context: context,
          delegate: _ConversationSearchDelegate(
            conversations: conversations,
            currentUid: currentUser.uid,
          ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.chat,
    required this.currentUid,
  });

  final Map<String, dynamic> chat;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final participants = List<String>.from(
      (chat['participants'] as List?)?.whereType<String>() ?? const [],
    );

    final otherUids = participants
        .where((uid) => uid != currentUid)
        .toList();

    if (otherUids.isEmpty) {
      return const ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.person_outline),
        ),
        title: Text('Conversation'),
        subtitle: Text('Participant information unavailable'),
      );
    }

    final receiverUid = otherUids.first;
    final chatId = chat['chatId'] as String? ?? '';
    final lastMessage = chat['lastMessage'] as String? ?? '';
    final profileFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .get();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: profileFuture,
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() ?? {};

        final storedName = userData['name'] as String?;
        final username = userData['username'] as String?;

        final name = storedName != null && storedName.trim().isNotEmpty
            ? storedName.trim()
            : username != null && username.trim().isNotEmpty
            ? username.trim()
            : 'ByChat user';

        final photoUrl = userData['photoUrl'] as String?;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          leading: CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFF6558F5).withValues(alpha: 0.12),
            backgroundImage: photoUrl != null && photoUrl.trim().isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.trim().isEmpty
                ? const Icon(
              Icons.person,
              color: Color(0xFF6558F5),
              size: 28,
            )
                : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              lastMessage.isEmpty ? 'Start a conversation' : lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: () {
            if (chatId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This conversation has an invalid ID.'),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  contactName: name,
                  receiverUid: receiverUid,
                  chatId: chatId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ConversationSearchDelegate extends SearchDelegate<String> {
  _ConversationSearchDelegate({
    required this.conversations,
    required this.currentUid,
  });

  final List<Map<String, dynamic>> conversations;
  final String currentUid;

  @override
  String get searchFieldLabel => 'Search chats';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
        tooltip: 'Clear search',
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
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);

  Widget _buildResults(BuildContext context) {
    final filtered = conversations.where((chat) {
      final participants = List<String>.from(
        (chat['participants'] as List?)?.whereType<String>() ?? const [],
      );

      final otherUids = participants
          .where((uid) => uid != currentUid)
          .toList();

      if (otherUids.isEmpty) return false;

      final receiverUid = otherUids.first;
      final lastMessage = (chat['lastMessage'] as String? ?? '').toLowerCase();

      // Search by message or UID; names are loaded asynchronously in the tile.
      return lastMessage.contains(query.toLowerCase()) ||
          receiverUid.toLowerCase().contains(query.toLowerCase()) ||
          query.trim().isEmpty;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No matching conversations found.'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _ConversationTile(
          chat: filtered[index],
          currentUid: currentUid,
        );
      },
    );
  }
}
