
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:bychat/features/contacts/models/bychat_contact_model.dart';

class ContactService {
  ContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<ByChatContactModel>> loadContacts({
    required String currentUserUid,
  }) async {
    final permission = await FlutterContacts.permissions.request(
      PermissionType.read,
    );

    if (permission != PermissionStatus.granted) {
      throw Exception('Contacts permission was not granted.');
    }

    final phoneContacts = await FlutterContacts.getAll(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
      },
    );

    final registeredUsersSnapshot =
    await _firestore.collection('users').get();

    final registeredUsers = <String, Map<String, dynamic>>{};

    for (final document in registeredUsersSnapshot.docs) {
      if (document.id == currentUserUid) continue;

      final data = document.data();
      final phoneNumber = _normalizePhoneNumber(
        data['phoneNumber'] as String? ?? '',
      );

      if (phoneNumber.isNotEmpty) {
        registeredUsers[phoneNumber] = {
          ...data,
          'uid': document.id,
        };
      }
    }

    final results = <ByChatContactModel>[];
    final seenPhones = <String>{};

    for (final contact in phoneContacts) {
      final contactName = contact.displayName.trim();
      if (contact.phones.isEmpty) continue;

      for (final phone in contact.phones) {
        final originalPhone = phone.number.trim();
        final normalizedPhone = _normalizePhoneNumber(originalPhone);

        if (normalizedPhone.isEmpty || !seenPhones.add(normalizedPhone)) {
          continue;
        }

        final registeredUser = registeredUsers[normalizedPhone];

        results.add(
          ByChatContactModel(
            uid: registeredUser?['uid'] as String? ?? '',
            name: contactName.isEmpty ? originalPhone : contactName,
            phoneNumber: originalPhone,
            username: registeredUser?['username'] as String? ?? '',
            photoUrl: registeredUser?['photoUrl'] as String?,
            isRegistered: registeredUser != null,
          ),
        );
      }
    }

    results.sort((a, b) {
      if (a.isRegistered != b.isRegistered) {
        return a.isRegistered ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return results;
  }

  String _normalizePhoneNumber(String phone) {
    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    }

    // Convert Pakistan local numbers to the +92 country-code format.
    if (normalized.startsWith('0092')) {
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('92')) {
      // Already contains Pakistan's country code.
    } else if (normalized.startsWith('0') && normalized.length == 11) {
      normalized = '92${normalized.substring(1)}';
    }

    return normalized;
  }
}
