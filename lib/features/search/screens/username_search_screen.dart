
import 'dart:async';

import 'package:bychat/features/profile/screens/public_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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

  // Normalizes Pakistani phone numbers for matching.
  String _normalizePhoneNumber(String phone) {
    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    }

    if (normalized.startsWith('0092')) {
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('92')) {
      // Already contains Pakistan country code.
    } else if (normalized.startsWith('0') &&
        normalized.length == 11) {
      normalized = '92${normalized.substring(1)}';
    }

    return normalized;
  }

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

      final data = snapshot.data();

      if (data == null ||
          data['uid'] is! String ||
          (data['uid'] as String).trim().isEmpty) {
        setState(() {
          _result = null;
          _error = 'This username has an incomplete profile.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _result = {
          ...data,
          'username': data['username'] is String
              ? data['username']
              : username,
        };
        _loading = false;
      });
    } catch (error) {
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
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

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
            (a, b) => (a.displayName ?? '')
            .toLowerCase()
            .compareTo((b.displayName ?? '').toLowerCase()),
      );

      setState(() {
        _contacts = contacts;
        _contactsLoading = false;
      });

      if (contacts.isEmpty) {
        setState(() {
          _contactsMessage = 'Aapke phone mein koi contact nahi mila.';
        });
        return;
      }

      await _matchContactsWithUsers(contacts);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _contactsLoading = false;
        _contactsMessage =
        'Contacts load nahi hue. Permission aur internet check karein.';
      });
    }
  }

  Future<void> _matchContactsWithUsers(
      List<Contact> contacts,
      ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        setState(() {
          _contactsMessage = 'Please sign in to find ByChat contacts.';
        });
        return;
      }

      final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      final registeredUsers = <String, Map<String, dynamic>>{};

      for (final document in usersSnapshot.docs) {
        if (document.id == currentUser.uid) continue;

        final data = document.data();
        final phone = data['phoneNumber'] as String? ?? '';
        final normalized = _normalizePhoneNumber(phone);

        if (normalized.isNotEmpty) {
          registeredUsers[normalized] = {
            ...data,
            'uid': document.id,
          };
        }
      }

      var matchCount = 0;

      for (final contact in contacts) {
        for (final phone in contact.phones) {
          final normalized = _normalizePhoneNumber(phone.number);

          if (normalized.isEmpty) continue;

          final user = registeredUsers[normalized];

          if (user != null) {
            matchCount++;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _contactsMessage = matchCount == 0
            ? 'Koi matching ByChat account nahi mila. Phone numbers '
            'aur profile numbers ka format check karein.'
            : '$matchCount registered ByChat contact(s) mil gaye.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _contactsMessage =
        'ByChat users match nahi ho sake. Firebase permissions check karein.';
      });
    }
  }



  Future<void> _openContact(Contact contact) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('Please sign in first.');
      return;
    }

    final phoneNumbers = contact.phones
        .map((phone) => _normalizePhoneNumber(phone.number))
        .where((phone) => phone.isNotEmpty)
        .toSet();

    if (phoneNumbers.isEmpty) {
      _showMessage('Is contact ka phone number available nahi hai.');
      return;
    }

    try {
      final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      if (!mounted) return;

      Map<String, dynamic>? matchedUser;

      for (final document in usersSnapshot.docs) {
        if (document.id == currentUser.uid) continue;

        final data = document.data();
        final savedPhone = data['phoneNumber'] as String? ?? '';
        final normalizedSavedPhone =
        _normalizePhoneNumber(savedPhone);

        if (phoneNumbers.contains(normalizedSavedPhone)) {
          matchedUser = {
            ...data,
            'uid': document.id,
          };
          break;
        }
      }

      if (matchedUser == null) {
        _showMessage(
          'Is number se matching ByChat account nahi mila.',
        );
        return;
      }

      final uid = matchedUser['uid'] as String?;
      if (uid == null || uid.trim().isEmpty) {
        _showMessage('ByChat profile ki user ID missing hai.');
        return;
      }

      final username = matchedUser['username'] as String? ?? '';
      final name = matchedUser['name'] as String? ?? '';

      if (username.trim().isEmpty && name.trim().isEmpty) {
        _showMessage('Is ByChat user ka profile incomplete hai.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicProfileScreen(
            uid: uid,
            username: username.trim().isNotEmpty
                ? username.trim()
                : name.trim(),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Contact check nahi ho saka. Internet aur Firebase rules check karein.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        title: const Text('New Chat'),
        actions: [
          IconButton(
            tooltip: 'Phone contacts',
            onPressed: _loadContacts,
            icon: const Icon(Icons.contacts_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search username',
                hintStyle: const TextStyle(color: _muted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: _muted,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    _controller.clear();
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
          if (_loading)
            const LinearProgressIndicator(color: _green),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          if (!_showContacts &&
              !_loading &&
              _error == null &&
              username != null &&
              uid != null)
            Card(
              color: _panel,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _green,
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
                  color: _green,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicProfileScreen(
                        uid: uid,
                        username: username,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_showContacts && _contactsMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _contactsMessage!,
                style: const TextStyle(color: _muted),
                textAlign: TextAlign.center,
              ),
            ),
          if (_showContacts && _contactsLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: _green),
              ),
            )
          else if (_showContacts)
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(
                child: Text(
                  'Contacts yahan dikhaye jayenge.',
                  style: TextStyle(color: _muted),
                ),
              )
                  : ListView.separated(
                itemCount: _contacts.length,
                separatorBuilder: (_, index) => const Divider(
                  height: 1,
                  indent: 72,
                  color: _panel,
                ),
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  final numbers = contact.phones
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
                      numbers.isEmpty
                          ? 'No phone number'
                          : numbers.join(', '),
                      style: const TextStyle(color: _muted),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: _green,
                    ),
                    onTap: () => _openContact(contact),
                  );
                },
              ),
            )
          else if (username == null && _error == null && !_loading)
              const Expanded(
                child: Center(
                  child: Text(
                    'Username search karein ya phone contacts kholein.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
