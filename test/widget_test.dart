import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Tests', () {
    testWidgets('MaterialApp can be created', (WidgetTester tester) async {
      // Test that we can create a basic MaterialApp
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      );

      // Verify that the app starts successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('Scaffold can be created', (WidgetTester tester) async {
      // Test basic widget creation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });
  });
} 