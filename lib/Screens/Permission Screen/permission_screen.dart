
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  static const Color backgroundColor = Color(0xFF101418);
  static const Color tealColor = Color(0xFF009688);
  static const Color textColor = Color(0xFFF1F3F5);
  static const Color mutedColor = Color(0xFF9AA4AA);
  static const Color iconBackground = Color(0xFF17221D);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = false;

  Future<void> _continueWithPermissions() async {
    setState(() => _isLoading = true);

    try {
      // Request only the permissions used by this screen.
      await Permission.contacts.request();
      await Permission.photos.request();
      await Permission.notification.request();
    } catch (e) {
      debugPrint('Permission request error: $e');
    }

    if (!mounted) return;

    setState(() => _isLoading = false);
    _openHomeScreen();
  }
  Future<void> _skipPermissions() async {
    await _openHomeScreen();
  }

  Future<void> _openHomeScreen() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('permission_screen_completed', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  Widget _permissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: PermissionScreen.iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: PermissionScreen.tealColor,
              size: 29,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PermissionScreen.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: PermissionScreen.mutedColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PermissionScreen.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: PermissionScreen.iconBackground,
                  borderRadius: BorderRadius.circular(38),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 86,
                  color: PermissionScreen.tealColor,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Allow Access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PermissionScreen.textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'For the best experience on ByChat, '
                    'you can allow access to the following:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PermissionScreen.mutedColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 42),

              _permissionItem(
                icon: Icons.contacts_rounded,
                title: 'Contacts',
                description:
                'Find and connect with people you know on ByChat.',
              ),

              _permissionItem(
                icon: Icons.photo_library_rounded,
                title: 'Photos & Media',
                description:
                'Choose photos and videos to share in your chats.',
              ),

              _permissionItem(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                description:
                'Get notified about new messages and calls.',
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                  _isLoading ? null : _continueWithPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PermissionScreen.tealColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    PermissionScreen.tealColor.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      //strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _isLoading ? null : _skipPermissions,
                style: TextButton.styleFrom(
                  foregroundColor: PermissionScreen.tealColor,
                  minimumSize: const Size(100, 48),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
