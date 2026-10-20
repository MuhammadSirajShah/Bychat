
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LinksPrivacyScreen extends StatefulWidget {
  const LinksPrivacyScreen({super.key});

  @override
  State<LinksPrivacyScreen> createState() =>
      _LinksPrivacyScreenState();
}

class _LinksPrivacyScreenState extends State<LinksPrivacyScreen> {
  static const Color _green = Color(0xFF20C875);

  String _selectedPrivacy = 'everyone';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _options = [
    {
      'value': 'everyone',
      'title': 'Everyone',
      'description': 'Anyone on ByChat can see your links.',
      'icon': Icons.public,
    },
    {
      'value': 'myContacts',
      'title': 'My contacts',
      'description': 'Only your contacts can see your links.',
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
      'description': 'Your links will be hidden from everyone else.',
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
        throw Exception('Please sign in again.');
      }

      final snapshot = await document.get();
      final savedValue = snapshot.data()?['linksPrivacy'];

      const validValues = [
        'everyone',
        'myContacts',
        'myContactsExcept',
        'nobody',
      ];

      if (mounted) {
        setState(() {
          _selectedPrivacy =
          savedValue is String && validValues.contains(savedValue)
              ? savedValue
              : 'everyone';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load privacy settings.'),
        ),
      );
    }
  }

  Future<void> _savePrivacy(String value) async {
    if (_isSaving || value == _selectedPrivacy) return;

    final document = _userDocument;

    if (document == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again.'),
        ),
      );
      return;
    }

    final previousValue = _selectedPrivacy;

    setState(() {
      _selectedPrivacy = value;
      _isSaving = true;
    });

    try {
      await document.set({
        'linksPrivacy': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Links privacy settings saved.'),
        ),
      );

      Navigator.pop(context, value);
    } catch (_) {
      if (!mounted) return;

      setState(() => _selectedPrivacy = previousValue);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save settings. Check your connection and Firestore rules.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Links Privacy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: _green,
                  size: 30,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your links, your choice',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Choose who can see the social links on your profile.',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'WHO CAN SEE LINKS ON MY PROFILE?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          ..._options.map((option) {
            final value = option['value'] as String;
            final selected = value == _selectedPrivacy;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: selected
                  ? _green.withValues(alpha: 0.10)
                  : theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected
                      ? _green
                      : theme.dividerColor.withValues(alpha: 0.25),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: _green.withValues(alpha: 0.12),
                  child: Icon(
                    option['icon'] as IconData,
                    color: _green,
                  ),
                ),
                title: Text(
                  option['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    option['description'] as String,
                  ),
                ),
                trailing: selected
                    ? const Icon(
                  Icons.check_circle,
                  color: _green,
                )
                    : const Icon(Icons.circle_outlined),
                onTap: _isSaving
                    ? null
                    : () => _savePrivacy(value),
              ),
            );
          }),
          if (_isSaving) ...[
            const SizedBox(height: 12),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Your selection is saved to your ByChat profile.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
