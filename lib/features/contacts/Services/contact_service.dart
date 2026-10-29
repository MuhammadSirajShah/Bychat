
import 'package:bychat/features/contacts/models/bychat_contact_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  ContactService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

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

    final contactEntries = <Map<String, String>>[];
    final allNormalizedPhones = <String>{};

    for (final contact in phoneContacts) {
      final contactName = contact.displayName?.trim() ?? '';

      for (final phone in contact.phones) {
        final originalPhone = phone.number.trim();
        final normalizedPhone = _normalizePhoneNumber(originalPhone);

        if (normalizedPhone.isEmpty ||
            !allNormalizedPhones.add(normalizedPhone)) {
          continue;
        }

        contactEntries.add({
          'name': contactName.isEmpty ? originalPhone : contactName,
          'phoneNumber': originalPhone,
          'normalizedPhone': normalizedPhone,
        });
      }
    }

    final registeredUsers = <String, Map<String, dynamic>>{};

    final callable = _functions.httpsCallable('findByChatContacts');

    // The Cloud Function accepts a maximum of 200 numbers per request.
    for (var start = 0;
    start < contactEntries.length;
    start += 200) {
      final end = (start + 200 < contactEntries.length)
          ? start + 200
          : contactEntries.length;

      final batch = contactEntries.sublist(start, end);
      final phoneNumbers = batch
          .map((entry) => entry['normalizedPhone']!)
          .toList();

      final response = await callable.call<Map<String, dynamic>>({
        'phoneNumbers': phoneNumbers,
      });

      final data = response.data;
      final matches = data['contacts'];

      if (matches is! List) continue;

      for (final match in matches) {
        if (match is! Map) continue;

        final user = Map<String, dynamic>.from(match);
        final normalizedPhone = _normalizePhoneNumber(
          user['phoneNumber'] as String? ?? '',
        );
        final uid = user['uid'] as String? ?? '';

        if (normalizedPhone.isEmpty ||
            uid.isEmpty ||
            uid == currentUserUid) {
          continue;
        }

        registeredUsers[normalizedPhone] = user;
      }
    }

    final results = <ByChatContactModel>[];

    for (final entry in contactEntries) {
      final normalizedPhone = entry['normalizedPhone']!;
      final registeredUser = registeredUsers[normalizedPhone];

      results.add(
        ByChatContactModel(
          uid: registeredUser?['uid'] as String? ?? '',
          name: entry['name']!,
          phoneNumber: entry['phoneNumber']!,
          username: registeredUser?['username'] as String? ?? '',
          photoUrl: registeredUser?['photoUrl'] as String?,
          isRegistered: registeredUser != null,
        ),
      );
    }

    results.sort((a, b) {
      if (a.isRegistered != b.isRegistered) {
        return a.isRegistered ? -1 : 1;
      }

      return a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
    });

    return results;
  }

  String _normalizePhoneNumber(String phone) {
    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    }

    if (normalized.startsWith('0092')) {
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('92')) {
      // Already includes Pakistan's country code.
    } else if (normalized.startsWith('0') &&
        normalized.length == 11) {
      normalized = '92${normalized.substring(1)}';
    }

    return normalized;
  }
}
