
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bychat/features/contacts/models/bychat_contact_model.dart';
import 'package:bychat/features/contacts/services/contact_service.dart';

final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService();
});

final byChatContactsProvider =
FutureProvider<List<ByChatContactModel>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('Please sign in to view your contacts.');
  }

  final contactService = ref.watch(contactServiceProvider);

  return contactService.loadContacts(
    currentUserUid: user.uid,
  );
});
