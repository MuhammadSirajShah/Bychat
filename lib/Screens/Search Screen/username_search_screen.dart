
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsernameSearchScreen extends StatefulWidget {
  const UsernameSearchScreen({super.key});

  @override
  State<UsernameSearchScreen> createState() => _UsernameSearchScreenState();
}

class _UsernameSearchScreenState extends State<UsernameSearchScreen> {
  static const Color _green = Color(0xFF20C875);
  static const Color _background = Color(0xFF0B1013);
  static const Color _panel = Color(0xFF20282B);
  static const Color _muted = Color(0xFF929A9E);

  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;
  bool _loading = false;
  String _query = '';
  String? _error;
  Map<String, dynamic>? _result;

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final username = value.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

    setState(() {
      _query = username;
      _result = null;
      _error = null;
      _loading = false;
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

      setState(() {
        _result = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _result = null;
        _error = 'Search failed. Please check your connection.';
        _loading = false;
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
        title: const Text('Search ByChat Users'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                    hintText: 'Search username...',
                    hintStyle: const TextStyle(color: _muted),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: _muted,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: _muted,
                      ),
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
              const SizedBox(height: 24),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: _green),
                )
              else if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: _muted, fontSize: 15),
                )
              else if (username != null && uid != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: _green,
                          child: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@$username',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'ByChat user',
                                style: TextStyle(color: _muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    'Enter a username to find a ByChat account.',
                    style: TextStyle(color: _muted, fontSize: 15),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
