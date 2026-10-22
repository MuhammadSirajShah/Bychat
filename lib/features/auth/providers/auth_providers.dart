import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final cloudProfileProvider = FutureProvider.family<bool, String>((ref, uid) async {
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

final setupStatusProvider = FutureProvider<Map<String, bool>>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'permissionsCompleted':
        prefs.getBool('permission_screen_completed') ?? false,
    'profileCompleted':
        prefs.getBool('profile_setup_completed') ?? false,
  };
});
