
import 'dart:async';

import 'package:bychat/features/contacts/models/bychat_contact_model.dart';
import 'package:bychat/features/contacts/providers/contact_providers.dart';
import 'package:bychat/features/profile/screens/public_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  static const Color _background = Color(0xFF101418);
  static const Color _teal = Color(0xFF009688);
  static const Color _muted = Color(0xFF9AA4AA);
  static const Color _panel = Color(0xFF20282B);

  final TextEditingController _searchController =
  TextEditingController();

  Timer? _debounce;

  bool _searching = false;
  String _query = '';
  String? _searchError;
  Map<String, dynamic>? _searchResult;

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final username = value
        .trim()
        .replaceFirst(RegExp(r'^@'), '')
        .toLowerCase();

    setState(() {
      _query = username;
      _searchResult = null;
      _searchError = null;
      _searching = false;
    });

    if (username.isEmpty) return;

    if (!RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(username)) {
      setState(() {
        _searchError = 'Enter a valid username.';
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
          () => _searchUsername(username),
    );
  }

  Future<void> _searchUsername(String username) async {
    if (!mounted) return;

    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .get();

      if (!mounted || _query != username) return;

      if (!snapshot.exists) {
        setState(() {
          _searching = false;
          _searchError = 'No ByChat account found for @$username.';
        });
        return;
      }

      final data = snapshot.data();

      if (data == null ||
          data['uid'] is! String ||
          (data['uid'] as String).trim().isEmpty) {
        setState(() {
          _searching = false;
          _searchError = 'This username has an incomplete profile.';
        });
        return;
      }

      setState(() {
        _searchResult = {
          ...data,
          'username': data['username'] is String
              ? data['username']
              : username,
        };
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _searching = false;
        _searchError = 'Search failed. Please check your connection.';
      });
    }
  }

  void _openProfile(Map<String, dynamic> user) {
    final uid = user['uid'] as String?;
    final username = user['username'] as String?;

    if (uid == null || uid.trim().isEmpty ||
        username == null || username.trim().isEmpty) {
      _showMessage('User profile information is incomplete.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(
          uid: uid,
          username: username,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(byChatContactsProvider);

    final username = _searchResult?['username'] as String?;
    final hasSearch = _query.isNotEmpty;

    return Scaffold(
      //backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: const Text(
          'New Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh contacts',
            onPressed: () => ref.invalidate(byChatContactsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search ByChat username',
                hintStyle: const TextStyle(color: _muted),
                prefixIcon: const Icon(Icons.search, color: _muted),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: const Icon(Icons.clear, color: _muted),
                ),
                filled: true,
                fillColor: _panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (_searching)
            const LinearProgressIndicator(color: _teal),

          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _searchError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),

          if (username != null && _searchResult != null)
            Card(
              color: _panel,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'ByChat user',
                  style: TextStyle(color: _muted),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: _teal,
                ),
                onTap: () => _openProfile(_searchResult!),
              ),
            ),

          if (hasSearch)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Search results',
                style: TextStyle(color: _muted),
              ),
            ),

          if (!hasSearch)
            Expanded(
              child: contactsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _teal),
                ),
                error: (error, stackTrace) => _ErrorView(
                  message: error.toString().contains('permission')
                      ? 'Contacts permission is required to show your phone contacts.'
                      : 'Could not load contacts. Please check your connection and permissions.',
                  onRetry: () =>
                      ref.invalidate(byChatContactsProvider),
                ),
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No phone contacts found.\nSave a contact on your phone and refresh.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }

                  final registered = contacts
                      .where((contact) => contact.isRegistered)
                      .toList();

                  final notRegistered = contacts
                      .where((contact) => !contact.isRegistered)
                      .toList();

                  return ListView(
                    children: [
                      if (registered.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'ON BYCHAT',
                          count: registered.length,
                        ),
                        ...registered.map(
                              (contact) => _ContactTile(
                            contact: contact,
                            onTap: () {
                              _showMessage(
                                'Registered user profile navigation will be connected after secure contact matching.',
                              );
                            },
                          ),
                        ),
                      ],
                      if (notRegistered.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'INVITE TO BYCHAT',
                          count: notRegistered.length,
                        ),
                        ...notRegistered.map(
                              (contact) => _ContactTile(
                            contact: contact,
                            onTap: () {
                              _showMessage(
                                'Invite for ${contact.name} will be connected in the next step.',
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          color: Color(0xFF009688),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.onTap,
  });

  final ByChatContactModel contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final registered = contact.isRegistered;

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF263238),
        backgroundImage: contact.photoUrl != null &&
            contact.photoUrl!.isNotEmpty
            ? NetworkImage(contact.photoUrl!)
            : null,
        child: contact.photoUrl == null ||
            contact.photoUrl!.isEmpty
            ? Text(
          contact.name.isNotEmpty
              ? contact.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
      title: Text(
        contact.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        registered && contact.username.isNotEmpty
            ? '@${contact.username}'
            : contact.phoneNumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF9AA4AA)),
      ),
      trailing: registered
          ? const Icon(
        Icons.chat_outlined,
        color: Color(0xFF009688),
      )
          : const Text(
        'Invite',
        style: TextStyle(
          color: Color(0xFF009688),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.contacts_outlined,
              size: 48,
              color: Color(0xFF9AA4AA),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
