
import 'package:flutter/material.dart';

import '../../main.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // Profile shortcut
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            leading: const CircleAvatar(
              radius: 29,
              backgroundColor: Color(0xFFE4DFFF),
              child: Icon(
                Icons.person,
                size: 34,
                color: Color(0xFF6558F5),
              ),
            ),
            title: const Text(
              'Your Name',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Hey there! I am using ByChat.'),
            trailing: const Icon(Icons.qr_code),
            onTap: () {
              _showMessage(context, 'Profile');
            },
          ),

          const Divider(height: 24),

          _settingsItem(
            icon: Icons.key_outlined,
            title: 'Account',
            subtitle: 'Privacy, security and account information',
            onTap: () => _showMessage(context, 'Account'),
          ),

          _settingsItem(
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Control who can see your information',
            onTap: () => _showMessage(context, 'Privacy'),
          ),

          _settingsItem(
            icon: Icons.chat_bubble_outline,
            title: 'Chats',
            subtitle: 'Chat theme, wallpaper and chat settings',
            onTap: () => _showMessage(context, 'Chats settings'),
          ),

          _settingsItem(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Message, group and call notifications',
            onTap: () => _showMessage(context, 'Notifications'),
          ),

          _settingsItem(
            icon: Icons.storage_outlined,
            title: 'Storage and data',
            subtitle: 'Network usage and media storage',
            onTap: () => _showMessage(context, 'Storage and data'),
          ),

          _settingsItem(
            icon: Icons.language_outlined,
            title: 'App language',
            subtitle: 'Choose your preferred language',
            onTap: () => _showMessage(context, 'App language'),
          ),

          // _settingsItem(
          //   icon: Icons.palette_outlined,
          //   title: 'Appearance',
          //   subtitle: 'Light and dark mode',
          //   onTap: () => _showMessage(context, 'Appearance'),
          // ),

          _settingsItem(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Choose light or dark mode',
            onTap: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (sheetContext) {
                  return StatefulBuilder(
                    builder: (context, setSheetState) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Choose appearance',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              RadioListTile<ThemeMode>(
                                title: const Text('Light mode'),
                                secondary: const Icon(Icons.light_mode_outlined),
                                value: ThemeMode.light,
                                groupValue: themeController.themeMode,
                                onChanged: (mode) {
                                  if (mode == null) return;

                                  themeController.setThemeMode(mode);
                                  setSheetState(() {});
                                },
                              ),
                              RadioListTile<ThemeMode>(
                                title: const Text('Dark mode'),
                                secondary: const Icon(Icons.dark_mode_outlined),
                                value: ThemeMode.dark,
                                groupValue: themeController.themeMode,
                                onChanged: (mode) {
                                  if (mode == null) return;

                                  themeController.setThemeMode(mode);
                                  setSheetState(() {});
                                },
                              ),
                              RadioListTile<ThemeMode>(
                                title: const Text('System default'),
                                secondary: const Icon(Icons.settings_brightness),
                                value: ThemeMode.system,
                                groupValue: themeController.themeMode,
                                onChanged: (mode) {
                                  if (mode == null) return;

                                  themeController.setThemeMode(mode);
                                  setSheetState(() {});
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),


          _settingsItem(
            icon: Icons.help_outline,
            title: 'Help',
            subtitle: 'Help center and contact support',
            onTap: () => _showMessage(context, 'Help'),
          ),

          _settingsItem(
            icon: Icons.people_outline,
            title: 'Invite a friend',
            subtitle: 'Invite friends to join ByChat',
            onTap: () => _showMessage(context, 'Invite a friend'),
          ),

          const SizedBox(height: 18),

          Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble,
                  size: 25,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'ByChat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your conversations, your way',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      leading: Icon(icon, size: 25),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle),
      ),
      onTap: onTap,
    );
  }

  void _showMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature settings will be implemented next.'),
      ),
    );
  }
}
