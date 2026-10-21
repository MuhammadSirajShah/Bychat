
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Contacts Test Screen/contacts_test_screen.dart';

class LinksPrivacyScreen extends StatefulWidget {
  const LinksPrivacyScreen({super.key});

  @override
  State<LinksPrivacyScreen> createState() =>
      _LinksPrivacyScreenState();
}

class _LinksPrivacyScreenState extends State<LinksPrivacyScreen> {
  static const Color _green = Color(0xFF20C875);
  static const Color _background = Color(0xFF0B1013);
  static const Color _muted = Color(0xFF929A9E);

  String _selected = 'everyone';
  bool _loading = true;
  bool _saving = false;

  final List<Map<String, dynamic>> _options = [
    {
      'value': 'everyone',
      'title': 'Everyone',
      'description': 'All ByChat users can see your profile links.',
      'icon': Icons.public,
    },
    {
      'value': 'myContacts',
      'title': 'My contacts',
      'description': 'Only your selected contacts can see your links.',
      'icon': Icons.people_outline,
    },
    {
      'value': 'myContactsExcept',
      'title': 'My contacts except...',
      'description': 'Hide your links from selected contacts.',
      'icon': Icons.person_off_outlined,
    },
    {
      'value': 'nobody',
      'title': 'Nobody',
      'description': 'Your profile links are hidden from other users.',
      'icon': Icons.lock_outline,
    },
  ];

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
  }

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    try {
      final document = _userDocument;

      if (document == null) {
        throw Exception('Please sign in first.');
      }

      final snapshot = await document.get();
      final value = snapshot.data()?['linksPrivacy'] as String?;

      const validOptions = [
        'everyone',
        'myContacts',
        'myContactsExcept',
        'nobody',
      ];

      if (mounted) {
        setState(() {
          if (value != null && validOptions.contains(value)) {
            _selected = value;
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load privacy settings.'),
        ),
      );
    }
  }

  Future<void> _savePrivacy(String value) async {
    if (_saving || value == _selected) return;

    final document = _userDocument;

    if (document == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first.'),
        ),
      );
      return;
    }

    final previousValue = _selected;

    setState(() {
      _selected = value;
      _saving = true;
    });

    try {
      await document.set(
        {
          'linksPrivacy': value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Links privacy saved.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _selected = previousValue);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save privacy setting: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _buildOption(Map<String, dynamic> option) {
    final value = option['value'] as String;
    final isSelected = _selected == value;

    return InkWell(
      onTap: _saving ? null : () => _savePrivacy(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(
              option['icon'] as IconData,
              color: isSelected ? _green : _muted,
              size: 25,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    option['description'] as String,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? _green : const Color(0xFF41494E),
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Links',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFF20272B),
          ),
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: _green),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 42, 24, 18),
            child: Text(
              'Who can see links on my profile',
              style: TextStyle(
                color: _muted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ..._options.map(_buildOption),
          if (_saving)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactsTestScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.contacts_outlined),
                  label: const Text('Test Mobile Contacts'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
