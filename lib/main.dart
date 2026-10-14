
import 'package:flutter/material.dart';
import 'Screens/home_screen/home_screen.dart';

void main() {
  runApp(const ByChatApp());
}

class ByChatApp extends StatelessWidget {
  const ByChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6558F5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByChat',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7FC),
          foregroundColor: Color(0xFF202033),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
