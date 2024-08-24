import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_editor_gsoc/views/starter_screen_1.dart';
import 'package:firebase_editor_gsoc/views/starter_screen_2.dart';

void main() {
  testWidgets('StarterScreen1 renders correctly and navigates on tap', (WidgetTester tester) async {
    // Initialize the GetX navigation
    await tester.pumpWidget(
      GetMaterialApp(
        home: const StarterScreen1(),
      ),
    );

    // Verify the initial UI elements
    expect(find.text('Firebase'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);

    // Tap anywhere on the screen
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    // Verify that navigation to StarterScreen2 occurred
    expect(find.byType(StarterScreen2), findsOneWidget);
  });

  testWidgets('Navigates to StarterScreen2 when arrow icon is pressed', (WidgetTester tester) async {
    // Initialize the GetX navigation
    await tester.pumpWidget(
      GetMaterialApp(
        home: const StarterScreen1(),
      ),
    );

    // Tap the forward arrow icon
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    await tester.pumpAndSettle();

    // Verify that navigation to StarterScreen2 occurred
    expect(find.byType(StarterScreen2), findsOneWidget);
  });
}
