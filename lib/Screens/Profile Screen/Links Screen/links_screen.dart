
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Links Privacy Screen/links_privacy_screen.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  static const Color _green = Color(0xFF20C875);
  static const Color _background = Color(0xFF0B1013);
  static const Color _muted = Color(0xFF929A9E);

  CollectionReference<Map<String, dynamic>>? get _links {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('links');
  }

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
      'name': 'GitHub',
      'icon': Icons.code,
      'hint': 'https://github.com/username',
    },
    {
      'name': 'WhatsApp',
      'icon': Icons.chat_outlined,
      'hint': 'https://wa.me/923001234567',
    },
    {
      'name': 'Other',
      'icon': Icons.link,
      'hint': 'https://example.com',
    },
  ];

  IconData _iconFor(String platform) {
    for (final item in _platforms) {
      if (item['name'] == platform) {
        return item['icon'] as IconData;
      }
    }

    return Icons.link;
  }

  Future<void> _openPrivacy() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LinksPrivacyScreen(),
      ),
    );
  }

  Future<void> _showLinkDialog({
    required String platform,
    String? documentId,
    String? initialUrl,
  }) async {
    final collection = _links;

    if (collection == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    final controller = TextEditingController(
      text: initialUrl ?? '',
    );

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !saving,
        builder: (dialogContext) {
          final platformInfo = _platforms.firstWhere(
                (item) => item['name'] == platform,
            orElse: () => _platforms.last,
          );

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF182126),
                title: Text(
                  documentId == null
                      ? 'Add $platform link'
                      : 'Edit $platform link',
                  style: const TextStyle(color: Colors.white),
                ),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Profile URL',
                      hintText: platformInfo['hint'] as String,
                      labelStyle: const TextStyle(color: _muted),
                      hintStyle: const TextStyle(color: _muted),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _muted),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _green),
                      ),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      final uri = Uri.tryParse(text);

                      if (text.isEmpty) {
                        return 'Enter your profile URL';
                      }

                      if (uri == null ||
                          !uri.hasScheme ||
                          !['https', 'http'].contains(uri.scheme) ||
                          uri.host.isEmpty) {
                        return 'Enter a valid URL starting with https://';
                      }

                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                      if (!(formKey.currentState?.validate() ??
                          false)) {
                        return;
                      }

                      setDialogState(() {
                        saving = true;
                      });

                      try {
                        final data = <String, dynamic>{
                          'platform': platform,
                          'url': controller.text.trim(),
                          'updatedAt':
                          FieldValue.serverTimestamp(),
                        };

                        if (documentId == null) {
                          await collection.add({
                            ...data,
                            'createdAt':
                            FieldValue.serverTimestamp(),
                          });
                        } else {
                          await collection
                              .doc(documentId)
                              .update(data);
                        }

                        if (!dialogContext.mounted) return;

                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                        if (dialogContext.mounted) {
                          setDialogState(() {
                            saving = false;
                          });
                        }

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not save link: $e',
                            ),
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
                        color: Colors.black,
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
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deleteLink(String documentId) async {
    try {
      await _links?.doc(documentId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link removed.')),
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
        !['https', 'http'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this link.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this link.'),
        ),
      );
    }
  }

  Widget _platformRow(
      String platform,
      IconData icon,
      Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> savedLinks,
      ) {
    final document = savedLinks[platform];
    final url = document?.data()['url'] as String? ?? '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 5,
      ),
      leading: Icon(icon, color: _muted, size: 31),
      title: Text(
        platform,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
      subtitle: document == null
          ? null
          : Text(
        url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _muted,
          fontSize: 12,
        ),
      ),
      trailing: document == null
          ? IconButton(
        tooltip: 'Add $platform',
        onPressed: () => _showLinkDialog(
          platform: platform,
        ),
        icon: const Icon(
          Icons.add,
          color: _muted,
          size: 29,
        ),
      )
          : PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: _muted,
        ),
        onSelected: (value) {
          if (value == 'open') {
            _openLink(url);
          } else if (value == 'edit') {
            _showLinkDialog(
              platform: platform,
              documentId: document.id,
              initialUrl: url,
            );
          } else if (value == 'delete') {
            _deleteLink(document.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'open',
            child: Text('Open link'),
          ),
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Remove'),
          ),
        ],
      ),
      onTap: document == null
          ? () => _showLinkDialog(platform: platform)
          : () => _openLink(url),
    );
  }

  // FIX: Close the bottom sheet first, then open the dialog.
  Future<void> _showAddAnotherLinkSheet() async {
    final otherPlatforms = _platforms
        .where(
          (item) =>
      item['name'] != 'Instagram' &&
          item['name'] != 'Facebook',
    )
        .toList();

    final selectedPlatform = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF182126),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Add another link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...otherPlatforms.map((item) {
                return ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: _green,
                  ),
                  title: Text(
                    item['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.add,
                    color: _muted,
                  ),
                  onTap: () {
                    // Return the selected platform to the caller.
                    // Do not open a dialog from inside the sheet.
                    Navigator.of(sheetContext).pop(
                      item['name'] as String,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );

    // Wait for the bottom sheet to finish closing.
    if (!mounted || selectedPlatform == null) return;

    // Now open the dialog using the screen's context.
    await _showLinkDialog(platform: selectedPlatform);
  }

  @override
  Widget build(BuildContext context) {
    final collection = _links;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Links',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFF20272B),
          ),
        ),
      ),
      body: collection == null
          ? const Center(
        child: Text(
          'Please sign in to manage your links.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: collection.orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load links. Check your Firestore rules and connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _green,
              ),
            );
          }

          final savedLinks =
          <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

          for (final document in snapshot.data?.docs ?? []) {
            final platform =
                document.data()['platform'] as String? ?? 'Other';

            savedLinks[platform] = document;
          }

          return ListView(
            padding: const EdgeInsets.only(
              top: 22,
              bottom: 35,
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Adding links to your ByChat profile helps your contacts easily visit your other profiles.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _platformRow(
                'Instagram',
                Icons.camera_alt_outlined,
                savedLinks,
              ),
              _platformRow(
                'Facebook',
                Icons.facebook,
                savedLinks,
              ),
              const SizedBox(height: 12),
              if (savedLinks.keys.any(
                    (name) =>
                name != 'Instagram' &&
                    name != 'Facebook',
              )) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(32, 16, 24, 8),
                  child: Text(
                    'Other links',
                    style: TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                ...savedLinks.keys
                    .where(
                      (name) =>
                  name != 'Instagram' &&
                      name != 'Facebook',
                )
                    .map(
                      (name) => _platformRow(
                    name,
                    _iconFor(name),
                    savedLinks,
                  ),
                ),
              ],
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'To manage who can see your links, go to ',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: _openPrivacy,
                      child: const Text(
                        'privacy settings.',
                        style: TextStyle(
                          color: _green,
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: OutlinedButton.icon(
                  onPressed: _showAddAnotherLinkSheet,
                  icon: const Icon(Icons.add_link),
                  label: const Text('Add another link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
