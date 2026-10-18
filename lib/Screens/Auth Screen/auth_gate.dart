
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<bool> _hasCloudProfile(String uid) async {
    final document = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return false;
    }

    final data = document.data();

    return data != null &&
        data['name'] is String &&
        (data['name'] as String).trim().isNotEmpty;
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

  Widget _errorScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171C20),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load your profile. Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const AuthGate(),
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const WelcomeScreen();
        }

        return FutureBuilder<bool>(
          future: _hasCloudProfile(user.uid),
          builder: (context, cloudSnapshot) {
            if (cloudSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _loadingScreen();
            }

            if (cloudSnapshot.hasError) {
              return _errorScreen(context);
            }

            if (cloudSnapshot.data == true) {
              return const HomeScreen();
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
                  return _errorScreen(context);
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
      },
    );
  }
}
