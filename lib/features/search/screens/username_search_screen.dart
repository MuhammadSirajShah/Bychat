
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:bychat/features/profile/screens/public_profile_screen.dart';

class UsernameSearchScreen extends StatefulWidget {
  const UsernameSearchScreen({super.key});

  @override
  State<UsernameSearchScreen> createState() =>
      _UsernameSearchScreenState();
}

class _UsernameSearchScreenState extends State<UsernameSearchScreen> {
  static const Color _green = Color(0xFF20C875);
  static const Color _background = Color(0xFF0B1013);
  static const Color _panel = Color(0xFF20282B);
  static const Color _muted = Color(0xFF929A9E);

  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;

  bool _loading = false;
  bool _contactsLoading = false;
  bool _showContacts = false;

  String _query = '';
  String? _error;
  String? _contactsMessage;

  Map<String, dynamic>? _result;
  List<Contact> _contacts = [];

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final username = value
        .trim()
        .replaceFirst(RegExp(r'^@'), '')
        .toLowerCase();

    setState(() {
      _query = username;
      _result = null;
      _error = null;
      _loading = false;
      _showContacts = false;
    });

    if (username.isEmpty) return;

    if (!RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(username)) {
      setState(() => _error = 'Enter a valid username.');
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
      _loading = true;
      _error = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .get();

      if (!mounted || _query != username) return;

      if (!snapshot.exists) {
        setState(() {
          _result = null;
          _error = 'No ByChat account found for @$username.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _result = snapshot.data();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _result = null;
        _error = 'Search failed. Please check your connection.';
        _loading = false;
      });
    }
  }

  Future<void> _loadContacts() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _showContacts = true;
      _contactsLoading = true;
      _contactsMessage = null;
      _error = null;
      _result = null;
    });

    try {
      final permission =
      await FlutterContacts.permissions.request(PermissionType.read);

      if (permission != PermissionStatus.granted) {
        if (!mounted) return;

        setState(() {
          _contactsLoading = false;
          _contactsMessage =
          'Contacts permission nahi mili. Phone settings mein '
              'ByChat ko Contacts permission dein.';
        });
        return;
      }

      final contacts = await FlutterContacts.getAll(
        properties: {
          ContactProperty.name,
          ContactProperty.phone,
        },
      );

      if (!mounted) return;

      contacts.sort(
            (a, b) => (a.displayName ?? '').toLowerCase().compareTo(
          (b.displayName ?? '').toLowerCase(),
        ),
      );

      setState(() {
        _contacts = contacts;
        _contactsLoading = false;
        _contactsMessage = contacts.isEmpty
            ? 'Aapke phone mein koi contact nahi mila.'
            : '${contacts.length} phone contacts load hue. '
            'Registered ByChat users ki matching abhi connect '
            'nahi hui hai.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _contactsLoading = false;
        _contactsMessage =
        'Contacts load nahi hue. Permission aur phone settings check karein.';
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = _result?['username'] as String?;
    final uid = _result?['uid'] as String?;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('New Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search username, e.g. @siraj221',
                    hintStyle: const TextStyle(color: _muted),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: _muted,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: _muted),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: _panel,
                elevation: 0,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: _green,
                    child: Icon(
                      Icons.contacts,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text(
                    'Find from contacts',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Phone contacts load karein',
                    style: TextStyle(color: _muted),
                  ),
                  trailing: _contactsLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _green,
                    ),
                  )
                      : const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _muted,
                  ),
                  onTap: _contactsLoading ? null : _loadContacts,
                ),
              ),
            ),

            if (!_showContacts) ...[
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: _green),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: _muted, fontSize: 15),
                  ),
                )
              else if (username != null && uid != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: _panel,
                      elevation: 0,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: _green,
                          child: Icon(Icons.person, color: Colors.black),
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
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Username search karein ya apne contacts kholein.',
                      style: TextStyle(color: _muted, fontSize: 15),
                    ),
                  ),
            ] else ...[
              if (_contactsMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    _contactsMessage!,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              Expanded(
                child: _contactsLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: _green),
                )
                    : _contacts.isEmpty
                    ? const Center(
                  child: Text(
                    'Contacts yahan dikhaye jayenge.',
                    style: TextStyle(color: _muted),
                  ),
                )
                    : ListView.separated(
                  itemCount: _contacts.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 72,
                    color: _panel,
                  ),
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];

                    final phoneNumbers = contact.phones
                        .map((phone) => phone.number.trim())
                        .where((number) => number.isNotEmpty)
                        .toSet()
                        .toList();

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: _panel,
                        child: Icon(
                          Icons.person,
                          color: _green,
                        ),
                      ),
                      title: Text(
                        contact.displayName?.isNotEmpty == true
                            ? contact.displayName!
                            : 'Unknown contact',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        phoneNumbers.isEmpty
                            ? 'No phone number'
                            : phoneNumbers.join(', '),
                        style: const TextStyle(color: _muted),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublicProfileScreen(
                              uid: uid!,
                              username: username!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
