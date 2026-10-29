
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupService {
  Future<void> saveProfile({
    required User user,
    required String name,
    String? profileImagePath,
  }) async {
    final phoneNumber = user.phoneNumber ?? '';

    // Save the user's private profile first.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'name': name,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Maintain the contact lookup through the trusted backend.
    await FirebaseFunctions.instance
        .httpsCallable('updateContactLookup')
        .call();

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
