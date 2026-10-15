
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

          // Profile picture and name
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 58,
                  backgroundColor: Color(0xFFE4DFFF),
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Color(0xFF6558F5),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFF6558F5),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showMessage(context, 'Change profile photo');
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

          const Center(
            child: Text(
              'Your Name',
              style: TextStyle(
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

          // Name
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Name'),
            subtitle: const Text('Your Name'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () {
              _editField(context, 'Name', 'Your Name');
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Hey there! I am using ByChat.'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () {
              _editField(
                context,
                'About',
                'Hey there! I am using ByChat.',
              );
            },
          ),

          // Phone number
          const ListTile(
            leading: Icon(Icons.phone_outlined),
            title: Text('Phone number'),
            subtitle: Text('Not added yet'),
          ),

          // Cover photo
          ListTile(
            leading: const Icon(Icons.wallpaper_outlined),
            title: const Text('Background / Cover picture'),
            subtitle: const Text('Personalize your profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage(context, 'Change cover picture');
            },
          ),

          const Divider(),

          // Business profile
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Business information'),
            subtitle: const Text('Add your business details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage(context, 'Business information');
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _editField(
      BuildContext context,
      String title,
      String currentValue,
      ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            autofocus: true,
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
                Navigator.pop(dialogContext);
                _showMessage(
                  context,
                  '$title editing will be saved in a later step.',
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message feature will be added later.')),
    );
  }
}
