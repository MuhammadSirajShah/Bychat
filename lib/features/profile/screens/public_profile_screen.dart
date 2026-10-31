
import 'package:bychat/features/chats/providers/chat_providers.dart';
import 'package:bychat/features/chats/screens/chat_screen.dart';
import 'package:bychat/features/chats/utils/chat_id_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({
    super.key,
    required this.uid,
    required this.username,
  });

  final String uid;
  final String username;

  Future<void> _openChat(
      BuildContext context,
      WidgetRef ref,
      String name,
      ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    if (currentUser.uid == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is your own profile.')),
      );
      return;
    }

    final chatId = createChatId(currentUser.uid, uid);

    try {
      await ref.read(chatMessageActionsProvider).ensureChat(
        chatId: chatId,
        currentUserId: currentUser.uid,
        receiverId: uid,
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            contactName: name,
            receiverUid: uid,
            chatId: chatId,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat open nahi ho saki: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text('Could not load this profile.'),
            );
          }

          final data = snapshot.data!.data() ?? {};

          final storedName = data['name'] as String?;
          final name = storedName != null && storedName.trim().isNotEmpty
              ? storedName.trim()
              : username;

          final links = data['links'];
          final about = (data['about'] as String?) ??
              (links is Map ? (links['about'] as String? ?? '') : '');

          final photoUrl = data['photoUrl'] as String?;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor:
                  theme.colorScheme.surfaceContainerHighest,
                  backgroundImage:
                  photoUrl != null && photoUrl.trim().isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.trim().isEmpty
                      ? const Icon(Icons.person, size: 58)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '@$username',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
              if (about.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  subtitle: Text(about),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => _openChat(context, ref, name),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6558F5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
