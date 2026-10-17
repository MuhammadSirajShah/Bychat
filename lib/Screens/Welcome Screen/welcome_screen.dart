
import 'package:flutter/material.dart';

import '../Auth Screen/phone_login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const Color primaryColor = Color(0xFF6558F5);
  static const Color backgroundColor = Color(0xFF10111A);

  String selectedLanguage = 'English';

  void _showInformation(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF20212D),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    final languages = [
      'English',
      'اردو',
      'العربية',
      'हिन्दी',
      'Español',
      'Français',
      '中文',
      'বাংলা',
      'Türkçe',
      'Português',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF20212D),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  'Choose language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...languages.map(
                    (language) => ListTile(
                  title: Text(
                    language,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: selectedLanguage == language
                      ? const Icon(Icons.check_circle, color: primaryColor)
                      : null,
                  onTap: () {
                    setState(() => selectedLanguage = language);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 28,
                ),
                color: const Color(0xFF252635),
                onSelected: (value) {
                  if (value == 'help') {
                    _showInformation(
                      'Help',
                      'Welcome to ByChat Help. Support options will be '
                          'available here.',
                    );
                  } else if (value == 'accessibility') {
                    _showInformation(
                      'Accessibility',
                      'Accessibility options will be available here.',
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'help',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline),
                        SizedBox(width: 12),
                        Text('Help'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'accessibility',
                    child: Row(
                      children: [
                        Icon(Icons.accessibility_new),
                        SizedBox(width: 12),
                        Text('Accessibility'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            height: 190,
                            width: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal.withValues(alpha: 0.20),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 132,
                                  width: 132,
                                  decoration: const BoxDecoration(
                                    color: Colors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const Icon(
                                  Icons.forum_rounded,
                                  size: 78,
                                  color: Colors.white,
                                ),
                                const Positioned(
                                  right: 28,
                                  bottom: 35,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFFB7AEFF),
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Welcome to ByChat',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Connect with your people. Share your moments. '
                                'Stay close, wherever you are.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => _showInformation(
                                  'Privacy Policy',
                                  'ByChat will explain what information it '
                                      'collects, how information is used, how it '
                                      'is protected, and the choices available '
                                      'to users. The complete policy must be '
                                      'published before public release.',
                                ),
                                child: const Text('Privacy Policy'),
                              ),
                              const Text(
                                ' • ',
                                style: TextStyle(color: Colors.white54),
                              ),
                              TextButton(
                                onPressed: () => _showInformation(
                                  'Terms of Service',
                                  'These terms will describe the rules for '
                                      'using ByChat, user responsibilities, '
                                      'acceptable use, and service limitations. '
                                      'The final terms must be reviewed before '
                                      'public release.',
                                ),
                                child: const Text('Terms of Service'),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _showInformation(
                              'Learn More',
                              'ByChat is a messaging app concept designed '
                                  'to help people connect using their phone '
                                  'numbers. Phone verification and other features '
                                  'will be introduced during setup.',
                            ),
                            child: const Text(
                              'Learn More',
                              style: TextStyle(
                                color: Color(0xFF9E94FF),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: _showLanguagePicker,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.language,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedLanguage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _continue,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Agree & Continue',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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
}
