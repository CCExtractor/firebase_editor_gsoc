import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_editor_gsoc/views/screens/starter_screens/starter_screen_2.dart';
import 'package:firebase_editor_gsoc/views/screens/starter_screens/starter_screen_3.dart';

void main() {
  testWidgets('Tapping on screen navigates to StarterScreen3', (WidgetTester tester) async {
    // Initialize the GetX navigation
    await tester.pumpWidget(
      GetMaterialApp(
        home: const StarterScreen2(),
      ),
    );

    // Tap the screen to trigger navigation
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    // Verify that navigation to StarterScreen3 occurred
    expect(find.byType(StarterScreen3), findsOneWidget);
  });

  testWidgets('Tapping on the forward arrow icon navigates to StarterScreen3', (WidgetTester tester) async {
    // Initialize the GetX navigation
    await tester.pumpWidget(
      GetMaterialApp(
        home: const StarterScreen2(),
      ),
    );

    // Tap the forward arrow icon to trigger navigation
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    await tester.pumpAndSettle();

    // Verify that navigation to StarterScreen3 occurred
    expect(find.byType(StarterScreen3), findsOneWidget);
  });

  testWidgets('Displays the correct content', (WidgetTester tester) async {
    // Initialize the GetX navigation
    await tester.pumpWidget(
      GetMaterialApp(
        home: const StarterScreen2(),
      ),
    );

    // Verify the image and texts are present
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Access'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('your databases anytime, anywhere!'), findsOneWidget);
  });
}
