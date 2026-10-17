import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/Auth Screen/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ByChatApp());
}

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
  }
}

final ThemeController themeController = ThemeController();

class ByChatApp extends StatelessWidget {
  const ByChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6558F5);

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ByChat',
          themeMode: themeController.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F7FC),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.dark,
            ),
          ),
            home: const AuthGate(),
        );
      },
    );
  }
}
