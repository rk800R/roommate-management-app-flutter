// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roommate/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows the RoomieSync branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('RoomieSync'), findsOneWidget);
    expect(find.text('Smart Roommate Management'), findsOneWidget);
  });
}
