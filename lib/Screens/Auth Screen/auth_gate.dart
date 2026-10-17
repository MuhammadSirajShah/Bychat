
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Permission Screen/permission_screen.dart';
import '../Welcome Screen/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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

        if (snapshot.hasData) {
          return const PermissionScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
