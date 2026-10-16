
import 'package:bychat/Screens/Welcome%20Screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ByChat welcome screen displays correctly', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    expect(find.text('Welcome to ByChat'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Learn More'), findsOneWidget);
    expect(find.text('Agree & Continue'), findsOneWidget);
  });
}
