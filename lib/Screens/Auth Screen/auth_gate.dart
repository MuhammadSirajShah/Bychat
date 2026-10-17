
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Permission Screen/permission_screen.dart';
import '../Welcome Screen/welcome_screen.dart';
import '../home_screen/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasCompletedPermissionScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('permission_screen_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF171C20),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF009688),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        return FutureBuilder<bool>(
          future: _hasCompletedPermissionScreen(),
          builder: (context, permissionSnapshot) {
            if (permissionSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF171C20),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF009688),
                  ),
                ),
              );
            }

            if (permissionSnapshot.data == true) {
              return const HomeScreen();
            }

            return const PermissionScreen();
          },
        );
      },
    );
  }
}
