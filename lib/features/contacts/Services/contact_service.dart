
import 'package:bychat/features/contacts/models/bychat_contact_model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
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

    final results = <ByChatContactModel>[];
    final seenNumbers = <String>{};

    for (final contact in phoneContacts) {
      final contactName = contact.displayName?.trim() ?? '';

      for (final phone in contact.phones) {
        final originalPhone = phone.number.trim();
        final normalizedPhone = _normalizePhoneNumber(originalPhone);

        if (normalizedPhone.isEmpty ||
            !seenNumbers.add(normalizedPhone)) {
          continue;
        }

        results.add(
          ByChatContactModel(
            uid: '',
            name: contactName.isEmpty ? originalPhone : contactName,
            phoneNumber: originalPhone,
            username: '',
            photoUrl: null,
            isRegistered: false,
          ),
        );
      }
    }

    results.sort(
          (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );

    return results;
  }

  String _normalizePhoneNumber(String phone) {
    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    }

    if (normalized.startsWith('0092')) {
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('0') &&
        normalized.length == 11) {
      normalized = '92${normalized.substring(1)}';
    }

    if (!RegExp(r'^\d{8,15}$').hasMatch(normalized)) {
      return '';
    }

    return normalized;
  }
}
