
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  final String initialAbout;

  const AboutScreen({
    super.key,
    required this.initialAbout,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const Color green = Color(0xFF20C875);
  static const Color background = Color(0xFF0B1013);
  static const Color panel = Color(0xFF20282B);

  final TextEditingController _controller = TextEditingController();

  String _emoji = '';
  String _duration = '1 day';
  String _privacy = 'My contacts';

  final List<Map<String, String>> _suggestions = [
    {'emoji': '🌙', 'text': 'Away, leave a message'},
    {'emoji': '😴', 'text': 'Sleeping'},
    {'emoji': '💼', 'text': 'At work'},
    {'emoji': '✈️', 'text': 'Traveling'},
    {'emoji': '💪', 'text': 'At the gym'},
    {'emoji': '📚', 'text': 'Studying'},
    {'emoji': '🎮', 'text': 'Gaming'},
    {'emoji': '🎧', 'text': 'Listening to music'},
    {'emoji': '🏠', 'text': 'At home'},
    {'emoji': '😊', 'text': 'Available'},
    {'emoji': '🔋', 'text': 'Battery about to die'},
    {'emoji': '🚗', 'text': 'On the road'},
  ];

  @override
  void initState() {
    super.initState();

    final initial = widget.initialAbout.trim();

    if (initial.isNotEmpty) {
      final match = RegExp(
        r'^(\X)\s*(.*)$',
        unicode: true,
      ).firstMatch(initial);

      if (match != null && _isEmoji(match.group(1)!)) {
        _emoji = match.group(1)!;
        _controller.text = match.group(2) ?? '';
      } else {
        _controller.text = initial;
      }
    }
  }

  bool _isEmoji(String value) {
    return value.runes.any((rune) =>
    rune >= 0x1F000 ||
        rune == 0x2764 ||
        rune == 0x2708 ||
        rune == 0x2600);
  }

  String get _fullAbout {
    final text = _controller.text.trim();
    if (_emoji.isEmpty) return text;
    if (text.isEmpty) return _emoji;
    return '$_emoji $text';
  }

  void _selectSuggestion(String emoji, String text) {
    setState(() {
      _emoji = emoji;
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  Future<void> _save() async {
    final result = _fullAbout.trim();

    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your About')),
      );
      return;
    }

    Navigator.pop(context, result);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'About',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 34,
                  bottom: 16,
                ),
                children: [
                  // About input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: green,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _emoji = _emoji.isEmpty ? '😊' : '';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 12,
                              bottom: 12,
                            ),
                            child: Text(
                              _emoji.isEmpty ? '😊' : _emoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (_) => setState(() {}),
                            maxLength: 139,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'About',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _emoji = '';
                              _controller.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.grey,
                            size: 27,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Duration and privacy
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _optionButton(
                        icon: Icons.access_time,
                        text: _duration,
                        onTap: () => _chooseOption(
                          title: 'Duration',
                          options: [
                            '1 day',
                            '1 week',
                            '1 month',
                            'Custom',
                          ],
                          selected: _duration,
                          onSelected: (value) {
                            setState(() => _duration = value);
                          },
                        ),
                      ),
                      _optionButton(
                        icon: Icons.contact_page_outlined,
                        text: _privacy,
                        onTap: () => _chooseOption(
                          title: 'Who can see my About?',
                          options: [
                            'Everyone',
                            'My contacts',
                            'My contacts except...',
                            'Nobody',
                          ],
                          selected: _privacy,
                          onSelected: (value) {
                            setState(() => _privacy = value);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ..._suggestions.map((item) {
                    final selected =
                        _emoji == item['emoji'] &&
                            _controller.text == item['text'];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        item['emoji']!,
                        style: const TextStyle(fontSize: 31),
                      ),
                      title: Text(
                        item['text']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                        Icons.check,
                        color: green,
                        size: 27,
                      )
                          : null,
                      onTap: () => _selectSuggestion(
                        item['emoji']!,
                        item['text']!,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom preview panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 22),
              decoration: const BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Preview',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _save,
                        style: IconButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.black,
                          fixedSize: const Size(54, 54),
                        ),
                        icon: const Icon(
                          Icons.check,
                          size: 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFF51473F),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fullAbout.isEmpty
                                    ? 'Your About appears here'
                                    : _fullAbout,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: panel,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  _fullAbout.isEmpty
                                      ? '😊 About'
                                      : _fullAbout,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 21),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF303639)),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }

  Future<void> _chooseOption({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...options.map(
                    (option) => ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: option == selected
                      ? const Icon(Icons.check, color: green)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (value != null) onSelected(value);
  }
}
