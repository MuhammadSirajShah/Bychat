import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a new user's profile and phone lookup.
  Future<void> saveProfile({
    required User user,
    required String name,
    String? profileImagePath,
  }) async {
    final phoneNumber = _getVerifiedPhoneNumber(user);

    final userRef = _firestore.collection('users').doc(user.uid);
    final lookupRef =
    _firestore.collection('phoneLookups').doc(phoneNumber);

    final batch = _firestore.batch();

    batch.set(
      userRef,
      {
        'name': name,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(lookupRef, {
      'uid': user.uid,
      'phoneNumber': phoneNumber,
    });

    await batch.commit();

    await _saveLocalProfile(
      name: name,
      phoneNumber: phoneNumber,
      profileImagePath: profileImagePath,
    );
  }

  /// Registers the verified phone number of an existing user.
  /// Does not change the user's profile or setup status.
  Future<void> ensurePhoneLookup(User user) async {
    final phoneNumber = _getVerifiedPhoneNumber(user);

    await _firestore
        .collection('phoneLookups')
        .doc(phoneNumber)
        .set({
      'uid': user.uid,
      'phoneNumber': phoneNumber,
    });
  }

  String _getVerifiedPhoneNumber(User user) {
    final phoneNumber = user.phoneNumber?.trim() ?? '';

    if (phoneNumber.isEmpty) {
      throw Exception(
        'Your verified phone number is missing. Please sign in again.',
      );
    }

    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber)) {
      throw Exception(
        'Your phone number format is invalid. Please verify your number again.',
      );
    }

    return phoneNumber;
  }

  Future<void> _saveLocalProfile({
    required String name,
    required String phoneNumber,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('bychat_profile_name', name);
    await prefs.setString('bychat_profile_phone', phoneNumber);

    if (profileImagePath != null) {
      await prefs.setString(
        'bychat_profile_image_path',
        profileImagePath,
      );
    }

    await prefs.setBool('permission_screen_completed', true);
    await prefs.setBool('profile_setup_completed', true);
  }
}