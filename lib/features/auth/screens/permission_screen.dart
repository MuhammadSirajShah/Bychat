
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_info_screen.dart';


class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  static const Color backgroundColor = Color(0xFF101418);
  static const Color tealColor = Color(0xFF009688);
  static const Color textColor = Color(0xFFF1F3F5);
  static const Color mutedColor = Color(0xFF9AA4AA);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = false;

  Future<bool> _requestAccess({
    required Permission permission,
    required String title,
    required String description,
  }) async {
    final status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!mounted) return false;

    final permanentlyDenied = status.isPermanentlyDenied;

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF222A2E),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          permanentlyDenied
              ? '$description You can enable this permission in Settings '
              'or continue without it for now.'
              : '$description You can try again or continue without '
              'this permission for now.',
          style: const TextStyle(
            color: Color(0xFFCDD3D6),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'continue'),
            child: const Text(
              'Continue',
              style: TextStyle(color: PermissionScreen.tealColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              permanentlyDenied ? 'settings' : 'retry',
            ),
            child: Text(
              permanentlyDenied ? 'Open Settings' : 'Try Again',
              style: const TextStyle(
                color: PermissionScreen.tealColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (choice == 'retry') {
      return _requestAccess(
        permission: permission,
        title: title,
        description: description,
      );
    }

    if (choice == 'settings') {
      await openAppSettings();
    }

    // User may continue even if permission is denied.
    return false;
  }

  Future<void> _continue() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 1. Request contacts access.
      await _requestAccess(
        permission: Permission.contacts,
        title: 'Contacts permission',
        description:
        'ByChat uses contacts to help you find people you know.',
      );

      if (!mounted) return;

      // 2. Request photos and videos access.
      await _requestAccess(
        permission: Permission.photos,
        title: 'Photos and videos permission',
        description:
        'ByChat lets you choose photos and videos to share.',
      );

      if (!mounted) return;

      // 3. Show loading before the Profile Info screen.
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ProfileInfoScreen(),
        ),
      );
    } catch (error) {
      debugPrint('Permission flow error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ProfileInfoScreen(),
      ),
    );
  }

  Widget _permissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF17221D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: PermissionScreen.tealColor,
              size: 29,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PermissionScreen.textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: PermissionScreen.mutedColor,
                    fontSize: 13,
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const Icon(
                    Icons.verified_user_rounded,
                    color: PermissionScreen.tealColor,
                    size: 90,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Allow Access',
                    style: TextStyle(
                      color: PermissionScreen.textColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Connect with people and share moments '
                        'with your friends on ByChat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PermissionScreen.mutedColor,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 38),
                  _permissionItem(
                    icon: Icons.contacts_rounded,
                    title: 'Contacts',
                    description:
                    'Find and connect with people you know.',
                  ),
                  _permissionItem(
                    icon: Icons.photo_library_rounded,
                    title: 'Photos & Videos',
                    description:
                    'Choose photos and videos to share in chats.',
                  ),
                  _permissionItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    description:
                    'Receive alerts about messages and calls.',
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PermissionScreen.tealColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: PermissionScreen.tealColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: PermissionScreen.backgroundColor.withValues(
                  alpha: 0.96,
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: PermissionScreen.tealColor,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: PermissionScreen.textColor,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
