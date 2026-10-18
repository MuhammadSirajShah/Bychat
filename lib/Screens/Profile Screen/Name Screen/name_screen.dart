
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key, this.initialName = ''});

  final String initialName;

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  static const Color background = Color(0xFF0B1013);
  static const Color green = Color(0xFF20C875);
  static const Color muted = Color(0xFF929A9E);

  late final TextEditingController _controller;
  bool _showEmojiPicker = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  void _addEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;

    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;

    final updatedText = text.replaceRange(start, end, emoji);

    setState(() {
      _controller.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(
          offset: start + emoji.length,
        ),
      );
    });
  }

  Future<void> _saveName() async {
    final name = _controller.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (name.isEmpty) {
      _message('Please enter your name.');
      return;
    }

    if (name.length > 25) {
      _message('Your name can contain up to 25 characters.');
      return;
    }

    if (user == null) {
      _message('Please sign in again.');
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name,
        'phoneNumber': user.phoneNumber ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pop(context, name);
    } catch (e) {
      if (mounted) {
        _message('Could not save your name. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Name'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: TextField(
                controller: _controller,
                maxLength: 25,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  labelText: 'Your name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  counterStyle: const TextStyle(color: muted),
                  suffixIcon: IconButton(
                    tooltip: 'Choose emoji',
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: muted,
                      size: 28,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: green, width: 1.5),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: green, width: 2),
                  ),
                ),
                onTap: () {
                  if (_showEmojiPicker) {
                    setState(() => _showEmojiPicker = false);
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your name will be visible to people on ByChat.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (_showEmojiPicker)
              SizedBox(
                height: 280,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _addEmoji(emoji.emoji);
                  },
                  config: const Config(
                    height: 280,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: Color(0xFF171C20),
                      emojiSizeMax: 30,
                      columns: 8,
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: background,
                      indicatorColor: green,
                      iconColor: muted,
                      iconColorSelected: green,
                    ),
                    bottomActionBarConfig: BottomActionBarConfig(
                      backgroundColor: background,
                      buttonColor: Color(0xFF222A2E),
                      buttonIconColor: Colors.white,
                    ),
                    searchViewConfig: SearchViewConfig(
                      backgroundColor: Color(0xFF171C20),
                      buttonIconColor: muted,
                      hintText: 'Search emoji',
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
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
            ),
          ],
        ),
      ),
    );
  }
}
