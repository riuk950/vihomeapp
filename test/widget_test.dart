// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/app/app.dart';

void main() {
  group('FlavorApp Widget Tests', () {
    testWidgets('should render MaterialApp with correct title', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const FlavorApp());

      // Verify that MaterialApp is present
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify AppBar title is correct
      expect(find.text('Material App Bar'), findsOneWidget);
    });

    testWidgets('should display Scaffold with correct body text', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const FlavorApp());

      // Verify Scaffold is present
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify body contains text that starts with 'Hello World'
      expect(find.textContaining('Hello World'), findsOneWidget);
    });

    testWidgets('should have correct widget tree structure', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const FlavorApp());

      // Verify the widget tree structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // AppBar title and body text
    });
  });
}
