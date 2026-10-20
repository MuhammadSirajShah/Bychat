
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

    for (final item in _suggestions) {
      final emoji = item['emoji']!;

      if (initial.startsWith(emoji)) {
        _emoji = emoji;
        _controller.text =
            initial.substring(emoji.length).trimLeft();
        return;
      }
    }

    _controller.text = initial;
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

  void _save() {
    final result = _fullAbout.trim();

    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your About'),
        ),
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
        child: Stack(
          children: [
            // TOP CONTENT: input, duration, privacy and suggestions
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  32, 22, 32, 30,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                              _emoji =
                              _emoji.isEmpty ? '😊' : '';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              _emoji.isEmpty ? '😊' : _emoji,
                              style: const TextStyle(
                                fontSize: 29,
                              ),
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
                              fontSize: 19,
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
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _optionButton(
                        icon: Icons.access_time,
                        text: _duration,
                        onTap: () => _chooseOption(
                          title: 'Duration',
                          options: const [
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
                          options: const [
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

                  const SizedBox(height: 28),

                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ..._suggestions.map((item) {
                    final selected =
                        _emoji == item['emoji'] &&
                            _controller.text == item['text'];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        item['emoji']!,
                        style: const TextStyle(fontSize: 30),
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

            // DRAGGABLE PREVIEW PANEL

            Positioned.fill(
              child: DraggableScrollableSheet(
                initialChildSize: 0.15,
                minChildSize: 0.12,
                maxChildSize: 0.55,
                snap: true,
                snapSizes: const [0.12, 0.15, 0.55],
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        28, 12, 28, 24,
                      ),
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

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
                                fixedSize: const Size(50, 50),
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 23,
                                    backgroundColor: Color(0xFF51473F),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your Name',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'How others see your About',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
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
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
      icon: Icon(
        icon,
        color: Colors.white,
        size: 21,
      ),
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
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Color(0xFF303639),
        ),
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
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: option == selected
                      ? const Icon(
                    Icons.check,
                    color: green,
                  )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext, option);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (value != null && mounted) {
      onSelected(value);
    }
  }
}
