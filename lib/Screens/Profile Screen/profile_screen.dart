
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _name = prefs.getString('bychat_profile_name') ?? 'Your Name';
      _profileImagePath =
          prefs.getString('bychat_profile_image_path');
      _phoneNumber =
          prefs.getString('bychat_phone_number') ?? 'Not added yet';
      _about =
          prefs.getString('bychat_profile_about') ??
              'Hey there! I am using ByChat.';
      _isLoading = false;
    });
  }

  Future<void> _editField(String title, String currentValue) async {
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: title == 'About' ? 139 : 40,
            maxLines: title == 'About' ? 3 : 1,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty || !mounted) return;

    final prefs = await SharedPreferences.getInstance();

    if (title == 'Name') {
      await prefs.setString('bychat_profile_name', result);
    } else {
      await prefs.setString('bychat_profile_about', result);
    }

    if (!mounted) return;

    setState(() {
      if (title == 'Name') {
        _name = result;
      } else {
        _about = result;
      }
    });
  }

  Widget _buildProfilePicture() {
    final path = _profileImagePath;
    final hasImage = path != null &&
        path.isNotEmpty &&
        File(path).existsSync();

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
                    backgroundColor: const Color(0xFF6558F5),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Profile photo editing will be added next.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 19,
                        color: Colors.white,
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
            onTap: () => _editField('Name', _name),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text(_about),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editField('About', _about),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Phone number'),
            subtitle: Text(_phoneNumber),
          ),
          ListTile(
            leading: const Icon(Icons.wallpaper_outlined),
            title: const Text('Background / Cover picture'),
            subtitle: const Text('Personalize your profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cover picture feature will be added later.'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Business information'),
            subtitle: const Text('Add your business details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Business information feature will be added later.'),
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
