
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Permission Screen/permission_screen.dart';
import '../Profile Info Screen/profile_info_screen.dart';
import '../Welcome Screen/welcome_screen.dart';
import '../home_screen/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, bool>> _getSetupStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'permissionsCompleted':
      prefs.getBool('permission_screen_completed') ?? false,
      'profileCompleted':
      prefs.getBool('profile_setup_completed') ?? false,
    };
  }

  Widget _loadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFF171C20),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF009688),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        return FutureBuilder<Map<String, bool>>(
          future: _getSetupStatus(),
          builder: (context, setupSnapshot) {
            if (setupSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _loadingScreen();
            }

            if (setupSnapshot.hasError ||
                !setupSnapshot.hasData) {
              return _loadingScreen();
            }

            final setup = setupSnapshot.data!;
            final permissionsCompleted =
                setup['permissionsCompleted'] ?? false;
            final profileCompleted =
                setup['profileCompleted'] ?? false;

            if (profileCompleted) {
              return const HomeScreen();
            }

            if (!permissionsCompleted) {
              return const PermissionScreen();
            }

            return const ProfileInfoScreen();
          },
        );
      },
    );
  }
}
