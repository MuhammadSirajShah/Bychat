
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupService {
  Future<void> saveProfile({
    required User user,
    required String name,
    String? profileImagePath,
  }) async {
    final phoneNumber = user.phoneNumber?.trim() ?? '';

    if (phoneNumber.isEmpty) {
      throw Exception(
        'Verified phone number is missing. Please verify your phone number.',
      );
    }

    // Firebase Phone Auth numbers should be in E.164 format.
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber)) {
      throw Exception(
        'Phone number format is invalid. Please verify your phone number again.',
      );
    }

    final firestore = FirebaseFirestore.instance;

    final userRef = firestore.collection('users').doc(user.uid);

    final lookupRef = firestore
        .collection('phoneLookups')
        .doc(phoneNumber);

    // Save private profile and verified phone lookup together.
    final batch = firestore.batch();

    batch.set(
      userRef,
      {
        'name': name,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      lookupRef,
      {
        'uid': user.uid,
        'phoneNumber': phoneNumber,
      },
    );

    await batch.commit();

    // Save profile information locally.
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
