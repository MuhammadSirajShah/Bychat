
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/home_screen.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  static const Color _background = Color(0xFF101418);
  static const Color _teal = Color(0xFF009688);
  static const Color _text = Color(0xFFF1F3F5);
  static const Color _muted = Color(0xFF9AA4AA);

  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _profileImage;
  bool _isSaving = false;
  bool _showEmojiPicker = false;

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() => _profileImage = image);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select the profile picture.'),
        ),
      );
    }
  }

  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();

    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your phone number first.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save the profile to Firestore using the verified Firebase UID.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name,
        'phoneNumber': user.phoneNumber ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Keep local preferences for the current device.
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('bychat_profile_name', name);
      await prefs.setString(
        'bychat_profile_phone',
        user.phoneNumber ?? '',
      );

      if (_profileImage != null) {
        await prefs.setString(
          'bychat_profile_image_path',
          _profileImage!.path,
        );
      }

      await prefs.setBool('permission_screen_completed', true);
      await prefs.setBool('profile_setup_completed', true);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your profile. Check your internet connection and try again.',
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: const Text('Profile Info'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Please add your name and an optional profile picture.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: const Color(0xFF222A2E),
                              shape: BoxShape.circle,
                              border: Border.all(color: _teal, width: 2),
                              image: _profileImage == null
                                  ? null
                                  : DecorationImage(
                                image: FileImage(
                                  File(_profileImage!.path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: _profileImage == null
                                ? const Icon(
                              Icons.person_rounded,
                              color: _muted,
                              size: 72,
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: _teal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Add profile photo (optional)',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                    const SizedBox(height: 42),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your name',
                        style: TextStyle(color: _muted, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _teal,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              onTap: () {
                                if (_showEmojiPicker) {
                                  setState(() => _showEmojiPicker = false);
                                }
                              },
                              style: const TextStyle(
                                color: _text,
                                fontSize: 17,
                              ),
                              textCapitalization: TextCapitalization.words,
                              maxLength: 40,
                              decoration: const InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(color: _muted),
                                counterText: '',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: const Color(0xFF222A2E),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _toggleEmojiPicker,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: _teal,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.add,
                                    color: _teal,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose a name your contacts will recognize. '
                            'You can change it any time.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'Next',
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
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 280,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    final currentText =
                    _nameController.text.trimRight();

                    final newText = currentText.isEmpty
                        ? emoji.emoji
                        : '$currentText ${emoji.emoji}';

                    setState(() {
                      _nameController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(
                          offset: newText.length,
                        ),
                      );
                    });
                  },
                  config: Config(
                    height: 280,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: const Color(0xFF222A2E),
                      emojiSizeMax: 30,
                      columns: 8,
                      verticalSpacing: 8,
                      horizontalSpacing: 8,
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                      backgroundColor: Color(0xFF171C20),
                      indicatorColor: _teal,
                      iconColor: _muted,
                      iconColorSelected: _teal,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      backgroundColor: Color(0xFF171C20),
                      buttonColor: Color(0xFF222A2E),
                      buttonIconColor: _text,
                    ),
                    searchViewConfig: const SearchViewConfig(
                      backgroundColor: Color(0xFF222A2E),
                      buttonIconColor: _muted,
                      hintText: 'Search emoji',
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
