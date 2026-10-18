
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'About Screen/about_screen.dart';
import 'Name Screen/name_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Your Name';
  String _about = 'Hey there! I am using ByChat.';
  String _phoneNumber = 'Not added yet';
  String? _profileImagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      var name = prefs.getString('bychat_profile_name') ?? 'Your Name';
      var about = prefs.getString('bychat_profile_about') ??
          'Hey there! I am using ByChat.';
      var phone = user?.phoneNumber ??
          prefs.getString('bychat_profile_phone') ??
          prefs.getString('bychat_phone_number') ??
          'Not added yet';

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data();

        if (data != null) {
          name = data['name'] as String? ?? name;
          about = data['about'] as String? ?? about;
          phone = data['phoneNumber'] as String? ?? phone;

          await prefs.setString('bychat_profile_name', name);
          await prefs.setString('bychat_profile_about', about);
          await prefs.setString('bychat_profile_phone', phone);
        }
      }

      if (!mounted) return;

      setState(() {
        _name = name;
        _about = about;
        _phoneNumber = phone;
        _profileImagePath =
            prefs.getString('bychat_profile_image_path');
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load your profile. Check your connection.'),
        ),
      );
    }
  }

  Future<void> _openNameScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => NameScreen(initialName: _name),
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _name = result);
  }



  Future<void> _editAbout() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AboutScreen(initialAbout: _about),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _about = result;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bychat_profile_about', result);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(
          {'about': result},
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('About could not be saved to the server.'),
        ),
      );
    }
  }



  Widget _buildProfilePicture() {
    final path = _profileImagePath;
    final hasImage =
        path != null && path.isNotEmpty && File(path).existsSync();

    return CircleAvatar(
      radius: 58,
      backgroundColor: const Color(0xFFE4DFFF),
      backgroundImage: hasImage ? FileImage(File(path)) : null,
      child: hasImage
          ? null
          : const Icon(
        Icons.person,
        size: 70,
        color: Color(0xFF6558F5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                _buildProfilePicture(),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFF20C875),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Profile photo editing will be added later.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 19,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Available on ByChat',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Name'),
            subtitle: Text(_name),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _openNameScreen,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text(_about),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editAbout,
          ),
          ListTile(
            leading: const Icon(Icons.alternate_email),
            title: const Text('Username'),
            subtitle: const Text('Reserve username'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Username screen is coming next.'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Phone number'),
            subtitle: Text(_phoneNumber),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Links'),
            subtitle: const Text('Add social media links'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Links screen is coming later.'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
