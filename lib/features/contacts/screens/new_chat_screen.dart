
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bychat/features/contacts/models/bychat_contact_model.dart';
import 'package:bychat/features/contacts/providers/contact_providers.dart';

class NewChatScreen extends ConsumerWidget {
  const NewChatScreen({super.key});

  static const Color _background = Color(0xFF101418);
  static const Color _panel = Color(0xFF20282B);
  static const Color _teal = Color(0xFF009688);
  static const Color _muted = Color(0xFF9AA4AA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(byChatContactsProvider);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Text(
              'Contacts on ByChat',
              style: TextStyle(fontSize: 12, color: _muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh contacts',
            onPressed: () => ref.invalidate(byChatContactsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: contactsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _teal),
        ),
        error: (error, stackTrace) => _ErrorView(
          message: error.toString().contains('permission')
              ? 'Contacts permission is required to show your phone contacts.'
              : 'Could not load contacts. Please check your connection and permissions.',
          onRetry: () => ref.invalidate(byChatContactsProvider),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No phone contacts found.\nSave a contact on your phone and refresh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, height: 1.5),
                ),
              ),
            );
          }

          final registered =
          contacts.where((contact) => contact.isRegistered).toList();
          final notRegistered =
          contacts.where((contact) => !contact.isRegistered).toList();

          return ListView(
            children: [
              if (registered.isNotEmpty) ...[
                _SectionHeader(
                  title: 'ON BYCHAT',
                  count: registered.length,
                ),
                ...registered.map(
                      (contact) => _ContactTile(contact: contact),
                ),
              ],
              if (notRegistered.isNotEmpty) ...[
                _SectionHeader(
                  title: 'INVITE TO BYCHAT',
                  count: notRegistered.length,
                ),
                ...notRegistered.map(
                      (contact) => _ContactTile(contact: contact),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          color: Color(0xFF009688),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});

  final ByChatContactModel contact;

  @override
  Widget build(BuildContext context) {
    final registered = contact.isRegistered;

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF263238),
        backgroundImage: contact.photoUrl != null &&
            contact.photoUrl!.isNotEmpty
            ? NetworkImage(contact.photoUrl!)
            : null,
        child: contact.photoUrl == null || contact.photoUrl!.isEmpty
            ? Text(
          contact.name.isNotEmpty
              ? contact.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
      title: Text(
        contact.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        registered && contact.username.isNotEmpty
            ? '@${contact.username}'
            : contact.phoneNumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF9AA4AA)),
      ),
      trailing: registered
          ? const Icon(Icons.chat_outlined, color: Color(0xFF009688))
          : const Text(
        'Invite',
        style: TextStyle(
          color: Color(0xFF009688),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        if (registered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${contact.name} is registered. Profile and chat navigation will be connected in the next step.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invite for ${contact.name} will be connected in the next step.',
              ),
            ),
          );
        }
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.contacts_outlined,
              size: 48,
              color: Color(0xFF9AA4AA),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
