import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/services.dart';

class UsernameSearchScreen extends StatefulWidget {
  const UsernameSearchScreen({super.key});

  @override
  State<UsernameSearchScreen> createState() =>
      _UsernameSearchScreenState();
}

class _UsernameSearchScreenState extends State<UsernameSearchScreen> {
  static const Color _background = Color(0xFF0B1013);
  static const Color _panel = Color(0xFF20282B);
  static const Color _green = Color(0xFF20C875);
  static const Color _muted = Color(0xFF929A9E);

  final TextEditingController _searchController =
  TextEditingController();

  List<Contact> _contacts = [];
  bool _loading = true;
  bool _searching = false;
  String _query = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (permission != PermissionStatus.granted) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _error =
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

      contacts.sort(
            (a, b) => (a.displayName ?? '')
            .toLowerCase()
            .compareTo((b.displayName ?? '').toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Contacts load nahi ho sake. Dobara try karein.';
      });
    }
  }

  List<Contact> get _filteredContacts {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _contacts;

    return _contacts.where((contact) {
      final name = (contact.displayName ?? '').toLowerCase();

      final numbers = contact.phones
          .map((phone) => phone.number.toLowerCase())
          .join(' ');

      return name.contains(query) || numbers.contains(query);
    }).toList();
  }

  String _formatPhone(String phone) {
    return phone.trim();
  }

  void _inviteContact(Contact contact) {
    final numbers = contact.phones
        .map((phone) => phone.number.trim())
        .where((number) => number.isNotEmpty)
        .toList();

    if (numbers.isEmpty) {
      _showMessage('Is contact ka phone number available nahi hai.');
      return;
    }

    // Clipboard action works without adding another package.
    // Share/SMS integration will be added in the next step.
    Clipboard.setData(ClipboardData(text: numbers.first));

    _showMessage(
      'Number copy ho gaya. Share/SMS invitation agle step mein '
          'connect karenge.',
    );
  }

  void _openContact(Contact contact) {
    final numbers = contact.phones
        .map((phone) => phone.number.trim())
        .where((number) => number.isNotEmpty)
        .toList();

    if (numbers.isEmpty) {
      _showMessage('Is contact ka phone number available nahi hai.');
      return;
    }

    // Registered ByChat account matching is not connected yet.
    // We must not open a chat until Firebase confirms the account.
    _showMessage(
      'ByChat account matching agle step mein connect hogi.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _panel,
      ),
    );
  }

  void _startSearch() {
    setState(() => _searching = true);
  }

  void _stopSearch() {
    _searchController.clear();

    setState(() {
      _query = '';
      _searching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _filteredContacts;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: _searching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) {
            setState(() => _query = value);
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search name or number',
            hintStyle: TextStyle(color: _muted),
            border: InputBorder.none,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select contact',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${_contacts.length} contacts',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search contacts',
            onPressed: _searching ? _stopSearch : _startSearch,
            icon: Icon(
              _searching ? Icons.close : Icons.search,
              size: 28,
            ),
          ),
          PopupMenuButton<String>(
            color: _panel,
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == 'refresh') {
                _loadContacts();
              } else if (value == 'help') {
                _showMessage(
                  'ByChat users matching aur invitation next step '
                      'mein connect honge.',
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'refresh',
                child: Text(
                  'Refresh contacts',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: Text(
                  'Contacts help',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: _green),
      )
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.contacts_outlined,
                color: _muted,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadContacts,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      )
          : contacts.isEmpty
          ? Center(
        child: Text(
          _query.isEmpty
              ? 'Aapke mobile mein koi contact nahi mila.'
              : 'Koi matching contact nahi mila.',
          style: const TextStyle(color: _muted),
          textAlign: TextAlign.center,
        ),
      )
          : RefreshIndicator(
        color: _green,
        onRefresh: _loadContacts,
        child: ListView.separated(
          itemCount: contacts.length,
          separatorBuilder: (context, index) =>
          const Divider(
            height: 1,
            indent: 76,
            color: _panel,
          ),
          itemBuilder: (context, index) {
            final contact = contacts[index];

            final name =
            contact.displayName?.trim().isNotEmpty ==
                true
                ? contact.displayName!.trim()
                : 'Unknown contact';

            final numbers = contact.phones
                .map((phone) =>
                _formatPhone(phone.number))
                .where((number) => number.isNotEmpty)
                .toSet()
                .toList();

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              leading: const CircleAvatar(
                radius: 25,
                backgroundColor: _panel,
                child: Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                numbers.isEmpty
                    ? 'No phone number'
                    : numbers.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                ),
              ),
              trailing: numbers.isEmpty
                  ? null
                  : TextButton(
                onPressed: () =>
                    _inviteContact(contact),
                style: TextButton.styleFrom(
                  foregroundColor: _green,
                ),
                child: const Text(
                  'Invite',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () => _openContact(contact),
            );
          },
        ),
      ),
    );
  }
}