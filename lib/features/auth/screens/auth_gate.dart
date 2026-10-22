
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_info_screen.dart';
import 'welcome_screen.dart';
import '../../../Screens/home_screen/home_screen.dart';
import 'permission_screen.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final cloudProfileProvider =
FutureProvider.family<bool, String>((ref, uid) async {
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
});

final setupStatusProvider =
FutureProvider<Map<String, bool>>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'permissionsCompleted':
    prefs.getBool('permission_screen_completed') ?? false,
    'profileCompleted':
    prefs.getBool('profile_setup_completed') ?? false,
  };
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => _loadingScreen(),
      error: (error, stackTrace) => _errorScreen(
        message: 'Unable to check your login status. Please try again.',
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (user) {
        if (user == null) {
          return const WelcomeScreen();
        }

        final cloudAsync = ref.watch(cloudProfileProvider(user.uid));

        return cloudAsync.when(
          loading: () => _loadingScreen(),
          error: (error, stackTrace) => _errorScreen(
            message:
            'Unable to load your profile. Please check your internet connection and try again.',
            onRetry: () =>
                ref.invalidate(cloudProfileProvider(user.uid)),
          ),
          data: (hasCloudProfile) {
            if (hasCloudProfile) {
              return const HomeScreen();
            }

            final setupAsync = ref.watch(setupStatusProvider);

            return setupAsync.when(
              loading: () => _loadingScreen(),
              error: (error, stackTrace) => _errorScreen(
                message: 'Unable to load your setup status. Please try again.',
                onRetry: () => ref.invalidate(setupStatusProvider),
              ),
              data: (setup) {
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

  Widget _errorScreen({
    required String message,
    required VoidCallback onRetry,
  }) {
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
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
