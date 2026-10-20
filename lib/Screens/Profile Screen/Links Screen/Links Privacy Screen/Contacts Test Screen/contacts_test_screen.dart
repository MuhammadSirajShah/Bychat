
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsTestScreen extends StatefulWidget {
  const ContactsTestScreen({super.key});

  @override
  State<ContactsTestScreen> createState() =>
      _ContactsTestScreenState();
}

class _ContactsTestScreenState extends State<ContactsTestScreen> {
  bool isLoading = false;
  String message = 'Mobile contacts load karne ke liye button dabayein.';
  List<Contact> contacts = [];

  Future<void> loadContacts() async {
    setState(() {
      isLoading = true;
      message = 'Contacts load ho rahe hain...';
    });

    try {
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (status != PermissionStatus.granted) {
        if (!mounted) return;

        setState(() {
          message = 'Contacts permission allow nahi hui.';
          isLoading = false;
        });
        return;
      }

      final result = await FlutterContacts.getAll(
        properties: {
          ContactProperty.name,
          ContactProperty.phone,
        },
      );

      if (!mounted) return;

      setState(() {
        contacts = result;
        message = 'Total contacts: ${result.length}';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts Test'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isLoading ? null : loadContacts,
                  child: const Text('Load Mobile Contacts'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];

                final numbers = contact.phones
                    .map((phone) => phone.number)
                    .join(', ');

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(contact.displayName ?? 'Unknown'),
                  subtitle: Text(
                    numbers.isEmpty ? 'No phone number' : numbers,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
