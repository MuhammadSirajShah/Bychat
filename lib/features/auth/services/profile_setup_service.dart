import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupService {
  Future<void> saveProfile({required User user, required String name,String? profileImagePath,}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'name': name,
      'phoneNumber': user.phoneNumber ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('bychat_profile_name', name);
    await prefs.setString(
      'bychat_profile_phone',
      user.phoneNumber ?? '',
    );

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
