
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({
    super.key,
    this.initialUsername = '',
  });

  final String initialUsername;

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  static const Color _green = Color(0xFF20C875);
  static const Color _background = Color(0xFF0B1013);
  static const Color _panel = Color(0xFF20282B);
  static const Color _muted = Color(0xFF929A9E);

  late final TextEditingController _controller;

  bool _saving = false;
  bool _checking = false;
  bool _available = false;
  String _message = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialUsername.replaceFirst(
        RegExp(r'^@'),
        '',
      ),
    );

    _controller.addListener(_onUsernameChanged);

    if (_controller.text.isNotEmpty) {
      _checkUsername(_controller.text.trim().toLowerCase());
    }
  }

  bool _isValid(String username) {
    return RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(username);
  }

  void _onUsernameChanged() {
    _debounce?.cancel();

    final username = _controller.text.trim().toLowerCase();

    setState(() {
      _available = false;
      _message = '';
      _checking = false;
    });

    if (username.isEmpty) return;

    if (!_isValid(username)) {
      setState(() {
        _message =
        'Use 3–30 letters, numbers, underscores or periods.';
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
          () => _checkUsername(username),
    );
  }

  Future<void> _checkUsername(String username) async {
    if (!_isValid(username)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (mounted) {
      setState(() {
        _checking = true;
        _message = '';
        _available = false;
      });
    }

    try {
      final db = FirebaseFirestore.instance;

      final currentDoc = await db.collection('users').doc(user.uid).get();
      final currentUsername =
      (currentDoc.data()?['username'] as String? ?? '').toLowerCase();

      if (username == currentUsername) {
        if (!mounted) return;

        setState(() {
          _available = true;
          _checking = false;
          _message = 'This is your current username.';
        });
        return;
      }

      final existing = await db
          .collection('usernames')
          .doc(username)
          .get();

      if (!mounted) return;

      setState(() {
        _available = !existing.exists;
        _checking = false;
        _message = existing.exists
            ? 'This username is already taken.'
            : 'Username is available!';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _checking = false;
        _available = false;
        _message = 'Could not check username. Check your connection.';
      });
    }
  }

  Future<void> _saveUsername() async {
    if (_saving) return;

    final username = _controller.text.trim().toLowerCase();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in again.');
      return;
    }

    if (!_isValid(username)) {
      _showMessage('Please enter a valid username.');
      return;
    }

    setState(() => _saving = true);

    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(user.uid);
    final usernameRef = db.collection('usernames').doc(username);

    try {
      await db.runTransaction((transaction) async {
        final currentSnapshot = await transaction.get(userRef);
        final oldUsername =
        (currentSnapshot.data()?['username'] as String? ?? '')
            .toLowerCase();

        if (oldUsername == username) return;

        final usernameSnapshot = await transaction.get(usernameRef);

        if (usernameSnapshot.exists) {
          throw Exception('USERNAME_TAKEN');
        }

        transaction.set(usernameRef, {
          'uid': user.uid,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(
          userRef,
          {
            'username': username,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        if (oldUsername.isNotEmpty) {
          final oldRef = db.collection('usernames').doc(oldUsername);
          transaction.delete(oldRef);
        }
      });

      if (!mounted) return;

      Navigator.pop(context, username);
    } catch (e) {
      if (!mounted) return;

      final text = e.toString().contains('USERNAME_TAKEN')
          ? 'This username has already been taken.'
          : 'Could not save username. Please check Firestore rules.';

      _showMessage(text);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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
    _controller.removeListener(_onUsernameChanged);
    _controller.dispose();
    super.dispose();
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
          'Username',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          children: [
            const Text(
              'Choose your username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your username helps people find you on ByChat without '
                  'needing your phone number.',
              style: TextStyle(
                color: _muted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _green,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '@',
                    style: TextStyle(
                      color: _green,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLength: 30,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'your_username',
                        hintStyle: TextStyle(color: _muted),
                        counterText: '',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_checking)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _green,
                      ),
                    )
                  else if (_available)
                    const Icon(Icons.check_circle, color: _green)
                  else
                    const Icon(Icons.alternate_email, color: _muted),
                ],
              ),
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _message,
                style: TextStyle(
                  color: _available ? _green : Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 22),
            const Text(
              'Username rules',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• 3–30 characters\n'
                  '• Letters and numbers\n'
                  '• Underscores (_) and periods (.)\n'
                  '• Must be unique on ByChat',
              style: TextStyle(
                color: _muted,
                height: 1.8,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                child: _saving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
