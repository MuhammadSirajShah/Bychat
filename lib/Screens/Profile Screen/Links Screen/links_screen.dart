
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  static const Color green = Color(0xFF20C875);

  final List<Map<String, dynamic>> _platforms = [
    {
      'name': 'Instagram',
      'icon': Icons.camera_alt_outlined,
      'hint': 'https://instagram.com/username',
    },
    {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'hint': 'https://facebook.com/username',
    },
    {
      'name': 'LinkedIn',
      'icon': Icons.work_outline,
      'hint': 'https://linkedin.com/in/username',
    },
    {
      'name': 'Website',
      'icon': Icons.language,
      'hint': 'https://example.com',
    },
    {
      'name': 'YouTube',
      'icon': Icons.play_circle_outline,
      'hint': 'https://youtube.com/@username',
    },
    {
      'name': 'TikTok',
      'icon': Icons.music_note,
      'hint': 'https://tiktok.com/@username',
    },
    {
      'name': 'Other',
      'icon': Icons.link,
      'hint': 'https://example.com',
    },
  ];

  CollectionReference<Map<String, dynamic>>? get _linksCollection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('links');
  }

  Future<void> _showLinkDialog({
    String? documentId,
    String? initialPlatform,
    String? initialUrl,
  }) async {
    final formKey = GlobalKey<FormState>();
    final urlController = TextEditingController(
      text: initialUrl ?? '',
    );

    String selectedPlatform = initialPlatform ?? 'Instagram';
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                documentId == null ? 'Add link' : 'Edit link',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedPlatform,
                        decoration: const InputDecoration(
                          labelText: 'Platform',
                          border: OutlineInputBorder(),
                        ),
                        items: _platforms.map((platform) {
                          return DropdownMenuItem<String>(
                            value: platform['name'] as String,
                            child: Text(platform['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedPlatform = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: 'Link URL',
                          hintText: _platforms.firstWhere(
                                (p) => p['name'] == selectedPlatform,
                          )['hint'] as String,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          final uri = Uri.tryParse(text);

                          if (text.isEmpty) {
                            return 'Please enter a link';
                          }

                          if (uri == null ||
                              !uri.hasScheme ||
                              (uri.scheme != 'https' &&
                                  uri.scheme != 'http') ||
                              uri.host.isEmpty) {
                            return 'Enter a valid URL starting with https://';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final collection = _linksCollection;
                    if (collection == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please sign in first.'),
                        ),
                      );
                      return;
                    }

                    setDialogState(() => saving = true);

                    try {
                      final data = <String, dynamic>{
                        'platform': selectedPlatform,
                        'url': urlController.text.trim(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      if (documentId == null) {
                        await collection.add({
                          ...data,
                          'createdAt':
                          FieldValue.serverTimestamp(),
                        });
                      } else {
                        await collection.doc(documentId).update(data);
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } catch (e) {
                      setDialogState(() => saving = false);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not save link: $e'),
                        ),
                      );
                    }
                  },
                  child: saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    urlController.dispose();
  }

  Future<void> _deleteLink(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete link?'),
        content: const Text(
          'Are you sure you want to remove this link from your profile?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _linksCollection?.doc(documentId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link deleted.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete link: $e')),
      );
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This link is not valid.')),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this link.')),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }

  IconData _platformIcon(String platform) {
    for (final item in _platforms) {
      if (item['name'] == platform) {
        return item['icon'] as IconData;
      }
    }

    return Icons.link;
  }

  @override
  Widget build(BuildContext context) {
    final collection = _linksCollection;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Links',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLinkDialog(),
        backgroundColor: green,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_link),
        label: const Text('Add link'),
      ),
      body: collection == null
          ? const Center(
        child: Text('Please sign in to manage your links.'),
      )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: collection.orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load links. Please check your connection '
                      'and Firestore security rules.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              const Text(
                'Your social links',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your social profiles or website so people can '
                    'find you outside ByChat.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (documents.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 46,
                          color: green,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No links added yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap “Add link” to add your first social link.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ...documents.map((document) {
                final data = document.data();
                final platform =
                    data['platform'] as String? ?? 'Other';
                final url = data['url'] as String? ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: green.withValues(alpha: 0.15),
                      child: Icon(
                        _platformIcon(platform),
                        color: green,
                      ),
                    ),
                    title: Text(platform),
                    subtitle: Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: url.isEmpty ? null : () => _openLink(url),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _showLinkDialog(
                            documentId: document.id,
                            initialPlatform: _platforms.any(
                                  (p) => p['name'] == platform,
                            )
                                ? platform
                                : 'Other',
                            initialUrl: url,
                          );
                        } else if (action == 'delete') {
                          _deleteLink(document.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
