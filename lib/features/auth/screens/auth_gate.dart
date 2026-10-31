import 'package:bychat/features/auth/providers/auth_providers.dart';
import 'package:bychat/features/auth/services/profile_setup_service.dart';
import 'package:bychat/features/home/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'permission_screen.dart';
import 'profile_info_screen.dart';
import 'welcome_screen.dart';

/// Registers an existing user's verified phone number.
final existingPhoneLookupProvider =
FutureProvider.family<void, User>((ref, user) async {
  await ProfileSetupService().ensurePhoneLookup(user);
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
              return _homeScreenWithPhoneLookup(ref, user);
            }

            final setupAsync = ref.watch(setupStatusProvider);

            return setupAsync.when(
              loading: () => _loadingScreen(),
              error: (error, stackTrace) => _errorScreen(
                message:
                'Unable to load your setup status. Please try again.',
                onRetry: () => ref.invalidate(setupStatusProvider),
              ),
              data: (setup) {
                final permissionsCompleted =
                    setup['permissionsCompleted'] ?? false;
                final profileCompleted =
                    setup['profileCompleted'] ?? false;

                if (profileCompleted) {
                  return _homeScreenWithPhoneLookup(ref, user);
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

  Widget _homeScreenWithPhoneLookup(WidgetRef ref, User user) {
    final lookupAsync = ref.watch(existingPhoneLookupProvider(user));

    return lookupAsync.when(
      loading: () => _loadingScreen(),
      error: (error, stackTrace) => _errorScreen(
        message:
        'Unable to register your phone number. Please check your internet connection and try again.',
        onRetry: () => ref.invalidate(existingPhoneLookupProvider(user)),
      ),
      data: (_) => const HomeScreen(),
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